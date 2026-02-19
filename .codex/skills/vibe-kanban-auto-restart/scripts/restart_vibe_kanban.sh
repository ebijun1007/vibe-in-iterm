#!/usr/bin/env bash
set -euo pipefail

PORT="${VIBE_KANBAN_PORT:-55233}"
APP_MATCH="${VIBE_KANBAN_APP_NAME:-vibe-kanban}"
START_CMD="${VIBE_KANBAN_START_CMD:-}"
LOG_FILE="/tmp/vibe-kanban-restart.log"

echo "[restart] target port: ${PORT}"

if lsof -iTCP:"${PORT}" -sTCP:LISTEN -Pn >/dev/null 2>&1; then
  echo "[restart] existing process detected on port ${PORT}"
else
  echo "[restart] no process detected on port ${PORT}"
fi

echo "[restart] stopping processes by pattern: ${APP_MATCH}"
pkill -f "${APP_MATCH}" >/dev/null 2>&1 || true
sleep 2

if [[ -n "${START_CMD}" ]]; then
  echo "[restart] starting by VIBE_KANBAN_START_CMD"
  nohup /bin/zsh -lc "${START_CMD}" >"${LOG_FILE}" 2>&1 &
else
  echo "[restart] VIBE_KANBAN_START_CMD is empty; trying macOS app launch"
  open -a "vibe-kanban" >/dev/null 2>&1 || open -a "Vibe Kanban" >/dev/null 2>&1 || true
fi

echo "[restart] waiting for port ${PORT}"
for _ in {1..30}; do
  if lsof -iTCP:"${PORT}" -sTCP:LISTEN -Pn >/dev/null 2>&1; then
    echo "[restart] ready: port ${PORT} is listening"
    exit 0
  fi
  sleep 1
done

echo "[restart] failed: port ${PORT} did not become ready"
echo "[restart] if needed, set VIBE_KANBAN_START_CMD and retry"
exit 1
