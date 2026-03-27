# Code Dev Plan: Realtime Kanban

## Phase 1: WebSocket Server Core

- What: Implement the kanban-server.cjs with HTTP serving, WebSocket handshake, frame encode/decode, and client connection management
- Where: `skills/meeting/scripts/kanban-server.cjs`
- How: Reuse the RFC 6455 WebSocket pattern from `server.cjs` (handshake, encodeFrame, decodeFrame). Create HTTP server that serves dashboard on `/` and health on `/health`. Handle WebSocket upgrade on `/ws`. Track connected clients in a Set. Bind to port 0 or `--port` value. Parse `--kanban` CLI argument. Emit structured JSON logs.
- Verify:
  - Server starts and binds to a port
  - HTTP GET `/` returns 200 with HTML content
  - HTTP GET `/health` returns JSON with status and uptime
  - WebSocket handshake succeeds on `/ws`
  - Server accepts `--kanban` and `--port` arguments

## Phase 2: File Watcher and State Broadcast

- What: Add fs.watch on kanban.json, debounced read-parse-broadcast, initial state on connection, and idle timeout
- Where: `skills/meeting/scripts/kanban-server.cjs`
- How: Use `fs.watch` on the kanban file path. On change, debounce (200ms), read file, parse JSON, construct KanbanState message, broadcast to all connected WebSocket clients. On new client connection, immediately send current cached state. Start a 30-minute idle timer that resets on each file change; on expiry, gracefully shut down.
- Verify:
  - Modifying kanban.json triggers WebSocket push within 1 second
  - New client receives initial state immediately on connection
  - Malformed JSON in kanban.json is handled gracefully (no crash, no push)
  - Server auto-terminates after 30 minutes of no file changes
  - Multiple rapid file changes produce a single debounced broadcast

## Phase 3: Dashboard HTML

- What: Build the single-file HTML dashboard with 3-column board, real-time updates, connection indicator, and auto-reconnect
- Where: `skills/meeting/scripts/kanban-dashboard.html` (served by kanban-server.cjs)
- How: Single HTML file with inline CSS (flexbox 3-column layout, min-width 800px) and inline JS. WebSocket client connects to server, receives KanbanState messages, renders cards into Backlog/In Progress/Done columns. In-progress cards get visual highlight (CSS animation or border). Header displays topic name and phase. Connection indicator dot changes color. Auto-reconnect with exponential backoff (1s initial, 2x factor, 30s max).
- Verify:
  - Dashboard renders 3 columns: Backlog, In Progress, Done
  - Cards display id and name
  - In-progress cards have visual distinction
  - Header shows topic name and phase
  - Connection indicator shows green when connected
  - Indicator turns red on disconnect, yellow during reconnect
  - Cards move between columns on WebSocket update without page reload

## Phase 4: Lifecycle Scripts

- What: Create start-kanban.sh and stop-kanban.sh following existing script conventions
- Where: `skills/meeting/scripts/start-kanban.sh`, `skills/meeting/scripts/stop-kanban.sh`
- How: start-kanban.sh: parse `--kanban` and `--port` args, create PID directory, kill existing server if PID file exists (AC13), launch kanban-server.cjs via nohup in background, write PID file, wait for `server-started` log line, output JSON with url/pid/pid_dir. stop-kanban.sh: read PID from file, send SIGTERM, wait 2 seconds, SIGKILL if still alive, clean up PID file.
- Verify:
  - start-kanban.sh launches server and outputs JSON with URL
  - PID file is created and contains valid PID
  - stop-kanban.sh terminates the server process
  - Re-running start-kanban.sh kills existing server first
  - stop-kanban.sh handles "not running" case gracefully

## Phase 5: Skill Integration

- What: Add kanban server auto-start to /implement and auto-stop to /lint as best-effort hooks
- Where: `skills/implement/SKILL.md`, `skills/lint/SKILL.md`
- How: In implement SKILL.md, add a setup step after branch creation that runs start-kanban.sh with the topic's kanban.json path, captures the URL, and displays it to the user. Wrap in best-effort guidance (proceed on failure). In lint SKILL.md, add a cleanup step at the end that runs stop-kanban.sh. Both hooks are advisory instructions in the skill markdown.
- Verify:
  - /implement SKILL.md contains kanban server start instruction
  - /lint SKILL.md contains kanban server stop instruction
  - Both hooks are marked as best-effort (non-blocking)
  - Dashboard URL is surfaced to the user
