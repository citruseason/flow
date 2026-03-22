---
name: worktree-create
description: "Create an isolated git worktree for parallel development. Allocates a port block if .flow/config.json exists. Called after /spec completion or directly. Creates branch, worktree directory, and guides the user to start a new Claude Code session."
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

**If neither is provided:** ask the user:
> "What name would you like for this worktree? (This will be used for the branch name and directory)"

**Branch:** if not provided, default to `feature/<name>`.

### 2. Validate

- Check the branch doesn't already exist: `git branch --list <branch>`
- Check `.worktrees/<name>` directory doesn't already exist
- If either exists, inform the user and ask for a different name

### 3. Create Worktree

```bash
git worktree add .worktrees/<name> -b <branch>
```

### 4. Initialize .flow Directory

Ensure `.flow/` directory exists in the project root (not in the worktree):

```bash
mkdir -p .flow
```

If `.flow/worktrees.json` doesn't exist, create it with `{}`.

### 5. Update worktrees.json

Add the new worktree entry:

```json
{
  "<name>": {
    "branch": "<branch>",
    "path": "<absolute-path-to-.worktrees/name>"
  }
}
```

### 6. Port Assignment (conditional)

If `.flow/config.json` exists, invoke the `/port-assign` skill with `worktree=<name>`.

If `.flow/config.json` does not exist, skip port assignment and inform:
> "No .flow/config.json found — skipping port management. Create one to enable automatic port allocation."

### 7. Spec File Access

> **Spec override:** The spec (step 5 of /worktree-create) says "spec 파일을 worktree 디렉토리의 동일 경로에 복사". This is unnecessary because git worktrees share the full git history — committed files (including the spec) are already accessible at the same path in the worktree. No copy needed.

If `spec` argument was provided, confirm the spec file is accessible in the worktree and note the path for the user.

### 8. Update .gitignore

Check if `.worktrees/` and `.flow/worktrees.json` are in `.gitignore`. If not, offer to add:

```
# Flow parallel development
.worktrees/
.flow/worktrees.json
.flow/review-result.md
```

### 9. Output

Display creation summary and next steps:

```
Worktree created:
  Name:   <name>
  Path:   <absolute-path>
  Branch: <branch>
  Ports:  FRONTEND_PORT=10000, API_PORT=10001, DB_PORT=10002  (or "none — no config.json")

Next: open a new terminal and start a Claude Code session:
  cd <absolute-path> && claude

Then run /plan to create the implementation plan.
```

## Chaining

This skill is called by `/spec` when the user agrees to worktree-based development. It can also be called directly via `/worktree-create`.
