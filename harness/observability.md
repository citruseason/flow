# Observability Guidelines

## Logging

### Format

All runtime logging uses structured JSON. The WebSocket server (`skills/meeting/scripts/server.cjs`) emits one JSON object per line to stdout:

```json
{"type": "server-started", "port": 52341, "host": "127.0.0.1", "url": "http://localhost:52341", "screen_dir": "/path/to/session"}
{"type": "screen-added", "file": "/path/to/file.html"}
{"type": "screen-updated", "file": "/path/to/file.html"}
{"source": "user-event", "type": "click", "choice": "a", "text": "Option A", "timestamp": 1706000101}
{"type": "server-stopped", "reason": "idle timeout"}
```

Shell scripts emit JSON for errors:

```json
{"error": "Server failed to start within 5 seconds"}
{"error": "Unknown argument: --bad-flag"}
{"status": "stopped"}
{"status": "not_running"}
```

### Levels

- **ERROR**: Unexpected failures requiring attention (e.g., WebSocket decode failure, fs.watch error)
- **WARN**: Recoverable issues or degraded behavior (not currently used -- recommended for future additions)
- **INFO**: Significant state changes and business events (server-started, screen-added, server-stopped)
- **DEBUG**: Diagnostic information for development (not currently used -- recommended for future additions)

### Conventions

- Server uses `console.log(JSON.stringify({...}))` for structured events and `console.error(...)` for parse failures
- Shell scripts use `echo '{"error": "..."}'` for error output and `echo '{"status": "..."}'` for status
- No log levels are explicitly set -- all output goes to stdout or stderr
- Session lifecycle events (started, stopped) always include a `type` field
- User interaction events always include a `source: "user-event"` field

## Error Handling

### Error Format

**JavaScript (server.cjs):**
- WebSocket protocol errors: throw Error with message, caught at connection level, client disconnected with close frame
- Parse errors: `console.error('Failed to parse WebSocket message:', e.message)` -- logged but not propagated
- File system errors: caught by fs.watch error handler, logged to stderr

**Shell scripts:**
- Errors output as JSON: `echo '{"error": "<message>"}'` followed by `exit 1`
- Non-fatal conditions: handled inline with `|| true` fallback
- Process management: graceful shutdown with SIGTERM, escalation to SIGKILL after 2 seconds

**Agent/Skill prompts:**
- Errors surface as structured output in the lint result contract (PASS/WARNING/FAIL with findings)
- Escalation pattern: retry up to N times, then escalate to human with specific context

### Error Propagation

```
Agent output errors     -> Skill reads and acts on structured findings
Server runtime errors   -> JSON to stdout/stderr, server continues running
Shell script errors     -> JSON error output + non-zero exit code
Review failures         -> Writer-reviewer loop (max 3 iterations) -> human escalation
Implementation failures -> SDD retry (max 2 attempts) -> human escalation
```

## Metrics

No metrics instrumentation detected. The project is a prompt-driven CLI plugin without a persistent runtime. Observability is achieved through:

- Structured JSON logging from the WebSocket server
- Lint skill output contracts (Status/Findings/Summary)
- Quality score computation in `harness/quality-score.md`
- Kanban state tracking in `harness/kanban.json` and topic-level kanban files

Consider adding timing metrics for agent dispatch duration if performance optimization becomes a concern.
