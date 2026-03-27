---
name: lint-architecture
description: "Check architecture compliance -- agent-skill separation, dependency direction, model assignment, skill self-containment, and agent registration."
---

# lint-architecture

Verify that the Flow plugin's three-layer architecture (skills -> agents -> infrastructure) is correctly maintained. This skill checks structural invariants that, if violated, break the plugin's execution model.

## Before Running

Read all files in this skill's `references/` directory to load the detailed rules:
- `references/agent-skill-separation.md`
- `references/dependency-direction.md`
- `references/model-assignment.md`

## Scope

Check these directories and file patterns:
- `agents/*.md` -- all agent definitions
- `skills/*/SKILL.md` -- all skill definitions
- `skills/*/references/*.md` -- skill reference files
- `skills/meeting/scripts/*` -- infrastructure scripts
- `.claude-plugin/plugin.json` -- agent registration

## Rules

### Rule 1: Agent-Skill Separation
- **What:** Agents must not contain orchestration logic (confirmation gates, kanban updates, git commits, slash command invocations). Skills must not contain execution logic (document generation, code analysis, review criteria).
- **Upstream:** harness/ARCHITECTURE.md
- **Why:** Agents execute with fresh context per dispatch. Mixing orchestration into agents causes state management issues. Mixing execution into skills bloats the orchestration layer.
- **Detection:** Grep agent files for orchestration patterns: "git commit", "git add", "kanban", "confirmation", "user approval", "AskUserQuestion". Grep skill files for execution-specific patterns: prompts with detailed generation instructions that should be in agents.
- **Fix:** Move orchestration logic to the dispatching skill. Move execution logic to the appropriate agent.

### Rule 2: Skill Self-Containment
- **What:** Every skill directory must have a SKILL.md with valid YAML frontmatter containing `name` and `description` fields. The `name` field must match the directory name.
- **Upstream:** harness/ARCHITECTURE.md
- **Why:** Claude Code discovers skills by scanning for SKILL.md files with valid frontmatter. Missing or malformed frontmatter makes the skill invisible.
- **Detection:** Glob for `skills/*/SKILL.md`. Parse YAML frontmatter (between `---` delimiters). Verify `name` and `description` fields exist and `name` matches the parent directory name.
- **Fix:** Add or correct YAML frontmatter with matching name and description.

### Rule 3: Agent Registration
- **What:** Every `.md` file in `agents/` must be listed in `.claude-plugin/plugin.json` agents array.
- **Upstream:** harness/ARCHITECTURE.md
- **Why:** Unregistered agents are not loadable by Claude Code. Registered agents that don't exist cause plugin load failures.
- **Detection:** List all files in `agents/`. Read `plugin.json` agents array. Compare the two lists.
- **Fix:** Add missing agents to plugin.json or remove stale entries.

### Rule 4: Dependency Direction
- **What:** Skills may reference other skills by slash command name. Agents must not reference other agents. Scripts must not reference agents or skills.
- **Upstream:** harness/ARCHITECTURE.md
- **Why:** Agents are dispatched with fresh context -- they should not assume another agent's state. Scripts are infrastructure and should be agnostic to the prompt layer above them.
- **Detection:** Grep agent files for references to other agent filenames (e.g., "meeting-reviewer", "design-doc-writer" used as dispatch targets are OK in skills, not OK as imports in agents). Grep script files for agent or skill references.
- **Fix:** Remove cross-references and restructure the dependency.

### Rule 5: Model Assignment
- **What:** Writer/creator agents must use `model: opus`. Validator/reviewer agents must use `model: sonnet`.
- **Upstream:** harness/ARCHITECTURE.md#model-assignment
- **Why:** Writer agents need maximum reasoning capability for generation. Reviewer agents need speed and efficiency for validation passes.
- **Detection:** Read each agent's frontmatter. Classify by role (writer: harness-initializer, meeting-facilitator, design-doc-writer; reviewer: meeting-reviewer, design-doc-reviewer, doc-gardener, lint-reviewer). Verify model assignment matches role.
- **Fix:** Update the `model` field in agent frontmatter.

## Output Contract

When reporting results, use this exact format:

```
## Lint Result: lint-architecture

### Status: PASS | WARNING | FAIL

### Findings

- [FAIL] {filepath}:{line} -- {description}
- [WARNING] {filepath}:{line} -- {description}
- [PASS] {check item} -- {pass reason}

### Summary

- Total checks: {N}
- Pass: {N} / Warning: {N} / Fail: {N}
```

## Rule Accumulation

Rules in `references/` are append-only. When updating:
- Add new rules at the end of the relevant file
- Update existing rules in place (clarify, add examples)
- Never delete rules -- mark deprecated rules with `[DEPRECATED: reason]`
