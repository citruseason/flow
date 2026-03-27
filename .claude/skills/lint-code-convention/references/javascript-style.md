# JavaScript Style

## Description

JavaScript coding conventions for the Visual Companion server and related scripts. The project uses zero-dependency Node.js with CommonJS modules.

## Rules

### JS-1: 2-space indentation

All JavaScript files must use 2-space indentation. No tabs.

**Detection:**
```bash
grep -Pn '\t' skills/meeting/scripts/server.cjs skills/meeting/scripts/helper.js
```

### JS-2: Single quotes for strings

Use single quotes for string literals. Double quotes only inside single-quoted strings or in JSON.

**Correct:** `const name = 'flow';`
**Incorrect:** `const name = "flow";`

**Exception:** Template literals with backticks are preferred for string interpolation:
```javascript
const url = `http://${host}:${port}`;
```

### JS-3: Semicolons required

Every statement must end with a semicolon.

**Correct:** `const x = 1;`
**Incorrect:** `const x = 1`

### JS-4: const by default

Use `const` for all declarations. Use `let` only when the variable is reassigned. Never use `var`.

**Detection:**
```bash
grep -n '\bvar\b' skills/meeting/scripts/server.cjs
```

### JS-5: camelCase for functions and variables

Functions and local variables use camelCase.

**Correct:** `function handleRequest(req, res)`, `let payloadLen`
**Incorrect:** `function handle_request(req, res)`, `let payload_len`

### JS-6: SCREAMING_SNAKE_CASE for module-level constants

Constants defined at the module level use SCREAMING_SNAKE_CASE.

**Current constants (correct):**
- `OPCODES`
- `WS_MAGIC`
- `PORT`
- `HOST`
- `URL_HOST`
- `SCREEN_DIR`
- `OWNER_PID`
- `MIME_TYPES`
- `WAITING_PAGE`
- `IDLE_TIMEOUT_MS`

### JS-7: CommonJS module format

The project uses CommonJS (not ES modules). Files use `.cjs` extension or plain `.js`.

**Correct:**
```javascript
const http = require('http');
module.exports = { computeAcceptKey, encodeFrame, decodeFrame, OPCODES };
```

**Incorrect:**
```javascript
import http from 'http';
export { computeAcceptKey };
```

### JS-8: Zero external dependencies

The Visual Companion server must use only Node.js built-in modules. No npm packages.

**Allowed imports:**
- `require('crypto')`
- `require('http')`
- `require('fs')`
- `require('path')`
- Any other `node:` built-in

**Detection:**
```bash
grep -n "require(" skills/meeting/scripts/server.cjs | grep -v "require('crypto')\|require('http')\|require('fs')\|require('path')"
```
