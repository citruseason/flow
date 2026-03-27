# Shell Script Style

## Description

Bash script conventions for the Flow plugin's infrastructure scripts. These scripts manage the Visual Companion server lifecycle.

## Rules

### SH-1: Shebang line

All shell scripts must start with `#!/usr/bin/env bash`. This ensures portability across systems where bash may be in different locations.

**Files to check:**
- `skills/meeting/scripts/start-server.sh`
- `skills/meeting/scripts/stop-server.sh`

**Detection:**
```bash
head -1 skills/meeting/scripts/*.sh
```

### SH-2: SCREAMING_SNAKE_CASE for variables

All shell variables use SCREAMING_SNAKE_CASE.

**Correct variables (from start-server.sh):**
- `SCRIPT_DIR`, `PROJECT_DIR`, `FOREGROUND`, `FORCE_BACKGROUND`
- `BIND_HOST`, `URL_HOST`, `SESSION_ID`, `SCREEN_DIR`
- `PID_FILE`, `LOG_FILE`, `SERVER_PID`, `OWNER_PID`

**Incorrect:** `script_dir`, `projectDir`, `screenDir`

**Exception:** Loop variables may use lowercase single letters: `for i in {1..50}`

### SH-3: Double-bracket conditionals

Use `[[ ]]` for all conditional tests. Never use `[ ]` (single bracket).

**Correct:** `if [[ -z "$PROJECT_DIR" ]]; then`
**Incorrect:** `if [ -z "$PROJECT_DIR" ]; then`

**Detection:**
```bash
grep -n 'if \[^[' skills/meeting/scripts/*.sh
```

### SH-4: Dollar-paren command substitution

Use `$()` for command substitution. Never use backticks.

**Correct:** `SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"`
**Incorrect:** `` SCRIPT_DIR=`cd \`dirname "$0"\` && pwd` ``

### SH-5: JSON format for error output

Error messages must be JSON objects with an `error` field. Status messages use a `status` field.

**Correct:**
```bash
echo '{"error": "Server failed to start within 5 seconds"}'
echo '{"status": "stopped"}'
```

**Incorrect:**
```bash
echo "Error: Server failed to start"
echo "Server stopped"
```

### SH-6: Quote all variable expansions

All variable expansions must be quoted to prevent word splitting.

**Correct:** `kill "$pid" 2>/dev/null`
**Incorrect:** `kill $pid 2>/dev/null`

### SH-7: Use case statements for argument parsing

Complex argument parsing should use `case`/`esac` with `shift`.

**Pattern (from start-server.sh):**
```bash
while [[ $# -gt 0 ]]; do
  case "$1" in
    --project-dir)
      PROJECT_DIR="$2"
      shift 2
      ;;
    *)
      echo "{\"error\": \"Unknown argument: $1\"}"
      exit 1
      ;;
  esac
done
```
