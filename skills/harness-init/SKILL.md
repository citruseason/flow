---
name: harness-init
description: "Analyze codebase and scaffold harness knowledge base with lint skills. Sets up the foundation for the meeting -> design-doc -> implement -> lint workflow."
---

# Harness Init

Analyze the current project's codebase and scaffold a `harness/` knowledge base with tailored `lint-*` skills. This is the entry point for setting up project-aware quality infrastructure.

## Input

```
/harness-init
```

No arguments required. The skill operates on the current project root.

## Checklist

You MUST create a task for each of these items and complete them in order:

1. **Set document language** -- ask the user what language they want generated documents written in. Example: "What language should generated documents be written in? (e.g., English, 한국어, 日本語)". The chosen language will be written into the project's CLAUDE.md (inside the `<!-- harness:start/end -->` section) so all agents follow it automatically.
2. **Detect re-run** -- check if `harness/index.md` exists at project root. If yes, switch to update mode (see Re-run Behavior below).
3. **Dispatch harness-initializer agent** -- dispatch the `harness-initializer` agent to perform full codebase analysis (project structure, tech stack, architecture patterns, code conventions). Include the language setting in the dispatch prompt.
4. **Present analysis results** -- show the user a summary of what was detected:
   - Tech stack (languages, frameworks, libraries)
   - Architecture pattern (layering, module organization)
   - Code conventions (naming, formatting, error handling)
   - Detected tech debt signals
   - Proposed lint skills (always: architecture + code-convention, conditional: framework-specific)
   - Ask: "Does this analysis look correct? Any adjustments before I generate the harness?"
5. **User confirmation gate** -- wait for the user to approve or request adjustments. If adjustments requested, re-dispatch the agent with additional instructions.
6. **Generate harness/ directory** -- the agent creates all harness files:
   - `harness/index.md` -- knowledge base table of contents
   - `harness/kanban.json` -- empty topics object
   - `harness/quality-score.md` -- quality scoring rubric
   - `harness/observability.md` -- logging/metrics/error format guidelines
   - `harness/golden-rules.md` -- core invariant rules
   - `harness/tech-debt.md` -- initial tech debt inventory
   - `harness/references/.gitkeep` -- empty references directory
7. **Generate lint-* skills** -- the agent creates lint skills in `.claude/skills/`:
   - `lint-architecture/` (always)
   - `lint-code-convention/` (always)
   - Framework-specific lint skills (conditional, based on detected stack)
8. **Present generated results** -- show the user what was created:
   - List all generated files with brief descriptions
   - Highlight key golden rules and architecture constraints
   - Show which lint skills were generated and why
   - Ask: "Everything look good? I can adjust any of these before committing."
9. **User approval gate** -- wait for the user to approve. If changes requested, apply them.
10. **Git commit** -- stage and commit all generated files:
    ```bash
    git add harness/ .claude/skills/lint-*/
    git commit -m "chore: initialize harness knowledge base and lint skills"
    ```
11. **Suggest next step** -- after completion, suggest:
    > "Harness initialized. You can now start a design session with `/meeting \"topic-name\"` to begin working on your next feature."

## Re-run Behavior

When `harness/index.md` already exists, operate in diff-based update mode:

1. **Dispatch harness-initializer agent** with re-run flag -- the agent re-analyzes the codebase and compares against existing harness files.
2. **Present diff summary** -- show the user what changed since the last run:
   - New patterns detected
   - Changed patterns (with before/after)
   - New lint rules to add
   - New lint skills to create (if new frameworks detected)
   - Protected files (user-customized, will not be overwritten)
3. **User confirmation gate** -- wait for approval before applying any changes.
4. **Apply updates** -- update only the changed files, preserving user customizations:
   - `harness/kanban.json` is never overwritten
   - Manually edited files are flagged before modification
   - Lint rules are appended, never deleted
5. **Git commit** -- stage and commit only the changed files:
   ```bash
   git add harness/ .claude/skills/lint-*/
   git commit -m "chore: update harness knowledge base"
   ```
6. **Suggest next step** -- same as initial run.

## Agent Dispatch

This skill dispatches a single agent:

- **harness-initializer** -- performs all analysis and file generation

The skill's role is orchestration: dispatching the agent, presenting results to the user, managing confirmation gates, and handling the git commit.

## What This Skill Does NOT Do

- Write implementation code
- Modify existing project source files
- Skip user confirmation gates
- Delete any existing harness or lint files
- Overwrite user-customized files without warning
