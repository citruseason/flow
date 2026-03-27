# Test Cases: Realtime Kanban

## Unit Tests

| ID | Scenario | Input | Expected Output |
|----|----------|-------|-----------------|
| U-001 | Parse --kanban argument | `["--kanban", "/tmp/kanban.json"]` | kanbanFile = "/tmp/kanban.json" |
| U-002 | Parse --port argument | `["--port", "3456"]` | port = 3456 |
| U-003 | Default port is 0 (auto) | `["--kanban", "/tmp/k.json"]` | port = 0 |
| U-004 | WebSocket accept key computation | Client key "dGhlIHNhbXBsZSBub25jZQ==" | "s3pPLMBiTxaQ9kYGzzhZRbK+xOo=" |
| U-005 | Encode WebSocket text frame | Opcode TEXT, payload "hello" | Valid RFC 6455 frame buffer |
| U-006 | Decode masked WebSocket frame | Valid masked frame with payload "test" | { opcode: TEXT, payload: "test" } |
| U-007 | Construct KanbanState message | kanban.json with 2 done, 1 in_progress, 3 backlog | JSON with type "kanban-state", correct step counts |
| U-008 | Handle malformed kanban.json | Invalid JSON string | No broadcast, error logged |
| U-009 | Handle missing kanban.json | Non-existent file path | Error logged, server does not crash |
| U-010 | Debounce rapid file changes | 5 changes within 100ms | Single broadcast emitted |
| U-011 | Idle timeout calculation | No file change for 30 min | Server shutdown triggered |
| U-012 | Idle timeout reset on change | File change at 29 min | Timer resets, no shutdown |
| U-013 | Health endpoint response | GET /health | { "status": "ok", "uptime": <number> } |

## Integration Tests

| ID | Scenario | Steps | Expected Result |
|----|----------|-------|-----------------|
| I-001 | Server start and HTTP serve | 1. Start server with --kanban <path> 2. GET / | 200 response with HTML containing "kanban" |
| I-002 | WebSocket handshake | 1. Start server 2. Send upgrade request to /ws | 101 Switching Protocols with valid Sec-WebSocket-Accept |
| I-003 | Initial state on connect (AC11) | 1. Start server with valid kanban.json 2. Connect WebSocket | Receive KanbanState message with current file content |
| I-004 | File change triggers push (AC1) | 1. Start server 2. Connect WebSocket 3. Modify kanban.json | Receive updated KanbanState within 1 second |
| I-005 | Multiple clients receive broadcast | 1. Start server 2. Connect 3 WebSocket clients 3. Modify kanban.json | All 3 clients receive the same KanbanState |
| I-006 | Read-only enforcement (AC9) | 1. Start server 2. Modify kanban.json multiple times 3. Check file content | kanban.json content matches only external writes, no server modifications |
| I-007 | Idle timeout shutdown (AC12) | 1. Start server with short idle timeout (e.g., 2s) 2. Wait for timeout | Server process exits |
| I-008 | Start script outputs JSON (AC7) | 1. Run start-kanban.sh --kanban <path> | stdout contains JSON with "url", "pid", "pid_dir" |
| I-009 | Stop script terminates (AC7) | 1. Start server via script 2. Run stop-kanban.sh <pid_dir> | Server process no longer running, PID file removed |
| I-010 | Restart kills existing (AC13) | 1. Start server 2. Start server again with same PID dir | First process killed, new process running, new PID in file |
| I-011 | Graceful malformed JSON handling | 1. Start server 2. Connect client 3. Write invalid JSON to kanban.json | No message sent, client stays connected, no crash |
| I-012 | Zero-dependency check (AC10) | 1. Parse kanban-server.cjs require() calls | Only http, fs, path, crypto modules used |

## E2E Tests

| ID | Scenario | Action | Expected Outcome |
|----|----------|--------|------------------|
| E-001 | Full board render (AC2) | Start server, open dashboard in browser with sample kanban.json | 3 columns visible: Backlog, In Progress, Done with cards in correct columns |
| E-002 | Real-time card movement (AC3) | Move step from backlog to in_progress in kanban.json | Card moves from Backlog column to In Progress column without page reload |
| E-003 | In-progress highlight (AC4) | Place a step in in_progress | Card in In Progress column has visual highlight (distinct border/animation) |
| E-004 | Header displays topic and phase (AC5) | Open dashboard with kanban.json containing topic "realtime-kanban", phase "implement" | Header shows "realtime-kanban" and "implement" |
| E-005 | Connection indicator green (AC6) | Open dashboard, WebSocket connects | Green indicator dot visible |
| E-006 | Connection indicator red (AC6) | Open dashboard, stop server | Indicator changes to red |
| E-007 | Connection indicator yellow + reconnect (AC6) | Open dashboard, stop server, restart server | Indicator turns yellow during reconnect, then green after reconnection |
| E-008 | Auto-reconnect with backoff (AC6) | Stop server, observe client retry timing | Reconnect attempts at ~1s, ~2s, ~4s intervals (exponential backoff) |
| E-009 | Lifecycle via scripts (AC7) | Run start-kanban.sh, verify dashboard loads, run stop-kanban.sh | Dashboard accessible after start, server stopped after stop |
| E-010 | Step completion flow | Simulate full workflow: all steps in backlog -> move one to in_progress -> move to done | Cards flow left to right across columns in real time |
| E-011 | Dashboard minimum width | Open dashboard in 800px wide viewport | Layout renders correctly with 3 visible columns |
| E-012 | Implement auto-start (AC8) | Follow /implement SKILL.md instructions for a topic | Kanban server starts, URL is displayed |
| E-013 | Lint auto-stop (AC8) | Follow /lint SKILL.md completion flow | Kanban server process is terminated |
