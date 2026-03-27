# Product

## Identity

- **Name:** Flow
- **Version:** 0.0.11
- **Description:** Complete development workflow plugin for Claude Code -- from harness setup through meeting-driven requirements, design documentation, autonomous implementation, and lint verification.
- **Type:** Claude Code plugin (prompt-driven CLI workflow tool)
- **License:** MIT

## Stack

- **Languages:** Markdown (primary -- agent/skill prompts), JavaScript-CJS (server, helper), Bash (shell scripts), JSON (config, kanban)
- **Frameworks:** None (zero-dependency Node.js WebSocket server)
- **Key Libraries:** Node.js built-ins only (`crypto`, `http`, `fs`, `path`)
- **Build Tools:** None (no compilation or bundling)
- **Test Frameworks:** None currently (recommended: `node:test` built-in runner)

## Architecture

- **Pattern:** Layered plugin -- Orchestration (skills/) -> Execution (agents/) -> Infrastructure (scripts/)
- **Module Organization:** By role (agents/, skills/, hooks/, harness/)
- **API Style:** Slash-command invocation with structured document I/O

### Three-Layer Model

```
skills/       Orchestration layer -- dispatch agents, manage confirmation gates, update kanban, handle git
agents/       Execution layer -- analyze, generate, review documents
scripts/      Infrastructure layer -- WebSocket server, process management
```

### Agent-Skill Separation

- Agents execute work (analysis, writing, reviewing). Skills orchestrate (dispatch agents, manage confirmation gates, update kanban, handle git commits).
- An agent must never perform orchestration tasks; a skill must never contain execution logic.

### Dependency Direction

- Skills may reference other skills by slash command.
- Agents must not reference other agents.
- Scripts must not reference agents or skills.
- The dependency flow is: skills -> agents -> references, never reverse.

### Self-Contained Skills

- Every skill directory must contain a SKILL.md with valid YAML frontmatter (`name`, `description`).
- Optional `references/` directory for supporting documents.
- No skill may depend on files outside its own directory or the `harness/`.

### Model Assignment

- **Writer agents use Opus:** harness-initializer, meeting-facilitator, design-doc-writer -- all agents that create or generate content must use `model: opus`.
- **Reviewer agents use Sonnet:** meeting-reviewer, design-doc-reviewer, doc-gardener, lint-reviewer -- all agents that validate or review must use `model: sonnet`.

### Agents (7)

| Agent | Model | Role |
|-------|-------|------|
| harness-initializer | Opus | Codebase analysis, harness/ scaffolding, lint-* skill generation |
| meeting-facilitator | Opus | Meeting dialogue, Meeting Log/CPS/PRD generation |
| meeting-reviewer | Sonnet | CPS/PRD validation |
| design-doc-writer | Opus | PRD-based design document creation (5 docs) |
| design-doc-reviewer | Sonnet | Cross-document consistency, PRD coverage validation |
| doc-gardener | Sonnet | Documentation/rule freshness verification |
| lint-reviewer | Sonnet | lint-* skill aggregation, quality score computation |

### Skills (14)

| Skill | Path | Purpose |
|-------|------|---------|
| harness-init | skills/harness-init/ | Codebase analysis and harness knowledge base scaffolding |
| meeting | skills/meeting/ | Meeting-driven requirements with visual companion |
| design-doc | skills/design-doc/ | PRD to design documents (Spec, Blueprint, Architecture, Code-Dev-Plan) |
| implement | skills/implement/ | Autonomous execution using SDD + TDD with kanban tracking |
| lint | skills/lint/ | Requirements verification + project lint-* skill invocation |
| lint-manage | skills/lint-manage/ | Lint skill evolution (create/update rules based on code changes) |
| lint-integrate | skills/lint-integrate/ | External skill integration into lint workflow |
| lint-validate | skills/lint-validate/ | Lint skill health validation (structure, freshness, detection) |
| core-update | skills/core-update/ | Post-merge CORE document update with realized decisions |
| doc-garden | skills/doc-garden/ | Harness documentation freshness validation |
| sdd | skills/sdd/ | Subagent-driven development pattern (dispatch + review gates) |
| tdd | skills/tdd/ | TDD methodology (RED -> GREEN -> REFACTOR) |
| using-worktree | skills/using-worktree/ | Worktree setup + working context for isolated development |
| update-plugin | skills/update-plugin/ | Manual plugin update |

## Pipeline

### Sequential Workflow

```
/harness-init -> /meeting -> /design-doc -> /implement -> /lint
```

- No step may be skipped. Each step's outputs are inputs to the next.
- **Autonomous execution boundary:** From `/implement` start through `/lint` completion, execution proceeds without user intervention. Only escalate on severe mismatches or unresolvable blockers.
- **User gates exist at meeting and design-doc:** Users must approve CPS, PRD, and the final design document set before proceeding. These gates must not be bypassed.

### Document Flow

```
harness/
├── PRODUCT.md, SECURITY.md, kanban.json, quality-score.md, tech-debt.md
└── topics/<topic>/
    ├── meetings/, cps.md, prd.md
    ├── spec.md, blueprint.md, architecture.md, code-dev-plan.md
    ├── history/                        <- version tracking (max 2)
    └── kanban.json                     <- topic progress tracking
```

### Document History

- **FIFO rotation with max 2 versions:** When archiving documents to `history/`, use consistent FIFO rotation: v1 = most recent prior version, v2 = older version. Maximum 2 archived versions per document.

## Conventions

### Naming

- **Files:** kebab-case for all files (`meeting-facilitator.md`, `start-server.sh`, `server.cjs`)
- **Directories:** kebab-case (`harness-init/`, `lint-architecture/`, `design-doc/`)
- **Agent/Skill names:** kebab-case in YAML frontmatter (`name: meeting-facilitator`)
- **JavaScript functions:** camelCase (`computeAcceptKey`, `encodeFrame`, `handleRequest`)
- **JavaScript constants (module-level):** UPPER_SNAKE_CASE (`OPCODES`, `WS_MAGIC`, `IDLE_TIMEOUT_MS`, `MIME_TYPES`)
- **Shell variables:** UPPER_SNAKE_CASE (`SCREEN_DIR`, `PID_FILE`, `SERVER_PID`)

### Formatting

- **Indentation:** 2 spaces (JavaScript, JSON, YAML, shell)
- **Semicolons:** Required in JavaScript
- **Quotes:** Single quotes in JavaScript, double quotes in JSON
- **Trailing commas:** Used in JavaScript objects/arrays
- **Line length:** No hard limit, but aim for readability

### Imports / Exports

- **JavaScript:** CommonJS (`require` / `module.exports`). No ES modules.
- **Import order:** Node.js built-ins first, then local modules.

### Error Handling

- **JavaScript:** try/catch at connection level, errors logged via `console.error()`, not propagated
- **Shell:** JSON error output (`echo '{"error": "..."}'`) followed by `exit 1`
- **Agents/Skills:** Structured output in lint result contract (PASS/WARNING/FAIL with findings)
- **Escalation:** Retry up to N times, then escalate to human with specific context

### Typing

- Not applicable (no TypeScript, no type annotations)

### Comments

- **JavaScript:** Inline `//` comments for section headers and non-obvious logic
- **Shell:** `#` comments for usage docs, argument descriptions
- **Markdown prompts:** Structured with `##` sections, code blocks for examples, tables for data

### Git

- **Commit format:** Conventional commits (`feat:`, `fix:`, `chore:`, `docs:`)
- **Branch naming:** `feature/<topic>` for topic branches
- **Version sync:** `plugin.json` and `marketplace.json` versions must match at all times. Both files must be updated together.
- **Patch-only versioning:** Until 1.0.0, only increment the patch version (0.0.1 -> 0.0.2 -> ...).

### Output Language

- All generated documents follow the language specified in the project's CLAUDE.md. The language is set during `/harness-init`. If no language is specified, default to English.

## Observability

### Logging Format

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

### Log Levels

- **ERROR:** Unexpected failures requiring attention (e.g., WebSocket decode failure, fs.watch error)
- **WARN:** Recoverable issues or degraded behavior (not currently used -- recommended for future additions)
- **INFO:** Significant state changes and business events (server-started, screen-added, server-stopped)
- **DEBUG:** Diagnostic information for development (not currently used -- recommended for future additions)

### Logging Conventions

- Server uses `console.log(JSON.stringify({...}))` for structured events and `console.error(...)` for parse failures
- Shell scripts use `echo '{"error": "..."}'` for error output and `echo '{"status": "..."}'` for status
- No log levels are explicitly set -- all output goes to stdout or stderr
- Session lifecycle events (started, stopped) always include a `type` field
- User interaction events always include a `source: "user-event"` field

### Error Propagation

```
Agent output errors     -> Skill reads and acts on structured findings
Server runtime errors   -> JSON to stdout/stderr, server continues running
Shell script errors     -> JSON error output + non-zero exit code
Review failures         -> Writer-reviewer loop (max 3 iterations) -> human escalation
Implementation failures -> SDD retry (max 2 attempts) -> human escalation
```

### Metrics

No metrics instrumentation. The project is a prompt-driven CLI plugin without a persistent runtime. Observability is achieved through:

- Structured JSON logging from the WebSocket server
- Lint skill output contracts (Status/Findings/Summary)
- Quality score computation in `harness/quality-score.md`
- Kanban state tracking in `harness/kanban.json` and topic-level kanban files
