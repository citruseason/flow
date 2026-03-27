# Kanban Schema

## Description

Kanban JSON files track workflow progress at both the root level and per-topic level. Schema compliance ensures the /implement skill can reliably read and resume from saved state.

## Rules

### KS-1: Root kanban schema

`harness/kanban.json` must be a valid JSON object with a `topics` field:

```json
{
  "topics": {
    "<topic-name>": {
      "phase": "<current-phase>",
      "last_updated": "YYYY-MM-DD"
    }
  }
}
```

The `topics` object may be empty (`{}`) when no topics have been created.

### KS-2: Topic kanban schema

`harness/topics/<topic>/kanban.json` must follow this schema:

```json
{
  "topic": "<topic-name>",
  "phase": "meeting | design-doc | implement | lint | done",
  "last_updated": "YYYY-MM-DD",
  "meetings": [
    {"date": "YYYY-MM-DD", "file": "meetings/YYYY-MM-DD-<session>.md"}
  ],
  "steps": {
    "done": [{"id": "<step-id>", "name": "<display-name>"}],
    "in_progress": [{"id": "<step-id>", "name": "<display-name>"}],
    "backlog": [{"id": "<step-id>", "name": "<display-name>"}]
  }
}
```

### KS-3: Required fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| topic | string | Yes | Topic name, must match directory name |
| phase | string | Yes | Current workflow phase |
| last_updated | string | Yes | ISO date (YYYY-MM-DD) |
| meetings | array | Yes | Array of meeting references (may be empty) |
| steps | object | Yes | Contains done, in_progress, backlog arrays |
| steps.done | array | Yes | Completed step items |
| steps.in_progress | array | Yes | Currently active step items |
| steps.backlog | array | Yes | Pending step items |

### KS-4: Step item schema

Each item in done/in_progress/backlog must have:

| Field | Type | Required |
|-------|------|----------|
| id | string | Yes |
| name | string | Yes |

### KS-5: Valid phase values

The `phase` field must be one of:
- `"meeting"` -- meeting in progress
- `"design-doc"` -- design documents being created
- `"implement"` -- implementation in progress
- `"lint"` -- lint verification in progress
- `"done"` -- all steps completed

### KS-6: Date format

All date fields must use ISO 8601 format: `YYYY-MM-DD` (e.g., `2026-03-27`).

### KS-7: At most one in_progress step

The `in_progress` array should contain at most one item at a time. Multiple in-progress items indicate a state inconsistency.

**Exception:** During initial kanban population, the array may be temporarily empty.
