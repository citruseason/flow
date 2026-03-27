# Dependency Direction

## Description

Dependencies in the Flow plugin flow in one direction: Skills -> Agents -> References. Infrastructure (scripts) sits outside this chain and must not reference the prompt layer.

## Rules

### DD-1: Skills may reference other skills by slash command

Skills can suggest or invoke other skills via their slash command name. This is the intended way to chain workflow steps.

**Correct patterns:**
```markdown
# In skills/meeting/SKILL.md
11. **Suggest next step** -- suggest `/design-doc <topic>`

# In skills/implement/SKILL.md
2. Invoke `/lint <topic>` (autonomous, no user interaction)
```

### DD-2: Skills dispatch agents but agents must not dispatch agents

Skills name the agents they dispatch. Agents must not name or dispatch other agents -- that is the skill's job.

**Correct pattern** (`skills/design-doc/SKILL.md`):
```markdown
### 4. Dispatch design-doc-writer Agent
### 5. Dispatch design-doc-reviewer Agent
```

**Incorrect pattern** (hypothetical agent violation):
```markdown
# In agents/design-doc-writer.md
After writing all documents, dispatch design-doc-reviewer to validate them.
```

### DD-3: Agents may reference skill reference files

Agents can read reference files from skill directories (e.g., `skills/sdd/references/worker-prompt.md`). This is how agents access prompt templates and configuration.

**Correct pattern** (`skills/implement/SKILL.md`):
```markdown
1. **Read prompt templates** from `skills/sdd/references/`
```

### DD-4: Scripts must not reference agents or skills

Infrastructure scripts (`skills/meeting/scripts/`) are generic utilities. They must not contain agent names, skill names, or slash commands.

**Files to check:**
- `skills/meeting/scripts/server.cjs`
- `skills/meeting/scripts/start-server.sh`
- `skills/meeting/scripts/stop-server.sh`
- `skills/meeting/scripts/helper.js`
- `skills/meeting/scripts/frame-template.html`

### DD-5: No circular dependencies between skills

If skill A references skill B via slash command, skill B must not reference skill A. The pipeline flows in one direction.

**Valid chain:**
```
harness-init -> meeting -> design-doc -> implement -> lint
                                                       |-> lint-manage -> lint-validate
```
