---
name: port-release
description: "Release a port block for a worktree. Checks for running processes on allocated ports, removes .env.flow, and cleans up worktrees.json. Called by /worktree-remove or directly."
---

# Port Release

Release a previously allocated port block for a worktree.

## Input

- `worktree` (required): Target worktree name

## Release Process

### 1. Look Up Port Information

Read `.flow/worktrees.json` and find the entry for the target worktree. If no entry exists or no ports are assigned:

> "No port allocation found for worktree '<worktree>'."

### 2. Check for Running Processes

For each allocated port, check if a process is using it:

```bash
lsof -i :<port> -t 2>/dev/null
```

If any port has a running process, warn the user:

> "The following ports are still in use:"
> ```
> PORT    PID     COMMAND
> 10000   12345   node
> 10001   12346   python
> ```
> "Do you want to terminate these processes before releasing?"

If the user agrees, kill the processes:

```bash
kill <pid>
```

If the user declines, proceed with release anyway (the ports will be freed when the processes stop naturally).

### 3. Delete .env.flow

Remove the `.env.flow` file from the worktree directory:

```bash
rm -f .worktrees/<worktree>/.env.flow
```

### 4. Update worktrees.json

Remove the `block` and `ports` fields from the worktree entry in `.flow/worktrees.json`. If the entry has no other fields (branch, path), remove the entire entry.

## Output

```
Port block released (block 10000):
  FRONTEND_PORT = 10000 (freed)
  API_PORT      = 10001 (freed)
  DB_PORT       = 10002 (freed)

.env.flow removed from .worktrees/<worktree>/
```
