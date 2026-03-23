---
name: worktree-create
description: "Create an isolated git worktree for parallel development. Allocates a port block if .flow/config.json exists. Called after /spec completion or directly. Creates branch, worktree directory, runs project setup, and verifies clean baseline before handing off."
---

# Worktree Create

Create an isolated git worktree for parallel feature development with automatic port management.

## Input

- `name` (optional): Worktree name. If omitted, extract from spec filename (e.g., `2026-03-22-auth-design.md` → `auth`) or ask the user.
- `branch` (optional): Branch name. Defaults to `feature/<name>`.
- `spec` (optional): Spec file path. Auto-passed when chained from `/spec`.

## Process

### 1. Determine Name and Branch

**If `name` is provided:** use it directly.

**If `spec` is provided but not `name`:** extract name from the spec filename:
- Pattern: `YYYY-MM-DD-<name>-design.md`
- Example: `2026-03-22-user-auth-design.md` → `user-auth`

**If neither is provided:** use AskUserQuestion:
> "What name would you like for this worktree? (This will be used for the branch name and directory)"

**Branch:** if not provided, default to `feature/<name>`.

### 2. Safety Verification

Verify `.worktrees/` is gitignored before proceeding:

```bash
git check-ignore -q .worktrees 2>/dev/null
```

If NOT ignored, add to `.gitignore` and commit before proceeding:

```bash
echo ".worktrees/" >> .gitignore
git add .gitignore && git commit -m "chore: add .worktrees/ to gitignore"
```

Also ensure `.flow/worktrees.json` and `.flow/review-result.md` are ignored.

### 3. Validate

- Check the branch doesn't already exist: `git branch --list <branch>`
- Check `.worktrees/<name>` directory doesn't already exist
- If either exists, use AskUserQuestion to inform and ask for a different name

### 4. Create Worktree

```bash
git worktree add .worktrees/<name> -b <branch>
cd .worktrees/<name>
```

From this point, all work happens inside the worktree.

### 5. Run Project Setup

Auto-detect and run appropriate setup:

```bash
# Node.js
if [ -f package.json ]; then npm install; fi

# Python
if [ -f requirements.txt ]; then pip install -r requirements.txt; fi
if [ -f pyproject.toml ]; then poetry install; fi

# Go
if [ -f go.mod ]; then go mod download; fi

# Rust
if [ -f Cargo.toml ]; then cargo build; fi
```

### 6. Initialize .flow State

Ensure `.flow/` directory exists in the **project root** (not in the worktree):

```bash
mkdir -p <project-root>/.flow
```

If `.flow/worktrees.json` doesn't exist, create it with `{}`.

Add the new worktree entry:

```json
{
  "<name>": {
    "branch": "<branch>",
    "path": "<absolute-path-to-.worktrees/name>"
  }
}
```

### 7. Port Assignment (conditional)

If `.flow/config.json` exists, invoke the `/port-assign` skill with `worktree=<name>`.

If `.flow/config.json` does not exist, skip port assignment and inform:
> "No .flow/config.json found — skipping port management. Create one to enable automatic port allocation."

### 8. Verify Clean Baseline

Run tests to confirm worktree starts clean:

```bash
# Use project-appropriate test command
npm test || pytest || go test ./... || cargo test
```

**If tests fail:** Use AskUserQuestion to report failures and ask whether to proceed or investigate.

**If tests pass:** Report ready.

**If no test runner found:** Skip and proceed.

### 9. Report Ready

```
Worktree ready at <full-path>
  Branch: <branch>
  Ports:  FRONTEND_PORT=10000, API_PORT=10001, DB_PORT=10002  (or "none")
  Tests:  passing (N tests) / skipped (no test runner)

Ready for /plan.
```

The session is now working inside the worktree. All subsequent skills (`/plan`, `/tdd`, `/code-review`, `/branch-finish`) operate on worktree files automatically.

## Mid-Workflow Transition Guide

This skill can be invoked at any point, not only after `/spec`. When called mid-workflow (e.g., during `/plan` or after `/tdd` has started), assess the current state and act accordingly:

- **No uncommitted changes on main:** Proceed normally. Committed documents (spec, plan) are accessible in the worktree via shared git history.
- **Uncommitted changes on main:** Stash them before creating the worktree, then apply the stash inside the worktree. Inform the user what was stashed.
- **Commits on main that should have been on a feature branch:** Create the worktree, then cherry-pick or rebase those commits onto the new branch. Use AskUserQuestion to confirm which commits to move.

The goal is a seamless transition regardless of when the user decides to isolate their work.

## Chaining

This skill is called by `/spec` when the user agrees to worktree-based development. Can also be called directly via `/worktree-create` at any point in the workflow.

After this skill completes, the session is inside the worktree — all subsequent skills work there without any extra configuration.
