#!/usr/bin/env bash
# Stop the kanban dashboard server and clean up
# Usage: stop-kanban.sh <pid_dir>
#
# Kills the kanban server process using the PID file.

PID_DIR="$1"

if [[ -z "$PID_DIR" ]]; then
  echo '{"error": "Usage: stop-kanban.sh <pid_dir>"}'
  exit 1
fi

PID_FILE="${PID_DIR}/.kanban.pid"

if [[ -f "$PID_FILE" ]]; then
  PID=$(cat "$PID_FILE")

  # Try graceful shutdown
  kill "$PID" 2>/dev/null || true

  # Wait up to 2 seconds
  for I in {1..20}; do
    if ! kill -0 "$PID" 2>/dev/null; then
      break
    fi
    sleep 0.1
  done

  # Escalate to SIGKILL if still alive
  if kill -0 "$PID" 2>/dev/null; then
    kill -9 "$PID" 2>/dev/null || true
    sleep 0.1
  fi

  if kill -0 "$PID" 2>/dev/null; then
    echo '{"status": "failed", "error": "process still running"}'
    exit 1
  fi

  rm -f "$PID_FILE" "${PID_DIR}/.kanban.log"
  echo '{"status": "stopped"}'
else
  echo '{"status": "not_running"}'
fi
