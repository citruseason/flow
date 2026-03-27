# History Rotation Consistency

## Description

Multiple skills and agents describe the FIFO document history rotation. All must use the same convention to avoid agents reading the wrong version during change detection.

## Rules

### HR-1: Standard convention

The project convention is:
- **v1 = most recent prior version** (the version that was current before the latest update)
- **v2 = older version** (the version before v1)
- **Maximum 2 archived versions per document**

### HR-2: Rotation procedure

When archiving a document:
1. If `history/<doc>.v2.md` exists, delete it
2. If `history/<doc>.v1.md` exists, rename it to `history/<doc>.v2.md`
3. Copy current `<doc>.md` to `history/<doc>.v1.md`

After rotation: v1 is the just-archived version, v2 is the previously archived version.

### HR-3: Files that must describe this consistently

All of these files reference the history rotation and must use the same convention:

| File | Section |
|------|---------|
| `agents/meeting-facilitator.md` | "Step 3: Archive before updating" |
| `agents/design-doc-writer.md` | "Archive Existing Documents" |
| `skills/meeting/SKILL.md` | "Follow-Up Execution" step 4 |
| `skills/design-doc/SKILL.md` | "Archive Existing Design Documents" step 3 |
| `skills/implement/SKILL.md` | "History-Based Change Detection" |

### HR-4: Known inconsistency (tracked in tech-debt.md)

`skills/design-doc/SKILL.md` step 3 states "v2 = most recent prior, v1 = older" which **inverts** the standard convention. This is tracked as a tech debt item.

**Detection:**
```bash
grep -n "v1.*older\|v2.*most recent prior\|v2.*most recent" skills/design-doc/SKILL.md
```

All other files correctly state "v1 = most recent prior, v2 = older".

### HR-5: History directory location

Archived versions are stored in `harness/topics/<topic>/history/` as `<doc-name>.v1.md` and `<doc-name>.v2.md`.

Documents that get archived:
- `cps.md` -> `history/cps.v1.md`, `history/cps.v2.md`
- `prd.md` -> `history/prd.v1.md`, `history/prd.v2.md`
- `spec.md` -> `history/spec.v1.md`, `history/spec.v2.md`
- `blueprint.md` -> `history/blueprint.v1.md`, `history/blueprint.v2.md`
- `architecture.md` -> `history/architecture.v1.md`, `history/architecture.v2.md`
- `code-dev-plan.md` -> `history/code-dev-plan.v1.md`, `history/code-dev-plan.v2.md`
- `test-cases.md` -> `history/test-cases.v1.md`, `history/test-cases.v2.md`
