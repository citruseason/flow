---
name: worktree-remove
description: "Remove a git worktree and release its port block. Auto-detects current worktree or accepts a name argument. Checks for running processes before cleanup. Invoke when done with a parallel development branch."
---

# Worktree Remove

Remove a git worktree and release its allocated port block.

## Input

- `name` (optional): Worktree name. If omitted, auto-detect from current directory.

## Auto-Detection

If `name` is not provided, check the current working directory:

1. Get the current path
2. Check if it contains `/.worktrees/` in the path
3. If yes, extract the name: `/project/.worktrees/<name>/...` → `<name>`
4. If no, read `.flow/worktrees.json` and list all registered worktrees for the user to choose:

> "Which worktree would you like to remove?"
> ```
> 1. auth (feature/auth, block 10000)
> 2. payments (feature/payments, block 10100)
> ```

## Process

### 1. Validate

Read `.flow/worktrees.json` and confirm the worktree entry exists. If not:

> "Worktree '<name>' not found in .flow/worktrees.json. Check /worktree-status for registered worktrees."

### 2. Check Running Processes

Check if any allocated ports have active processes:

```bash
lsof -i :<port> -t 2>/dev/null
```

If processes are found, warn and ask:

> "Active processes found on worktree ports:"
> ```
> PORT    PID     COMMAND
> 10000   12345   node
> ```
> "Terminate these processes? (Y/n)"

### 3. Release Ports

Invoke `/port-release` skill with `worktree=<name>`.

### 4. Remove Worktree

If the current directory is inside the worktree being removed, warn:

> "You are currently inside the worktree being removed. Please change to the project root first."

Otherwise:

```bash
git worktree remove .worktrees/<name>
```

If the worktree has uncommitted changes, git will refuse. Inform the user:

> "Worktree has uncommitted changes. Commit or stash them first, or use `git worktree remove --force .worktrees/<name>` to discard."

### 5. Update worktrees.json

Remove the entry from `.flow/worktrees.json`.

### 6. Branch Cleanup

Ask the user:

> "Delete branch '<branch>'? (Y/n)"

If yes:

```bash
git branch -d <branch>
```

If the branch is not fully merged, inform and offer force delete:

> "Branch '<branch>' is not fully merged. Force delete? (y/N)"

## Output

```
Worktree removed:
  Name:   <name>
  Branch: <branch> (deleted / kept)
  Ports:  released (block 10000)
```
