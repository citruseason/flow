---
name: harness-init
description: "Analyze codebase and scaffold harness knowledge base with lint skills. Sets up the foundation for the meeting -> design-doc -> implement -> lint workflow."
---

# Harness Init

Analyze the current project's codebase and scaffold a `harness/` knowledge base with CORE domain documents, CLAUDE.md harness section, dependency references, and tailored `lint-*` skills. This is the entry point for setting up project-aware quality infrastructure.

## Input

```
/harness-init
```

No arguments required. The skill operates on the current project root.

## Checklist

You MUST create a task for each of these items and complete them in order:

1. **Set document language** -- ask the user what language they want generated documents written in. Example: "What language should generated documents be written in? (e.g., English, 한국어, 日本語)". The chosen language will be stored in the CLAUDE.md harness section so all agents follow it automatically.
2. **Detect re-run** -- check if `harness/PRODUCT.md` exists at project root. If yes, check re-run type:
   - `harness/PRODUCT.md` exists -> CORE-era re-run (see Re-run Behavior below)
   - `harness/index.md`, `harness/golden-rules.md`, or `harness/observability.md` exist -> legacy harness (see Legacy Migration below)
   - Neither exists -> fresh run, continue with step 3
3. **Dispatch harness-initializer agent** -- dispatch the `harness-initializer` agent to perform full codebase analysis (project structure, tech stack, architecture patterns, code conventions, project characteristic detection). Include the chosen language in the dispatch prompt.
4. **Present analysis results** -- show the user a summary of what was detected:
   - Tech stack (languages, frameworks, libraries)
   - Architecture pattern (layering, module organization)
   - Code conventions (naming, formatting, error handling)
   - Project characteristics (which CORE documents will be generated and why)
   - Detected tech debt signals
   - Key dependencies for reference collection
   - Proposed lint skills (always: architecture + code-convention, conditional: framework-specific)
   - Ask: "Does this analysis look correct? Any adjustments before I generate the harness?"
5. **User confirmation gate** -- wait for the user to approve or request adjustments. If adjustments requested, re-dispatch the agent with additional instructions.
6. **Generate CORE documents** -- the agent creates all harness files:
   - `harness/PRODUCT.md` -- product definition, stack, conventions (always)
   - `harness/SECURITY.md` -- security principles and invariants (always)
   - `harness/DESIGN.md` -- design system and component patterns (conditional)
   - `harness/FRONTEND.md` -- frontend framework patterns (conditional)
   - `harness/BACKEND.md` -- backend API design and middleware (conditional)
   - `harness/BATCH.md` -- batch processing and scheduling (conditional)
   - `harness/INFRA.md` -- infrastructure and deployment (conditional)
   - `harness/DATA.md` -- database and data access patterns (conditional)
   - `harness/kanban.json` -- empty topics object
   - `harness/quality-score.md` -- quality scoring rubric
   - `harness/tech-debt.md` -- initial tech debt inventory
7. **Generate CLAUDE.md harness section** -- create or update CLAUDE.md with the harness section:
   - Use `<!-- harness:start -->` / `<!-- harness:end -->` markers
   - Include project description, CORE doc listing, operational docs, references pointer, lint skills
   - If CLAUDE.md exists, append section (or replace existing markers). Never modify content outside markers.
   - If CLAUDE.md does not exist, create it with the harness section.
   - Section must be 100 lines or fewer.
8. **Collect dependency references** -- the agent analyzes dependency manifests and fetches references:
   - Parse package.json, pyproject.toml, Cargo.toml, go.mod, etc.
   - For each key dependency: try llms.txt URL first, fallback to generated reference
   - Store at `harness/references/{library-name}.md`
   - Maximum 15 reference files
9. **Generate lint-* skills** -- the agent creates lint skills in `.claude/skills/`:
   - `lint-architecture/` (always)
   - `lint-code-convention/` (always)
   - Framework-specific lint skills (conditional, based on detected stack)
10. **Present generated results** -- show the user what was created:
    - List all generated CORE documents with brief descriptions
    - List generated references
    - Highlight key security rules and architecture constraints
    - Show which lint skills were generated and why
    - Show CLAUDE.md harness section preview
    - Ask: "Everything look good? I can adjust any of these before committing."
11. **User approval gate** -- wait for the user to approve. If changes requested, apply them.
12. **Git commit** -- stage and commit all generated files:
    ```bash
    git add harness/ .claude/skills/lint-*/ CLAUDE.md
    git commit -m "chore: initialize harness knowledge base and lint skills"
    ```
13. **Suggest next step** -- after completion, suggest:
    > "Harness initialized. You can now start a design session with `/meeting \"topic-name\"` to begin working on your next feature."

## Re-run Behavior

### CORE-era Re-run (harness/PRODUCT.md exists)

When `harness/PRODUCT.md` already exists, operate in diff-based update mode:

1. **Dispatch harness-initializer agent** with re-run flag -- the agent re-analyzes the codebase and compares against existing CORE documents.
2. **Present diff summary** -- show the user what changed since the last run:
   - New patterns detected
   - Changed patterns (with before/after)
   - New CORE documents to generate (if new signals detected)
   - New lint rules to add
   - New lint skills to create (if new frameworks detected)
   - New/removed dependencies for reference management
   - Protected files (user-customized, will not be overwritten)
3. **User confirmation gate** -- wait for approval before applying any changes.
4. **Apply updates** -- update only the changed files, preserving user customizations:
   - `harness/kanban.json` is never overwritten
   - Manually edited CORE documents are flagged before modification
   - `harness/quality-score.md` custom weights are preserved
   - Lint rules are appended, never deleted
5. **Update references:**
   - Add reference files for new dependencies
   - Delete reference files for removed dependencies
   - Leave existing references unchanged
6. **Update CLAUDE.md harness section** -- replace content between markers with current state.
7. **Git commit** -- stage and commit only the changed files:
   ```bash
   git add harness/ .claude/skills/lint-*/ CLAUDE.md
   git commit -m "chore: update harness knowledge base"
   ```
8. **Suggest next step** -- same as initial run.

### Legacy Migration (index.md/golden-rules.md/observability.md exist)

When legacy harness files are detected instead of CORE documents:

1. **Dispatch harness-initializer agent** with legacy migration flag -- the agent reads legacy files, performs fresh analysis, and prepares migration.
2. **Present migration plan** -- show the user:
   - Legacy files to be migrated (with content mapping):
     - `index.md` -> project info distributed to `PRODUCT.md`
     - `golden-rules.md` -> rules distributed to `SECURITY.md`, `PRODUCT.md`, and other CORE docs
     - `observability.md` -> content distributed to `BACKEND.md` or `PRODUCT.md`
   - Legacy files to be deleted after migration
   - Files preserved as-is: `quality-score.md`, `tech-debt.md`, `kanban.json`
   - New CORE documents to be generated
   - New CLAUDE.md harness section
   - New dependency references
3. **User confirmation gate** -- wait for approval. Emphasize zero information loss.
4. **Execute migration:**
   - Generate CORE documents, merging legacy content with fresh analysis
   - Delete legacy originals (`index.md`, `golden-rules.md`, `observability.md`)
   - Generate CLAUDE.md harness section
   - Collect dependency references
   - Generate/update lint-* skills
5. **Present mapping summary** -- show where each piece of legacy content was placed.
6. **User approval gate** -- final review before commit.
7. **Git commit:**
   ```bash
   git add harness/ .claude/skills/lint-*/ CLAUDE.md
   git commit -m "chore: migrate harness to CORE documents"
   ```
8. **Suggest next step** -- same as initial run.

## Agent Dispatch

This skill dispatches a single agent:

- **harness-initializer** -- performs all analysis, CORE document generation, CLAUDE.md section generation, reference collection, and lint skill generation

The skill's role is orchestration: dispatching the agent, presenting results to the user, managing confirmation gates, and handling the git commit.

## What This Skill Does NOT Do

- Write implementation code
- Modify existing project source files (except CLAUDE.md harness section within markers)
- Skip user confirmation gates
- Overwrite user-customized files without warning
- Generate per-app CORE docs in monorepos
