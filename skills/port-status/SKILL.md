---
name: port-status
description: "Display current port allocation status across all worktrees. Shows allocated ports and whether each port is actively in use. Invoke to check port usage."
---

# Port Status

Display current port allocation status across all worktrees with live process detection.

## Process

### 1. Read State

Read `.flow/worktrees.json`. If file doesn't exist or is empty:

> "No worktrees with port allocations found. Use /worktree-create to create a worktree with port management."

### 2. Check Each Port

For each port in each worktree entry, check live status:

```bash
lsof -i :<port> -t 2>/dev/null
```

### 3. Display Results

```
WORKTREE   ENV_VAR         PORT    IN_USE
auth       FRONTEND_PORT   10000   yes (pid: 12345)
auth       API_PORT        10001   yes (pid: 12346)
auth       DB_PORT         10002   no
payments   FRONTEND_PORT   10100   no
payments   API_PORT        10101   no
payments   DB_PORT         10102   no

Total: 2 worktrees, 6 ports allocated, 2 in use
```
