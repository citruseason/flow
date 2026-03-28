# Blueprint: Hooks Integration

## Components

- **hooks/hooks.json** -- Hook registry declaring all 4 hook events and their script bindings
- **hooks/scripts/post-merge.sh** -- PostToolUse handler: extract topic from merge/pull, check lint status, output core-update trigger
- **hooks/scripts/session-start.sh** -- SessionStart handler: detect source type, collect context, output summary
- **hooks/scripts/stop-summary.sh** -- Stop handler: read kanban, output one-line progress summary
- **hooks/scripts/subagent-kanban.sh** -- SubagentStop handler: read stdin, validate phase, update topic kanban.json
- **harness/kanban.json** -- Root kanban (read by all scripts to find active topics)
- **harness/topics/<topic>/kanban.json** -- Topic kanban (read/written by subagent-kanban.sh, read by others)
- **skills/implement/SKILL.md** -- Implement skill (kanban step-move logic to be removed)

## Connections

```
Claude Code hook system --> hooks/hooks.json --> dispatches scripts

PostToolUse (git merge/pull)
  hooks/scripts/post-merge.sh --> reads harness/kanban.json (find topic)
  hooks/scripts/post-merge.sh --> reads harness/topics/<topic>/kanban.json (check lint done)
  hooks/scripts/post-merge.sh --> stdout --> Claude context (triggers /core-update)

SessionStart (resume/compact)
  hooks/scripts/session-start.sh --> reads harness/kanban.json (active topics)
  hooks/scripts/session-start.sh --> reads harness/topics/<topic>/kanban.json (step details)
  hooks/scripts/session-start.sh --> reads harness/*.md (CORE doc listing)
  hooks/scripts/session-start.sh --> git log/diff (recent changes)
  hooks/scripts/session-start.sh --> stdout --> Claude context

Stop
  hooks/scripts/stop-summary.sh --> reads harness/kanban.json (in_progress topics)
  hooks/scripts/stop-summary.sh --> reads harness/topics/<topic>/kanban.json (step details)
  hooks/scripts/stop-summary.sh --> stdout --> Claude context

SubagentStop
  hooks/scripts/subagent-kanban.sh --> reads stdin (agent_name, exit_reason)
  hooks/scripts/subagent-kanban.sh --> reads harness/kanban.json (find implement-phase topic)
  hooks/scripts/subagent-kanban.sh --> writes harness/topics/<topic>/kanban.json (step transitions)
```

## External Boundaries

- **Claude Code hook system** -- Invokes scripts based on hooks.json declarations; provides stdin JSON and captures stdout
- **Git** -- Source of merge/pull events (PostToolUse trigger); provides `git log`/`git diff` data (SessionStart)
- **Filesystem** -- All kanban.json files and CORE documents are read/written directly; no database or API
