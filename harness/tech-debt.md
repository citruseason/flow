# Tech Debt Inventory

## Overview

Last analyzed: 2026-03-28
Total items: 6 (5 open, 1 resolved)

## Items

### Testing: No test coverage for WebSocket server
- **Severity:** HIGH
- **Location:** `skills/meeting/scripts/server.cjs`
- **Description:** The Visual Companion WebSocket server has zero test coverage. It implements RFC 6455 WebSocket protocol (frame encoding/decoding, masking, opcodes), HTTP request handling, file watching with debounce, and lifecycle management. These are all testable and critical to correct operation. The module exports `{ computeAcceptKey, encodeFrame, decodeFrame, OPCODES }` but no tests exercise them.
- **Suggested fix:** Add a test file (e.g., `skills/meeting/scripts/server.test.cjs`) covering: WebSocket frame encode/decode round-trips, accept key computation, `isFullDocument()` detection, `getNewestScreen()` file sorting, and HTTP request routing. Use Node.js built-in `node:test` runner (no dependencies needed).
- **Estimated effort:** Medium

### CI/CD: No automated checks
- **Severity:** MEDIUM
- **Location:** Project root (no `.github/workflows/` or equivalent)
- **Description:** No CI/CD pipeline exists. There are no automated checks for manifest consistency (plugin.json vs marketplace.json versions), frontmatter validity, or even basic syntax checks. All quality verification relies on manual `/lint` invocation.
- **Suggested fix:** Add a GitHub Actions workflow that validates: version sync between manifests, YAML frontmatter parsing in all agent/skill files, and (once tests exist) runs the test suite.
- **Estimated effort:** Small

### Documentation: Bilingual inconsistency
- **Severity:** MEDIUM
- **Location:** `README.md`, `skills/using-worktree/SKILL.md`
- **Description:** README.md is written primarily in Korean while CLAUDE.md is in English. The `using-worktree/SKILL.md` contains Korean section headers ("When This Applies" section uses Korean text). The golden rule states all generated output must be in English, but existing documentation does not consistently follow this. Meeting log templates in `agents/meeting-facilitator.md` also use Korean section headers.
- **Suggested fix:** Standardize all user-facing documentation to English, or explicitly define a bilingual policy (e.g., README in Korean for end users, all agent/skill content in English for agent consumption).
- **Estimated effort:** Medium

### Hardcoded Paths: update-plugin skill
- **Severity:** LOW
- **Location:** `skills/update-plugin/SKILL.md`
- **Description:** The update-plugin skill hardcodes absolute paths to `/Users/user/.claude/plugins/cache/flow-marketplace/` and `/Users/user/.claude/plugins/marketplaces/flow-marketplace`. These paths are user-specific and will not work on other machines.
- **Suggested fix:** Use `$HOME` or `~` expansion instead of hardcoded `/Users/user/`. Alternatively, detect the Claude Code plugin directory dynamically.
- **Estimated effort:** Small

### Convention Conflict: Version history FIFO inversion
- **Severity:** LOW
- **Location:** `skills/design-doc/SKILL.md` (step 3)
- **Description:** The design-doc SKILL.md step 3 states "v2 = most recent prior, v1 = older" which contradicts the meeting SKILL.md, meeting-facilitator agent, and design-doc-writer agent which all state "v1 = most recent prior, v2 = older". The majority convention is v1 = most recent prior.
- **Suggested fix:** Update `skills/design-doc/SKILL.md` step 3 to match the majority convention: "v1 = most recent prior, v2 = older".
- **Estimated effort:** Small
- **STATUS: RESOLVED** -- `skills/design-doc/SKILL.md` no longer specifies an explicit v1/v2 ordering; step 3 now reads "archive them to `history/` using FIFO rotation (max 2 versions)" without the inverted labels. Verified 2026-03-28.

### External Reference: Stale link in frame-template.html
- **Severity:** LOW
- **Location:** `skills/meeting/scripts/frame-template.html` (line 199)
- **Description:** The header link points to `https://github.com/obra/superpowers` which is a different project (Superpowers by Jesse Vincent). The link text says "Flow Spec Companion" but links to an unrelated repository. This appears to be a leftover from when the Visual Companion was adapted from the Superpowers project.
- **Suggested fix:** Update the link to point to the Flow repository or remove the hyperlink entirely, keeping just the text "Flow Spec Companion".
- **Estimated effort:** Small
