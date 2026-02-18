#!/usr/bin/env bash
set -e

# Check if running in iTerm
if [ "$TERM_PROGRAM" != "iTerm.app" ]; then
  echo "[error] This command only works in iTerm.app"
  exit 1
fi

# Get current working directory
WORKDIR="$PWD"

VC_TEMPLATE_REPO="${VC_TEMPLATE_REPO:-ebijun1007/vibe-coding}"
VC_TEMPLATE_REF="${VC_TEMPLATE_REF:-master}"
VC_TEMPLATE_ARCHIVE_URL="https://codeload.github.com/${VC_TEMPLATE_REPO}/tar.gz/${VC_TEMPLATE_REF}"

if ! command -v curl >/dev/null 2>&1; then
  echo "[error] curl is required to download template files" >&2
  exit 1
fi

if ! command -v tar >/dev/null 2>&1; then
  echo "[error] tar is required to extract template files" >&2
  exit 1
fi

tmp_dir="$(mktemp -d -t vc-template.XXXXXX)"
cleanup() {
  rm -rf "$tmp_dir"
}
trap cleanup EXIT

archive_path="$tmp_dir/template.tar.gz"

if ! curl -fsSL "$VC_TEMPLATE_ARCHIVE_URL" -o "$archive_path"; then
  echo "[error] Failed to download template archive: $VC_TEMPLATE_ARCHIVE_URL" >&2
  exit 1
fi

tar -xzf "$archive_path" -C "$tmp_dir"

src_root="$(find "$tmp_dir" -mindepth 1 -maxdepth 1 -type d | head -n 1)"
if [ -z "$src_root" ]; then
  echo "[error] Failed to locate extracted template directory" >&2
  exit 1
fi

merge_tree_skip_existing() {
  local src_dir="$1"
  local dest_dir="$2"

  [ -d "$src_dir" ] || return 0
  mkdir -p "$dest_dir"

  while IFS= read -r -d '' rel; do
    rel="${rel#./}"
    [ -n "$rel" ] || continue
    [ "$(basename "$rel")" = ".keep" ] && continue
    [ "$rel" = "CLAUDE.md" ] && continue
    [ "$rel" = "AGENTS.md" ] && continue

    local src_path="$src_dir/$rel"
    local dest_path="$dest_dir/$rel"

    if [ -d "$src_path" ]; then
      mkdir -p "$dest_path"
      continue
    fi

    mkdir -p "$(dirname "$dest_path")"
    if [ ! -e "$dest_path" ]; then
      cp -p "$src_path" "$dest_path"
      echo "[info] Added: $dest_path"
    fi
  done < <(cd "$src_dir" && find . -mindepth 1 -print0)
}

sync_tree_overwrite() {
  local src_dir="$1"
  local dest_dir="$2"

  [ -d "$src_dir" ] || return 0
  mkdir -p "$dest_dir"

  while IFS= read -r -d '' rel; do
    rel="${rel#./}"
    [ -n "$rel" ] || continue
    [ "$(basename "$rel")" = ".keep" ] && continue

    local src_path="$src_dir/$rel"
    local dest_path="$dest_dir/$rel"

    if [ -d "$src_path" ]; then
      mkdir -p "$dest_path"
      continue
    fi

    mkdir -p "$(dirname "$dest_path")"
    if [ -e "$dest_path" ] && cmp -s "$src_path" "$dest_path"; then
      continue
    fi
    cp -p "$src_path" "$dest_path"
    echo "[info] Synced: $dest_path"
  done < <(cd "$src_dir" && find . -mindepth 1 -print0)
}

copy_overwrite_if_exists() {
  local src_file="$1"
  local dest_file="$2"

  if [ -f "$src_file" ]; then
    mkdir -p "$(dirname "$dest_file")"
    cp -p "$src_file" "$dest_file"
    echo "[info] Overwrote: $dest_file"
  fi
}

# .design をワークディレクトリに反映（既存ファイルはスキップ）
if [ ! -d "$src_root/.design" ]; then
  echo "[error] Missing .design in template source: $VC_TEMPLATE_REPO@$VC_TEMPLATE_REF" >&2
  exit 1
fi
merge_tree_skip_existing "$src_root/.design" "$WORKDIR/.design"

# AGENTS.md / CLAUDE.md はテンプレがあれば上書きコピーして揃える
# ~/.claude / ~/.codex はテンプレから追加分を反映（既存ファイルはスキップ）
# ただし CLAUDE.md / AGENTS.md は常に上書き
CLAUDE_HOME="$HOME/.claude"
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"

merge_tree_skip_existing "$src_root/.claude" "$CLAUDE_HOME"
merge_tree_skip_existing "$src_root/.codex" "$CODEX_HOME"

# Skills はリポジトリ側が正本 — 常に上書き同期
sync_tree_overwrite "$src_root/.claude/skills" "$CLAUDE_HOME/skills"
sync_tree_overwrite "$src_root/.codex/skills" "$CODEX_HOME/skills"

copy_overwrite_if_exists "$src_root/.claude/CLAUDE.md" "$CLAUDE_HOME/CLAUDE.md"
copy_overwrite_if_exists "$src_root/.codex/AGENTS.md" "$CODEX_HOME/AGENTS.md"

sync_codex_vibe_kanban_mcp_config() {
  local codex_config="$CODEX_HOME/config.toml"
  local tmp_config
  tmp_config="$(mktemp -t codex-config.XXXXXX)"

  if [ -f "$codex_config" ]; then
    awk '
      BEGIN { skip = 0 }
      /^\[mcp_servers\.vibe_kanban\][[:space:]]*$/ { skip = 1; next }
      /^\[mcp_servers\.vibe-kanban\][[:space:]]*$/ { skip = 1; next }
      {
        if (skip && $0 ~ /^\[[^]]+\][[:space:]]*$/) {
          skip = 0
        }
        if (!skip) {
          print
        }
      }
    ' "$codex_config" >"$tmp_config"
  fi

  {
    if [ -s "$tmp_config" ]; then
      printf "\n"
    fi
    cat <<'EOF'
[mcp_servers.vibe_kanban]
command = "npx"
args = ["-y", "vibe-kanban@latest", "--mcp"]
EOF
  } >>"$tmp_config"

  mkdir -p "$(dirname "$codex_config")"
  mv "$tmp_config" "$codex_config"
  chmod 600 "$codex_config" >/dev/null 2>&1 || true
  echo "[info] Synced mcp_servers.vibe_kanban in: $codex_config"
}

sync_codex_vibe_kanban_mcp_config

echo "[done] Workspace prepared for: $WORKDIR"

ensure_vibe_kanban_running() {
  local port="${VIBE_KANBAN_PORT:-55233}"
  local log_path="${VIBE_KANBAN_LOG_PATH:-/tmp/vibe-kanban.log}"
  local port_file="${VIBE_KANBAN_PORT_FILE:-$HOME/.vibe-kanban/vibe-kanban.port}"
  local lock_dir="/tmp/vibe-kanban-${port}.lock"
  local wait_attempts=300
  local wait_interval=0.2
  local health_url="http://127.0.0.1:${port}/api/health"

  stop_vibe_kanban_processes() {
    local pids
    pids="$(pgrep -f 'vibe-kanban' || true)"
    if [ -z "$pids" ]; then
      return 0
    fi

    echo "[info] Stopping existing vibe-kanban / vibe-kanban-mcp processes..."
    # shellcheck disable=SC2086
    kill $pids >/dev/null 2>&1 || true

    local i
    for ((i = 1; i <= 50; i++)); do
      sleep 0.1
      local still_running=""
      local pid
      for pid in $pids; do
        if kill -0 "$pid" >/dev/null 2>&1; then
          still_running="$still_running $pid"
        fi
      done
      if [ -z "${still_running// /}" ]; then
        return 0
      fi
    done

    echo "[warn] Force killing remaining vibe-kanban processes..."
    # shellcheck disable=SC2086
    kill -9 $pids >/dev/null 2>&1 || true
  }

  wait_for_health() {
    local i
    for ((i = 1; i <= wait_attempts; i++)); do
      if curl -fsS "$health_url" >/dev/null 2>&1; then
        return 0
      fi
      sleep "$wait_interval"
    done

    echo "[error] Failed health check on ${health_url}. See log: ${log_path}" >&2
    return 1
  }

  write_port_file() {
    mkdir -p "$(dirname "$port_file")"
    printf '%s\n' "$port" >"$port_file"
    echo "[info] Wrote vibe-kanban port file: ${port_file}"
  }

  if mkdir "$lock_dir" >/dev/null 2>&1; then
    stop_vibe_kanban_processes

    echo "[info] Starting vibe-kanban on port ${port}"
    nohup env PORT="$port" npx -y vibe-kanban@latest >"$log_path" 2>&1 &

    if wait_for_health; then
      write_port_file
      rmdir "$lock_dir" >/dev/null 2>&1 || true
      echo "[info] Started vibe-kanban on port ${port} (log: ${log_path})"
      return 0
    fi

    rmdir "$lock_dir" >/dev/null 2>&1 || true
    return 1
  fi

  echo "[info] Another vc process is starting vibe-kanban. Waiting for port ${port}..."
  for ((i = 1; i <= wait_attempts; i++)); do
    sleep "$wait_interval"
    if curl -fsS "$health_url" >/dev/null 2>&1; then
      write_port_file
      echo "[info] vibe-kanban is now running on port ${port}"
      return 0
    fi
  done

  echo "[error] Timed out waiting for vibe-kanban on port ${port}" >&2
  return 1
}

ensure_vibe_kanban_running

# Run AppleScript to create iTerm layout
osascript <<EOF
on run
  set workdir to "$WORKDIR"

  tell application "iTerm"
    -- use current session and split it
    tell current session of current window
      -- split into top and bottom
      set topPane to it
      set bottomPane to (split horizontally with default profile)
    end tell

    -- split bottom pane into left and right
    tell bottomPane
      set bottomLeftPane to it
      set bottomRightPane to (split vertically with default profile)
    end tell

    -- top pane: run codex in the repo
    tell topPane
      write text "cd " & workdir & "; if command -v codex >/dev/null 2>&1; then codex; else echo \"[warn] codex not found in PATH\"; fi"
    end tell

    -- bottom left pane: run claude code (dangerously skip permissions)
    tell bottomLeftPane
      write text "cd " & workdir & "; if command -v claude >/dev/null 2>&1; then claude --dangerously-skip-permissions; else echo \"[warn] claude not found in PATH\"; fi"
    end tell

    -- bottom right pane: leave as terminal (just cd to workdir)
    tell bottomRightPane
      write text "cd " & workdir
    end tell

  end tell
end run
EOF

echo "[done] iTerm layout created for: $WORKDIR"
