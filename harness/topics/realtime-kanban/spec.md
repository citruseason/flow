# Spec: Realtime Kanban

## Features

### Kanban WebSocket Server
- Independent server process (separate from Visual Companion)
- Zero-dependency Node.js (http, fs, path, crypto only)
- `--kanban <path>` argument to specify watched kanban.json file
- `fs.watch` on kanban.json, parse and push to all WebSocket clients within 1 second
- Send initial kanban state on first client connection
- Serve HTML dashboard on HTTP
- Auto-assign port (port 0 binding) or accept `--port <port>`
- Idle timeout: auto-terminate after 30 minutes of no kanban.json changes

### Dashboard UI
- 3-column Trello-style layout: Backlog | In Progress | Done (left to right)
- Cards display `id` and `name` fields
- Real-time DOM update on WebSocket message (no page reload)
- Visual highlight/animation on `in_progress` cards
- Header shows topic name and current phase
- Connection status indicator: green (connected), red (disconnected), yellow (reconnecting)
- Auto-reconnect with exponential backoff
- Desktop-optimized, minimum width 800px

### Lifecycle Scripts
- `start-kanban.sh --kanban <path> [--port <port>]` -- background start, PID file, URL output
- `stop-kanban.sh` -- SIGTERM, 2-second grace, then SIGKILL
- Located in `skills/meeting/scripts/`

### Skill Integration
- `/implement` auto-starts kanban server at execution begin
- `/lint` auto-stops kanban server on completion
- Dashboard URL displayed to user
- Best-effort: failures do not block main workflow

### kanban.json Compatibility
- Uses existing kanban.json schema unchanged
- Server is strictly read-only
- Maps `steps.backlog` -> Backlog, `steps.in_progress` -> In Progress, `steps.done` -> Done

## Interfaces

### Server CLI
```
node kanban-server.cjs --kanban <path> [--port <port>]
```

### Environment Variables
```
KANBAN_FILE    -- absolute path to kanban.json (from --kanban)
KANBAN_PORT    -- port number (from --port, default: 0 = auto)
KANBAN_HOST    -- bind host (default: 127.0.0.1)
KANBAN_PID_DIR -- directory for PID/log files
```

### WebSocket Messages (Server -> Client)
```
{
  "type": "kanban-state",
  "topic": string,
  "phase": string,
  "steps": {
    "done": [{ "id": string, "name": string }],
    "in_progress": [{ "id": string, "name": string }],
    "backlog": [{ "id": string, "name": string }]
  }
}
```

### HTTP Endpoints
```
GET /           -- Serve HTML dashboard
GET /health     -- { "status": "ok", "uptime": number }
Upgrade: websocket  -- WebSocket handshake on /ws
```

### Shell Script Interfaces
```bash
# start-kanban.sh
# Input: --kanban <path> [--port <port>]
# Output (stdout): JSON { "url": string, "pid": number, "pid_dir": string }
# Side effects: PID file at <pid_dir>/.kanban.pid, log at <pid_dir>/.kanban.log

# stop-kanban.sh
# Input: <pid_dir>
# Output (stdout): JSON { "status": "stopped" | "not_running" | "failed" }
```

## Data Models

### kanban.json (existing, read-only)
| Field | Type | Description |
|-------|------|-------------|
| topic | string | Topic identifier |
| phase | string | Current workflow phase |
| last_updated | string | ISO date |
| meetings | array | Meeting references (ignored by dashboard) |
| steps.done | StepItem[] | Completed steps |
| steps.in_progress | StepItem[] | Active steps |
| steps.backlog | StepItem[] | Pending steps |

### StepItem
| Field | Type | Description |
|-------|------|-------------|
| id | string | Step identifier |
| name | string | Display name |

### WebSocket KanbanState message
| Field | Type | Description |
|-------|------|-------------|
| type | string | Always `"kanban-state"` |
| topic | string | From kanban.json |
| phase | string | From kanban.json |
| steps | object | `{ done, in_progress, backlog }` arrays of StepItem |

## Constraints

- Server must use only Node.js built-in modules (http, fs, path, crypto) -- no npm dependencies
- Server must not write to kanban.json under any circumstance
- WebSocket push must occur within 1 second of file change detection
- `fs.watch` debounce required to avoid rapid duplicate events
- Dashboard must not trigger page reload on state update
- Idle timeout timer resets on every kanban.json change event
- PID file must be cleaned up on server exit (normal or signal)
- Start script must terminate existing server before starting new one (AC13)
- Server must handle malformed kanban.json gracefully (log error, skip push)
- WebSocket frame implementation must follow RFC 6455 (masked client frames)
- Auto-reconnect backoff: initial 1s, max 30s, factor 2x
- Dashboard layout minimum width 800px, no mobile optimization required
