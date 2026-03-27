# Frontmatter Format

## Description

YAML frontmatter requirements for agent and skill files. Frontmatter is the machine-readable metadata that Claude Code uses to discover and configure agents and skills.

## Rules

### FF-1: Agent frontmatter must contain required fields

Every agent file in `agents/` must have YAML frontmatter with these fields:

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| name | Yes | string | Agent identifier, must match filename (without .md) |
| description | Yes | string | One-line description of the agent's role |
| tools | Yes | array | List of Claude Code tools the agent may use |
| model | Yes | string | LLM model to use: "opus" or "sonnet" |

**Correct example** (`agents/meeting-facilitator.md`):
```yaml
---
name: meeting-facilitator
description: Meeting facilitator dispatched by the /meeting skill. Conducts structured dialogue...
tools: ["Read", "Write", "Edit", "Bash", "Grep", "Glob"]
model: opus
---
```

**Incorrect -- missing model:**
```yaml
---
name: meeting-facilitator
description: Meeting facilitator...
tools: ["Read", "Write", "Edit", "Bash", "Grep", "Glob"]
---
```

### FF-2: Skill frontmatter must contain required fields

Every SKILL.md file must have YAML frontmatter with these fields:

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| name | Yes | string | Skill identifier, must match directory name |
| description | Yes | string | One-line description of what the skill does |

**Correct example** (`skills/meeting/SKILL.md`):
```yaml
---
name: meeting
description: "Conduct structured dialogue to define requirements via Meeting Log -> CPS -> PRD."
---
```

### FF-3: Frontmatter delimiter must be exactly `---`

Frontmatter starts and ends with exactly three dashes on their own line. No spaces, no extra dashes.

### FF-4: Agent name must match filename

The `name` field in agent frontmatter must exactly match the filename (minus `.md` extension).

| File | Expected name |
|------|---------------|
| `agents/harness-initializer.md` | `harness-initializer` |
| `agents/meeting-facilitator.md` | `meeting-facilitator` |
| `agents/design-doc-writer.md` | `design-doc-writer` |

### FF-5: Skill name must match directory name

The `name` field in skill frontmatter must exactly match the parent directory name.

| Directory | Expected name |
|-----------|---------------|
| `skills/harness-init/` | `harness-init` |
| `skills/meeting/` | `meeting` |
| `skills/design-doc/` | `design-doc` |

### FF-6: Tools array must contain valid Claude Code tools

Valid tool names: `Read`, `Write`, `Edit`, `Bash`, `Grep`, `Glob`

Reviewer agents should use minimal tool sets:
- Read-only reviewers: `["Read", "Grep", "Glob"]`
- Reviewers that update docs: `["Read", "Write", "Edit", "Grep", "Glob"]`
