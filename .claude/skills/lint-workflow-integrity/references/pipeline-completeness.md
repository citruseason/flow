# Pipeline Completeness

## Description

The Flow workflow is a sequential pipeline. Every step must have both a skill (orchestration) and at least one agent (execution). Missing pieces break the chain.

## Rules

### PC-1: Pipeline steps must have skills and agents

The core pipeline and its skill-to-agent mapping:

| Pipeline Step | Skill | Agent(s) |
|---------------|-------|----------|
| harness-init | `skills/harness-init/SKILL.md` | `agents/harness-initializer.md` |
| meeting | `skills/meeting/SKILL.md` | `agents/meeting-facilitator.md`, `agents/meeting-reviewer.md` |
| design-doc | `skills/design-doc/SKILL.md` | `agents/design-doc-writer.md`, `agents/design-doc-reviewer.md` |
| implement | `skills/implement/SKILL.md` | (dispatches SDD workers via `skills/sdd/`) |
| lint | `skills/lint/SKILL.md` | `agents/lint-reviewer.md`, `agents/doc-gardener.md` |

**Detection:**
1. For each row, verify the skill SKILL.md exists
2. For each row, verify all listed agent files exist
3. Verify the skill's body references the agents it dispatches

### PC-2: Supporting skills must exist

Skills referenced by the core pipeline:

| Supporting Skill | Referenced By | Purpose |
|-----------------|---------------|---------|
| `skills/sdd/SKILL.md` | implement | Subagent dispatch pattern |
| `skills/tdd/SKILL.md` | implement | TDD methodology |
| `skills/lint-manage/SKILL.md` | lint | Lint skill evolution |
| `skills/lint-validate/SKILL.md` | lint | Lint skill health check |
| `skills/doc-garden/SKILL.md` | lint | Documentation freshness |

### PC-3: Standalone skills must be self-sufficient

Skills that can be invoked independently:

| Skill | Agents Used |
|-------|-------------|
| `skills/using-worktree/SKILL.md` | None (inline logic) |
| `skills/update-plugin/SKILL.md` | None (inline logic) |
| `skills/doc-garden/SKILL.md` | `agents/doc-gardener.md` |
| `skills/lint-integrate/SKILL.md` | None (inline logic) |
| `skills/core-update/SKILL.md` | `agents/harness-initializer.md` (CORE Update Mode) |

Skills with no agent dependency are acceptable -- they contain inline orchestration logic.

### PC-4: Agent-to-plugin.json registration

Every agent file in `agents/` must appear in `.claude-plugin/plugin.json` agents array. The path format is `./agents/<name>.md`.

**Current expected entries (7 agents):**
```json
[
  "./agents/harness-initializer.md",
  "./agents/meeting-facilitator.md",
  "./agents/meeting-reviewer.md",
  "./agents/design-doc-writer.md",
  "./agents/design-doc-reviewer.md",
  "./agents/doc-gardener.md",
  "./agents/lint-reviewer.md"
]
```
