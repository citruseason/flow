---
name: worktree-status
description: "Display all registered worktrees with their branch, port block, and directory status. Detects stale entries where the directory has been manually removed. Invoke to check parallel development status."
---

# Worktree Status

Display all registered worktrees with validation.

## Process

### 1. Read State

Read `.flow/worktrees.json`. If file doesn't exist or is empty:

> "No worktrees registered. Use /worktree-create to create one."

### 2. Validate Each Entry

For each worktree entry:
- Check if the directory exists: `.worktrees/<name>/`
- If directory exists: status = `active`
- If directory doesn't exist: status = `missing`

### 3. Display Results

```
NAME       BRANCH           BLOCK   PORTS                              STATUS
auth       feature/auth     10000   FRONTEND:10000,API:10001,DB:10002  active
payments   feature/payments 10100   FRONTEND:10100,API:10101,DB:10102  active
old-feat   feature/old      10200   FRONTEND:10200,API:10201,DB:10202  missing
```

If any worktree has no port assignment:

```
NAME       BRANCH           BLOCK   PORTS   STATUS
simple     feature/simple   -       none    active
```

### 4. Handle Missing Entries

If any worktree has `missing` status:

> "Found stale worktree entries (directory not found). Clean up these entries? (Y/n)"

If yes, remove the stale entries from `.flow/worktrees.json` and run `/port-release` for each.

### 5. Cross-Check with Git

Also run `git worktree list` and compare with `.flow/worktrees.json`. If there are worktrees in git that aren't in the JSON (created outside of Flow), note them:

> "Note: Found git worktrees not managed by Flow:"
> ```
> /project/.worktrees/manual-branch  abc1234 [manual-branch]
> ```
