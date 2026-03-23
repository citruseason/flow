---
name: port-assign
description: "Allocate a port block for a worktree. Reads .flow/config.json for port definitions, finds the next available block in 10000-20000 range, verifies no collisions, and writes .env.flow. Called by /using-worktree or directly."
---

# Port Assign

Allocate a port block for a worktree from the 10000-20000 range using hybrid block-offset + collision check.

## Input

- `worktree` (required): Target worktree name

## Prerequisites

Check that `.flow/config.json` exists in the project root. If not, inform the user:

> ".flow/config.json not found. Create it with your port definitions to enable port management."
>
> Example:
> ```json
> {
>   "ports": {
>     "FRONTEND_PORT": 3000,
>     "API_PORT": 8080,
>     "DB_PORT": 5432
>   }
> }
> ```

## Allocation Process

### 1. Read Port Configuration

Read `.flow/config.json` and extract the `ports` object. The keys are environment variable names, values are original port numbers (used for documentation only — actual allocated ports come from the block).

### 2. Determine Next Available Block

Read `.flow/worktrees.json` (create empty `{}` if it doesn't exist). Find the lowest available block number:

- Blocks start at 10000 and increment by 100 (10000, 10100, 10200, ...)
- A block is "taken" if any entry in `worktrees.json` uses that block number
- Select the first untaken block

### 3. Map Ports Within Block

Assign ports sequentially within the block based on config key order:

```
Block 10000:
  1st key → 10000
  2nd key → 10001
  3rd key → 10002
  ...
```

### 4. Verify No Collisions

For each allocated port, check if it's already in use:

```bash
lsof -i :<port> -t 2>/dev/null
```

If any port in the block is occupied, move to the next block (10100, 10200, ...) and re-check. Maximum 10 retries.

If all 10 blocks have collisions, report error:

> "Could not find an available port block after 10 attempts (range 10000-20000). Please free up ports or assign manually."

### 5. Concurrent Access Guard

Before writing, re-read `.flow/worktrees.json` to verify the chosen block hasn't been taken by another session since step 2. If it has, recalculate from step 2.

### 6. Write .env.flow

Create `.env.flow` in the worktree directory (`.worktrees/<worktree>/`):

```
# Flow port assignment — block <block_number>
FRONTEND_PORT=10000
API_PORT=10001
DB_PORT=10002
```

### 7. Update worktrees.json

Update the worktree entry in `.flow/worktrees.json` with port information:

```json
{
  "<worktree>": {
    "block": 10000,
    "ports": {
      "FRONTEND_PORT": 10000,
      "API_PORT": 10001,
      "DB_PORT": 10002
    }
  }
}
```

Merge with existing entry if the worktree already has other fields (branch, path).

## Output

Display the allocated ports:

```
Port block allocated (block 10000):
  FRONTEND_PORT = 10000
  API_PORT      = 10001
  DB_PORT       = 10002

.env.flow written to .worktrees/<worktree>/.env.flow
```
