# Tool Declarations

## Description

Agent tool arrays control what capabilities each agent has when dispatched. Tools must be valid Claude Code tools, and the set should match the agent's role (minimal for reviewers, full for writers).

## Rules

### TD-1: Valid tool names only

The only valid tool names are: `Read`, `Write`, `Edit`, `Bash`, `Grep`, `Glob`

Any other string in a tools array is invalid and will cause dispatch failures.

### TD-2: Reviewer agents use minimal tool sets

Agents classified as reviewers should use the minimal set needed for their role:

| Agent | Expected Tools | Rationale |
|-------|---------------|-----------|
| meeting-reviewer | `["Read", "Grep", "Glob"]` | Read-only validation |
| design-doc-reviewer | `["Read", "Grep", "Glob"]` | Read-only validation |
| doc-gardener | `["Read", "Write", "Edit", "Grep", "Glob"]` | Reads + updates stale docs |
| lint-reviewer | `["Read", "Write", "Edit", "Bash", "Grep", "Glob"]` | Reads + writes quality scores + runs lint tools |

### TD-3: Writer agents use full tool sets

Agents classified as writers should have comprehensive access:

| Agent | Expected Tools | Rationale |
|-------|---------------|-----------|
| harness-initializer | `["Read", "Write", "Edit", "Bash", "Grep", "Glob"]` | Full codebase analysis and file generation |
| meeting-facilitator | `["Read", "Write", "Edit", "Bash", "Grep", "Glob"]` | Meeting docs + kanban updates |
| design-doc-writer | `["Read", "Write", "Edit", "Bash", "Grep", "Glob"]` | Design document generation |

### TD-4: Tools array must be a JSON array of strings

The tools field must be a valid JSON array with string elements. Not a comma-separated string, not a YAML list.

**Correct:** `tools: ["Read", "Write", "Edit"]`
**Incorrect:** `tools: "Read, Write, Edit"` or `tools: Read, Write, Edit`
