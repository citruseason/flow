# Document Templates

## Description

Meeting and design documents must follow defined templates to ensure downstream agents can reliably parse and cross-reference them.

## Rules

### DT-1: Meeting Log required sections

Meeting logs in `harness/topics/*/meetings/*.md` must contain:

| Section | Required |
|---------|----------|
| Title (H1) | Yes |
| Date | Yes |
| Topic | Yes |
| Session identifier | Yes |
| Discussion (Q&A format) | Yes |
| Decisions (numbered list) | Yes |
| Unresolved Items | Yes (may be empty with "None") |

### DT-2: CPS required sections

CPS documents (`harness/topics/*/cps.md`) must contain:

| Section | Required |
|---------|----------|
| Title (H1) with topic name | Yes |
| Last updated date | Yes |
| Context | Yes |
| Problem | Yes |
| Solution | Yes |

Unresolved items must be marked with `> [!NOTE]` callout format when present.

### DT-3: PRD required sections

PRD documents (`harness/topics/*/prd.md`) must contain:

| Section | Required |
|---------|----------|
| Title (H1) with topic name | Yes |
| Last updated date | Yes |
| Functional Requirements | Yes |
| Non-Functional Requirements | Yes |
| User Scenarios | Yes |
| Acceptance Criteria | Yes |

### DT-4: Design document required sections

Each design document must contain its expected structure (concise list format):

**spec.md:** Features (bulleted list), Interfaces (signatures), Data models (compact), Constraints (one-line each)
**blueprint.md:** Components (one-line each), Connections (A → B), External boundaries
**architecture.md:** Stack (list), Hierarchy (layers/groupings), Patterns (one-line rationale), Constraints (one-line each)
**code-dev-plan.md:** Sequential phases, each with What, Where, How, Verify sections
**test-cases.md:** Unit Tests, Integration Tests, E2E Tests with ID/Scenario/Input/Expected format

> Note: Design documents should be concise and scannable. Brevity is intentional — not a deficiency.

### DT-5: No implementation code in design documents

Design documents must not contain executable code. `code-dev-plan.md` describes direction, approach, and location -- never actual code. `spec.md` uses type signatures and contracts, not working implementations.

**Exception:** Code fences used for illustrative pseudocode or type signatures are acceptable.
