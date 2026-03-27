# Security

## Authentication & Authorization

No auth patterns detected. The WebSocket server (`skills/meeting/scripts/server.cjs`) binds to `127.0.0.1` by default, restricting access to the local machine. No authentication layer exists on the HTTP/WebSocket endpoints.

- Server is intended for local development use only
- Binding to `0.0.0.0` (via `--host` flag) exposes the server without authentication -- use only in trusted environments

## Secrets Management

- No credentials or API keys are managed by the plugin
- Environment variables used only for server configuration (`SPEC_PORT`, `SPEC_HOST`, `SPEC_DIR`, `SPEC_OWNER_PID`) -- none contain secrets
- `.gitignore` excludes `.claude/` (which may contain local settings)
- `.flow/` directory (runtime session data) is gitignored

## Input Validation

- **WebSocket frames:** Client frames are validated per RFC 6455 -- unmasked frames are rejected with an error
- **WebSocket messages:** JSON parse failures are caught and logged, not propagated
- **HTTP paths:** File serving is restricted to `SCREEN_DIR` using `path.basename()` to prevent directory traversal
- **Shell arguments:** Unknown arguments produce JSON error output and `exit 1`

## Dependencies

- **Zero runtime dependencies:** The WebSocket server uses only Node.js built-ins (`crypto`, `http`, `fs`, `path`)
- **No package.json / no node_modules:** No third-party packages to audit
- **No lock files needed:** No dependency tree to lock

## Sensitive Data

- No PII is collected or logged
- User interaction events (clicks, selections) are logged with choice identifiers only
- Session files are stored in `/tmp` (ephemeral) or project-local `.flow/` (gitignored)
- `.events` files contain user interaction data and are cleared on each new screen

## Process Isolation

- Server runs as a background process with `nohup` and `disown`
- Owner process monitoring: server exits if the spawning Claude Code session dies
- Idle timeout: server auto-shuts down after 30 minutes of inactivity
- Graceful shutdown with SIGTERM, escalation to SIGKILL after 2 seconds

## Additional Rules

- **Path traversal prevention:** HTTP file serving uses `path.basename()` to strip directory components from requested filenames
- **Ephemeral session cleanup:** `/tmp` session directories are removed on server stop; persistent `.flow/` directories are preserved for review
- **No hardcoded secrets:** No API keys, tokens, or credentials anywhere in the codebase
- **Plugin manifest integrity:** `plugin.json` and `marketplace.json` versions must match -- prevents deployment of mismatched plugin states
