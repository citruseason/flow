---
name: lint-integrate
description: "Integrate external skills into the lint workflow as lint-* wrapper skills. Supports add, update, list, and remove operations."
---

# Lint Integrate

Add external skills (GitHub repos, plugin skills) as `lint-*` wrapper skills so they run automatically during `/lint`.

## Input

```
/lint-integrate add <source>        ← add external skill as lint wrapper
/lint-integrate update [name]       ← re-sync all or specific integrated skill
/lint-integrate list                ← show all integrated external skills
/lint-integrate remove <name>       ← remove an integrated skill
```

## Source Types

The `<source>` argument accepts:

| Type | Example | Resolution |
|------|---------|------------|
| GitHub URL | `https://github.com/vercel-labs/agent-skills/tree/main/skills/react-best-practices` | Clone/fetch SKILL.md + references from the repo path |
| GitHub shorthand | `vercel-labs/agent-skills:skills/react-best-practices` | Same as above, shorter format |
| Raw URL | `https://example.com/skill.md` | Fetch single file as rules |

## Add Flow

### 1. Parse Source

Determine source type from the input. Extract:
- **repo** (owner/repo)
- **path** (directory within repo)
- **branch** (default: main)

### 2. Fetch Content

Use WebFetch or `gh` CLI to retrieve the external skill content:

- Read `SKILL.md` from the source path
- Read all files in `references/` if present
- If the source has an `AGENTS.md` or other rule files, include those too

### 3. Extract Lint Name

Derive the lint skill name from the source:
- `react-best-practices` → `lint-react-best-practices`
- If a `lint-` prefixed skill with that name already exists, warn and ask to overwrite or skip

### 4. Generate Wrapper Skill

Create the lint skill in the **user's project** at `.claude/skills/lint-{name}/`:

#### `SKILL.md`

```markdown
---
name: lint-{name}
description: "{one-line description from source skill}"
---

# Lint: {Name}

## Source

Integrated from external skill. See `references/source.md` for origin.

## Rules

See `references/rules.md` for the complete rule set.

## How to Check

For each rule in `references/rules.md`:
1. Search the codebase for violations using Grep/Glob
2. Report violations with file path, line number, and which rule was violated
3. Classify severity: CRITICAL (breaks functionality), WARNING (suboptimal pattern), INFO (suggestion)

## Output Contract

{standard lint output contract format — Status: PASS/WARNING/FAIL, findings list}
```

#### `references/rules.md`

The full content extracted from the external skill — all rules, guidelines, patterns, and examples. This is the authoritative rule set that the lint-reviewer reads and checks against.

#### `references/source.md`

```markdown
# Source

- **Origin:** {full URL or reference}
- **Type:** {github | url}
- **Repo:** {owner/repo if github}
- **Path:** {path within repo if github}
- **Branch:** {branch name}
- **Last synced:** {YYYY-MM-DD}
- **Commit:** {short SHA if available}
```

### 5. Confirm

Show the user what was created:
- Skill path: `.claude/skills/lint-{name}/`
- Rule count or summary
- Source reference
- "This skill will now run automatically during `/lint`."

## Update Flow

### 1. Discover Integrated Skills

Glob for `.claude/skills/lint-*/references/source.md` in the user's project.
Parse each `source.md` to find externally-integrated skills (those with `Origin` field).

### 2. Fetch Latest

For each integrated skill (or the specific one if `name` provided):
1. Re-fetch content from the recorded origin
2. Compare with current `references/rules.md`
3. If changed:
   - Overwrite `references/rules.md` with new content
   - Update `Last synced` and `Commit` in `source.md`
   - Show diff summary to user
4. If unchanged: report "already up to date"

### 3. Report

```
Lint integration update:
  lint-react-best-practices: updated (3 rules added, 1 modified)
  lint-go-standards: already up to date
```

## List Flow

Glob for `.claude/skills/lint-*/references/source.md`, parse each, and display:

```
Integrated lint skills:
  lint-react-best-practices
    Source: vercel-labs/agent-skills:skills/react-best-practices
    Last synced: 2026-03-28

  lint-go-standards
    Source: example/go-skills:skills/go-standards
    Last synced: 2026-03-25
```

If no integrated skills found: "No external skills integrated. Use `/lint-integrate add <source>` to add one."

## Remove Flow

1. Confirm with user: "Remove lint-{name}? This will delete `.claude/skills/lint-{name}/`."
2. Delete the entire skill directory
3. Report removal

## What This Skill Does NOT Do

- Modify the external skill source
- Run the lint check itself (that's lint-reviewer's job during `/lint`)
- Auto-update without user invocation
- Integrate skills that aren't lint-compatible (no generic tool integration)
