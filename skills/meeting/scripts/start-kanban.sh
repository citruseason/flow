#!/usr/bin/env bash
# Start the kanban dashboard server and output connection info
# Usage: start-kanban.sh --kanban <path> [--port <port>]
#
# Starts kanban-server.cjs in background, outputs JSON with URL.
# Watches a kanban.json file and serves a real-time dashboard.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Parse arguments
KANBAN_FILE=""
KANBAN_PORT=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --kanban)
      KANBAN_FILE="$2"
      shift 2
      ;;
    --port)
      KANBAN_PORT="$2"
      shift 2
      ;;
    *)
      echo "{\"error\": \"Unknown argument: $1\"}"
      exit 1
      ;;
  esac
done

if [[ -z "$KANBAN_FILE" ]]; then
  echo '{"error": "Usage: start-kanban.sh --kanban <path> [--port <port>]"}'
  exit 1
fi

# Resolve to absolute path
KANBAN_FILE="$(cd "$(dirname "$KANBAN_FILE")" && pwd)/$(basename "$KANBAN_FILE")"

if [[ ! -f "$KANBAN_FILE" ]]; then
  echo "{\"error\": \"Kanban file not found: $KANBAN_FILE\"}"
  exit 1
fi

# Use kanban file's directory for PID/log storage
PID_DIR="$(dirname "$KANBAN_FILE")"
PID_FILE="${PID_DIR}/.kanban.pid"
LOG_FILE="${PID_DIR}/.kanban.log"

# Kill existing server if running (AC13)
if [[ -f "$PID_FILE" ]]; then
  OLD_PID=$(cat "$PID_FILE")
  if kill -0 "$OLD_PID" 2>/dev/null; then
    kill "$OLD_PID" 2>/dev/null || true
    for I in {1..20}; do
      if ! kill -0 "$OLD_PID" 2>/dev/null; then
        break
      fi
      sleep 0.1
    done
    if kill -0 "$OLD_PID" 2>/dev/null; then
      kill -9 "$OLD_PID" 2>/dev/null || true
      sleep 0.1
    fi
  fi
  rm -f "$PID_FILE"
fi

# Build server command
SERVER_CMD="node ${SCRIPT_DIR}/kanban-server.cjs --kanban ${KANBAN_FILE}"
if [[ -n "$KANBAN_PORT" ]]; then
  SERVER_CMD="${SERVER_CMD} --port ${KANBAN_PORT}"
fi

# Start server in background
nohup $SERVER_CMD > "$LOG_FILE" 2>&1 &
SERVER_PID=$!
echo "$SERVER_PID" > "$PID_FILE"

# Wait for server-started log line (up to 5 seconds)
for I in {1..50}; do
  if [[ -f "$LOG_FILE" ]]; then
    STARTED_LINE=$(grep '"type":"server-started"' "$LOG_FILE" 2>/dev/null || true)
    if [[ -n "$STARTED_LINE" ]]; then
      # Extract URL from the log line
      URL=$(echo "$STARTED_LINE" | sed 's/.*"url":"\([^"]*\)".*/\1/')
      echo "{\"url\": \"${URL}\", \"pid\": ${SERVER_PID}, \"pid_dir\": \"${PID_DIR}\"}"
      exit 0
    fi
  fi
  sleep 0.1
done

# Check if process is still alive
if ! kill -0 "$SERVER_PID" 2>/dev/null; then
  echo '{"error": "Server failed to start within 5 seconds"}'
  rm -f "$PID_FILE"
  exit 1
fi

# Process alive but no log line yet — output what we know
echo "{\"url\": \"http://localhost:0\", \"pid\": ${SERVER_PID}, \"pid_dir\": \"${PID_DIR}\", \"warning\": \"server-started log not detected\"}"
