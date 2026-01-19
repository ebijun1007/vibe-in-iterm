#!/usr/bin/env bash
set -e

# Check if running in iTerm
if [ "$TERM_PROGRAM" != "iTerm.app" ]; then
  echo "[error] This command only works in iTerm.app"
  exit 1
fi

# Get current working directory
WORKDIR="$PWD"

VC_TEMPLATE_REPO="${VC_TEMPLATE_REPO:-ebijun1007/vibe-in-iterm}"
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

copy_overwrite_if_exists "$src_root/.claude/CLAUDE.md" "$CLAUDE_HOME/CLAUDE.md"
copy_overwrite_if_exists "$src_root/.codex/AGENTS.md" "$CODEX_HOME/AGENTS.md"

echo "[done] Workspace prepared for: $WORKDIR"

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

    -- split top pane into left and right
    tell topPane
      set topLeftPane to it
      set topRightPane to (split vertically with default profile)
    end tell

    -- top left pane: run codex in the repo
    tell topLeftPane
      write text "cd " & workdir & "; if command -v codex >/dev/null 2>&1; then codex; else echo \"[warn] codex not found in PATH\"; fi"
    end tell

    -- top right pane: run claude code (dangerously skip permissions)
    tell topRightPane
      write text "cd " & workdir & "; if command -v claude >/dev/null 2>&1; then claude --dangerously-skip-permissions; else echo \"[warn] claude not found in PATH\"; fi"
    end tell

    -- bottom pane: leave as terminal (just cd to workdir)
    tell bottomPane
      write text "cd " & workdir
    end tell

  end tell
end run
EOF

echo "[done] iTerm layout created for: $WORKDIR"
