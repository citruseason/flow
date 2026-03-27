# Architecture: Realtime Kanban

## Stack

- Node.js (CommonJS) -- server runtime, zero-dependency
- Built-in modules only: `http`, `fs`, `path`, `crypto`
- HTML/CSS/JS -- single-file inline dashboard (no build step)
- Bash -- lifecycle scripts
- WebSocket RFC 6455 -- real-time communication

## Hierarchy

```
skills/meeting/scripts/
  kanban-server.cjs         -- Main server (HTTP + WebSocket + file watcher)
  kanban-dashboard.html     -- Self-contained dashboard (served by kanban-server.cjs)
  start-kanban.sh           -- Lifecycle: start
  stop-kanban.sh            -- Lifecycle: stop

skills/implement/SKILL.md   -- Integration hook (start)
skills/lint/SKILL.md        -- Integration hook (stop)
```

## Patterns

- **File watcher + push** -- `fs.watch` triggers read-parse-broadcast cycle; avoids polling
- **Debounce** -- Coalesce rapid `fs.watch` events within a short window (~200ms) to prevent duplicate broadcasts
- **Adjacent dashboard file** -- kanban-dashboard.html is a separate self-contained file; kanban-server.cjs reads and serves it via HTTP
- **RFC 6455 manual WebSocket** -- Reuse proven pattern from `server.cjs` (handshake, frame encode/decode); no ws library needed
- **PID file lifecycle** -- Start script writes PID, stop script reads and signals; same pattern as existing `start-server.sh`/`stop-server.sh`
- **Structured JSON logging** -- All server output as JSON lines (`{"event": "...", ...}`) to stdout; matches existing project convention
- **Best-effort integration** -- Skill hooks wrap server start/stop in try-catch equivalent; failure emits warning, does not abort workflow
- **Idle timeout** -- Timer resets on each file change; fires server shutdown after 30 minutes of inactivity

## Constraints

- kanban-server.cjs must never import from or share state with server.cjs
- Server must never write to kanban.json (strictly read-only)
- All server output must be structured JSON (one JSON object per line)
- Dashboard must be a single self-contained HTML file (inline CSS + JS)
- Lifecycle scripts must follow the existing start-server.sh/stop-server.sh conventions
- Port 0 binding for auto-assignment; actual port extracted from `server.listen` callback
- WebSocket path must be `/ws` to avoid collision with HTTP routes
