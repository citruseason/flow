# Agent-Skill Separation

## Description

The Flow plugin separates orchestration (skills) from execution (agents). This separation is fundamental to how Claude Code dispatches work.

## Rules

### AS-1: Agents must not contain orchestration logic

Agents are dispatched as subagents with fresh context. They must not:
- Invoke slash commands (e.g., `/lint`, `/meeting`)
- Manage confirmation gates or user approval flows
- Update kanban files directly (the dispatching skill handles this)
- Execute git operations (commit, add, push)
- Reference `AskUserQuestion` or other user interaction primitives

**Correct example** (`agents/design-doc-writer.md`):
```
The agent writes design documents and presents them for approval.
The dispatching skill (skills/design-doc/SKILL.md) handles user gates and kanban updates.
```

**Incorrect example** (hypothetical agent violation):
```
After writing the spec, commit it:
git add harness/topics/<topic>/spec.md
git commit -m "feat: add spec"
```

### AS-2: Skills must not contain execution logic

Skills orchestrate by dispatching agents and managing flow. They must not contain:
- Detailed document templates or generation instructions (those belong in agents)
- Review criteria checklists (those belong in reviewer agents)
- Code analysis logic (those belong in the harness-initializer agent)

**Exception:** The `/lint` skill contains inline `lint-requirements` logic. This is documented and intentional -- it is the only exception to this rule.

**Correct example** (`skills/meeting/SKILL.md`):
```
3. **Dispatch meeting-facilitator** -- conduct structured dialogue with the user
```

**Incorrect example** (hypothetical skill violation):
```
3. Conduct the meeting by asking these questions in order:
   - What is the current state of the project?
   - What problem are you trying to solve?
   [detailed question list that belongs in the agent]
```

### AS-3: Agent tools must match their role

Writer agents need full tool access: `["Read", "Write", "Edit", "Bash", "Grep", "Glob"]`
Reviewer agents need read-only access: `["Read", "Grep", "Glob"]`

Exceptions:
- `doc-gardener` (reviewer role but updates docs): `["Read", "Write", "Edit", "Grep", "Glob"]`
- `lint-reviewer` (reviewer role but writes quality scores): `["Read", "Write", "Edit", "Bash", "Grep", "Glob"]`
