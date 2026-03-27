# Cross-Reference Integrity

## Description

Skills and agents reference each other by slash command names and file paths. All references must resolve to existing files to prevent dead ends in the workflow.

## Rules

### CR-1: Slash command references must resolve

When a skill or agent mentions a slash command (e.g., `/design-doc`, `/lint`), the corresponding skill directory must exist with a valid SKILL.md.

**Expected slash command to skill mapping:**

| Slash Command | Skill Directory |
|---------------|-----------------|
| `/harness-init` | `skills/harness-init/` |
| `/meeting` | `skills/meeting/` |
| `/design-doc` | `skills/design-doc/` |
| `/implement` | `skills/implement/` |
| `/lint` | `skills/lint/` |
| `/lint-manage` | `skills/lint-manage/` |
| `/lint-integrate` | `skills/lint-integrate/` |
| `/lint-validate` | `skills/lint-validate/` |
| `/doc-garden` | `skills/doc-garden/` |
| `/core-update` | `skills/core-update/` |
| `/sdd` | `skills/sdd/` |
| `/tdd` | `skills/tdd/` |
| `/using-worktree` | `skills/using-worktree/` |
| `/update-plugin` | `skills/update-plugin/` |

**Detection:**
```bash
# Find all slash command references
grep -rn '/[a-z][a-z-]*' skills/ agents/ --include='*.md' | grep -v 'http\|/tmp\|/path\|/Users'
```

### CR-2: Agent file references must resolve

When a skill mentions dispatching an agent by name, the agent file must exist in `agents/`.

**Skill-to-agent dispatch references:**

| Skill | Agents Dispatched |
|-------|-------------------|
| `skills/harness-init/SKILL.md` | harness-initializer |
| `skills/meeting/SKILL.md` | meeting-facilitator, meeting-reviewer |
| `skills/design-doc/SKILL.md` | design-doc-writer, design-doc-reviewer |
| `skills/lint/SKILL.md` | lint-reviewer, doc-gardener |
| `skills/doc-garden/SKILL.md` | doc-gardener |

### CR-3: Reference file paths must resolve

When an agent or skill references a file in `references/` (e.g., `skills/sdd/references/worker-prompt.md`), that file must exist.

**Known reference paths:**
- `skills/sdd/references/worker-prompt.md`
- `skills/sdd/references/compliance-reviewer-prompt.md`
- `skills/sdd/references/quality-reviewer-prompt.md`
- `skills/tdd/references/mock-patterns.md`
- `skills/tdd/references/testing-mistakes.md`

### CR-4: Script file references must resolve

When skills or visual-companion.md reference scripts, those scripts must exist.

**Known script references:**
- `skills/meeting/scripts/start-server.sh`
- `skills/meeting/scripts/stop-server.sh`
- `skills/meeting/scripts/server.cjs`
- `skills/meeting/scripts/frame-template.html`
- `skills/meeting/scripts/helper.js`

### CR-5: Pipeline "suggest next step" references

Skills that suggest a next step must reference a valid skill:

| Skill | Suggests Next |
|-------|---------------|
| harness-init | `/meeting` |
| meeting | `/design-doc` |
| design-doc | `/implement` |
| implement | `/lint` (auto-invoked) |
