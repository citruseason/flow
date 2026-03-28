# Architecture: Hooks Integration

## Stack

- **Bash** -- All hook scripts (consistent with existing `skills/meeting/scripts/` pattern)
- **Node.js** -- Inline JSON parsing via `node -e` (replaces jq dependency)
- **JSON** -- hooks.json registry, kanban.json data files
- **Git CLI** -- Branch name extraction, recent change detection

## Hierarchy

```
hooks/
├── hooks.json                  # Hook registry (4 events, 5 entries)
└── scripts/
    ├── post-merge.sh           # PostToolUse: merge detection + core-update trigger
    ├── session-start.sh        # SessionStart: context reinjection
    ├── stop-summary.sh         # Stop: kanban summary
    └── subagent-kanban.sh      # SubagentStop: kanban auto-update

harness/
├── kanban.json                 # Root kanban (read by all scripts)
└── topics/<topic>/
    └── kanban.json             # Topic kanban (read/write by subagent-kanban.sh)

skills/
└── implement/
    └── SKILL.md                # Modified: kanban step-move logic removed
```

## Patterns

- **Model-behavior trigger** -- stdout messages prompt Claude to invoke skills; no programmatic command execution
- **Non-blocking error handling** -- All scripts trap errors and exit 0; errors logged to stderr only
- **Stdin JSON protocol** -- Scripts read structured input from stdin using `node -e` one-liners for parsing
- **Permission rule syntax** -- PostToolUse `if` field uses Claude Code's native permission rule matching (`Bash(git merge *)`)
- **Idempotent state transitions** -- SubagentStop kanban updates are safe to re-run (moving already-done steps is a no-op)
- **Single-responsibility scripts** -- Each hook event maps to exactly one script with one job

## Constraints

- Scripts must not depend on jq or any external tool beyond bash, node, and git
- All scripts exit 0 unconditionally -- never block the main Claude Code workflow
- SubagentStop writes only to topic kanban.json, never to root kanban.json
- PostToolUse requires two separate hook entries (git merge, git pull) due to `if` field matching
- SessionStart script must handle all three source types (startup, resume, compact) in a single script
- stdout is the only channel for injecting context into Claude; stderr is for debug/error logging only
- Hook scripts must not invoke Claude Code skills directly -- they output messages that influence model behavior
