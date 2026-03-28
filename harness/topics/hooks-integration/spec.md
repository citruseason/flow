# Spec: Hooks Integration

## Features

### PostToolUse Hook -- Merge Detection (R1)
- Detect `git merge feature/<topic>` via PostToolUse hook with Bash matcher
- Detect `git pull` (remote merge) via separate PostToolUse hook entry
- Extract topic name from branch name (`feature/<topic>` pattern)
- Check topic's kanban.json for lint step in `done`
- Output stdout message to trigger `/core-update <topic>` (model-behavior trigger, not programmatic)
- Skip trigger when lint is not done

### SessionStart Hook -- Context Reinjection (R2)
- Fire on every session start (empty matcher)
- Distinguish `resume`/`compact` vs `startup` via stdin `source` field
- On `startup`: output existing welcome message only
- On `resume`/`compact`: collect and output context summary
  - Active in_progress topics from `harness/kanban.json`
  - Per-topic kanban status (current step, backlog items)
  - CORE document listing (`harness/*.md`)
  - Last modified files (`git diff --name-only HEAD~1`)
  - Last commit message (`git log -1 --oneline`)
- On no active topics: output harness summary only
- Output is concise summary, not full file contents

### Stop Hook -- Kanban Summary (R3)
- Fire on autonomous execution stop
- Check `harness/kanban.json` for in_progress topics
- Output one-line summary: `[Flow] <topic>: <step> (<done>/<total> done)`
- Silent when no in_progress topics
- Guard against infinite loop via `stop_hook_active` flag

### SubagentStop Hook -- Kanban Auto-Update (R4)
- Fire on every subagent stop (empty matcher)
- Read `agent_name` and `exit_reason` from stdin JSON
- Find topic in implement phase from `harness/kanban.json`
- Move topic's kanban: `in_progress` -> `done`, next `backlog` -> `in_progress`
- Update `last_updated` field
- Skip update on agent failure (`exit_reason` indicates error)
- Only operate during implement phase; no-op for meeting/design-doc/lint phases

### Hook Script Infrastructure (R5)
- All scripts in `hooks/scripts/` directory
- Bash scripts, no jq dependency (use Node.js inline JSON or grep/sed)
- Executable permission (+x) on all scripts
- Non-blocking errors (always exit 0, errors to stderr)

### Skill Kanban Cleanup (R6)
- Remove kanban step movement logic from `skills/implement/SKILL.md` only
- Preserve kanban logic in meeting, design-doc, lint, and all other skills

## Interfaces

### hooks/hooks.json Structure

```
hooks.json.hooks.PostToolUse[]  -- array of hook entries
  .matcher: string              -- "Bash"
  .if: string                   -- permission rule syntax, e.g. "Bash(git merge *)"
  .hooks[].type: "command"
  .hooks[].command: string      -- path to script
  .hooks[].timeout: number      -- ms

hooks.json.hooks.SessionStart[] -- array of hook entries
  .matcher: string              -- "" (all sessions)
  .hooks[].type: "command"
  .hooks[].command: string

hooks.json.hooks.Stop[]         -- array of hook entries
  .hooks[].type: "command"
  .hooks[].command: string

hooks.json.hooks.SubagentStop[] -- array of hook entries
  .matcher: string              -- "" (all agents)
  .hooks[].type: "command"
  .hooks[].command: string
```

### Script stdin (SubagentStop)

```
{ "agent_name": string, "exit_reason": string }
```

### Script stdin (SessionStart)

```
{ "source": "startup" | "resume" | "compact", ... }
```

### Script stdout Contracts

- **post-merge.sh**: `[Flow] Topic <topic> merged. Running /core-update <topic> automatically.`
- **session-start.sh**: Multi-line context summary (CORE docs, kanban state, last commit)
- **stop-summary.sh**: `[Flow] <topic>: <step> (<done>/<total> done)` or empty
- **subagent-kanban.sh**: Silent (writes to kanban.json file directly)

## Data Models

### harness/kanban.json (Root)

| Field | Type | Description |
|-------|------|-------------|
| topics | object | Map of topic name to topic entry |
| topics[name].phase | string | "meeting" / "design-doc" / "implement" / "lint" / "done" |
| topics[name].last_updated | string | ISO date (YYYY-MM-DD) |

### harness/topics/<topic>/kanban.json (Topic)

| Field | Type | Description |
|-------|------|-------------|
| topic | string | Topic name |
| phase | string | Current phase |
| last_updated | string | ISO date |
| steps.done | array | Completed step objects |
| steps.in_progress | array | Active step objects |
| steps.backlog | array | Pending step objects |

### Step Object

| Field | Type | Description |
|-------|------|-------------|
| id | string | Step identifier (e.g. "impl-phase-1", "lint") |
| name | string | Human-readable name |

## Constraints

- PostToolUse `if` field uses Claude Code permission rule syntax, not regex
- `git merge` and `git pull` require separate hook entries (different `if` values)
- Scripts must not depend on jq -- use Node.js `-e` for JSON parsing or shell string manipulation
- All scripts exit 0 regardless of internal errors; errors go to stderr
- SubagentStop only updates kanban for topics where `harness/kanban.json` shows `phase: "implement"`
- Stop hook checks `stop_hook_active` env var or marker file to prevent recursion
- SessionStart script distinguishes session source from stdin JSON, not from arguments
- stdout from hook scripts is injected into Claude's context; stderr is not
- Only `skills/implement/SKILL.md` kanban logic is removed; all other skills retain theirs
- Branch pattern assumption: `feature/<topic>` -- no nested paths
