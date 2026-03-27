# Naming Conventions

## Description

File and directory naming rules for the Flow plugin. Consistent naming enables predictable discovery by both humans and Claude Code's glob/grep operations.

## Rules

### NC-1: Agent files use kebab-case.md

All files in `agents/` must be kebab-case with `.md` extension.

**Current agent files (correct):**
- `agents/harness-initializer.md`
- `agents/meeting-facilitator.md`
- `agents/meeting-reviewer.md`
- `agents/design-doc-writer.md`
- `agents/design-doc-reviewer.md`
- `agents/doc-gardener.md`
- `agents/lint-reviewer.md`

**Incorrect patterns:**
- `agents/HarnessInitializer.md` (PascalCase)
- `agents/harness_initializer.md` (snake_case)
- `agents/harness-initializer.yaml` (wrong extension)

### NC-2: Skill directories use kebab-case

All directories under `skills/` must be kebab-case.

**Current skill directories (correct):**
- `skills/harness-init/`
- `skills/meeting/`
- `skills/design-doc/`
- `skills/implement/`
- `skills/lint/`
- `skills/lint-manage/`
- `skills/lint-integrate/`
- `skills/lint-validate/`
- `skills/doc-garden/`
- `skills/core-update/`
- `skills/sdd/`
- `skills/tdd/`
- `skills/using-worktree/`
- `skills/update-plugin/`

### NC-3: Skill entry files are SKILL.md (uppercase)

Every skill directory must contain a `SKILL.md` file (all caps). This is the entry point Claude Code scans for.

### NC-4: Reference files use kebab-case.md

Files in `references/` directories must be kebab-case with `.md` extension.

**Correct:** `references/worker-prompt.md`, `references/mock-patterns.md`
**Incorrect:** `references/WorkerPrompt.md`, `references/worker_prompt.md`

### NC-5: Dated documents use YYYY-MM-DD-kebab-case.md

Documents with dates (meeting logs, plans, specs) must prefix with ISO date.

**Correct:** `2026-03-27-session-1.md`, `2026-03-22-parallel-worktree-workflow-plan.md`
**Incorrect:** `03-27-2026-session-1.md`, `session-1-2026-03-27.md`

### NC-6: JavaScript files use camelCase or kebab-case naming

- `.cjs` files: kebab-case (e.g., `server.cjs`)
- `.js` files: kebab-case (e.g., `helper.js`)

### NC-7: Shell scripts use kebab-case

- `.sh` files: kebab-case (e.g., `start-server.sh`, `stop-server.sh`)

### NC-8: HTML templates use kebab-case

- `.html` files: kebab-case (e.g., `frame-template.html`)
