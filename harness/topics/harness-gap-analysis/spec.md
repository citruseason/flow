# Spec: Harness Gap Analysis

## Features

### CORE Domain Documents (R1)
- `/harness-init` generates CORE domain docs at `harness/` root
- Always generated: `PRODUCT.md`, `SECURITY.md`
- Conditionally generated based on project analysis: `DESIGN.md`, `FRONTEND.md`, `BACKEND.md`, `BATCH.md`, `INFRA.md`, `DATA.md`, additional as warranted
- Product-level scope — monorepo projects get one unified set, not per-app
- Detection criteria defined for each conditional document type

### CLAUDE.md Agent Entry Point (R2)
- `/harness-init` adds harness section to user project's CLAUDE.md
- Creates CLAUDE.md if absent; appends to existing without modifying user content
- Section includes: one-line project description, CORE doc listing with descriptions, pointers to topics/ and operational docs
- Section ≤ 100 lines
- Section updated when CORE docs change

### Legacy File Migration (R3)
- `harness/index.md` removed — replaced by CLAUDE.md harness section
- `harness/golden-rules.md` decomposed — rules distributed to relevant CORE docs
- `harness/observability.md` absorbed — content distributed to domain docs
- `harness/quality-score.md` and `harness/tech-debt.md` retained
- All existing information preserved — zero loss

### CORE as Lint Skill Upstream (R4)
- Lint rules derived from CORE docs, traceable to specific principles
- Lint skill files include explicit CORE doc references
- `/lint-manage` updates lint rules when CORE docs change
- `/lint-manage` checks CORE-lint alignment on create/update

### Merge-Time CORE Update (R5)
- CORE docs updated on merge, not at meeting/design-doc time
- System detects merge events and triggers CORE updates automatically
- Only affected CORE docs updated with realized design decisions
- CORE contains only realized facts (existing code), never planned changes
- CLAUDE.md harness section updated if CORE map changes

### Reference Management (R6)
- `/harness-init` analyzes dependency files → collects refs into `harness/references/`
- Libraries with official `llms.txt` → fetch directly
- Libraries without `llms.txt` → agent-generated reference from official docs
- Users can manually add references
- New dependencies → auto-collect; removed dependencies → cleanup
- Consistent agent-readable format

### Diverse Project Type Support (R7)
- Supports: web apps (SPA/SSR), backend services (REST/GraphQL), CLI tools, libraries, monorepos, mobile apps, batch/data pipelines
- Multi-characteristic projects handled correctly
- Extensible — new document types don't require changes to existing docs or lint skills

## Interfaces

### `/harness-init` (modified)
- Input: project root (implicit)
- Output: CORE docs at `harness/`, harness section in CLAUDE.md, lint skills, references
- Re-run: diff-based update of CORE docs + CLAUDE.md section

### `/lint-manage` (modified)
- Input: CORE doc changes, lint skill definitions
- Output: updated lint rules with CORE references
- New: CORE-lint alignment check

### Merge-Time Hook
- Trigger: topic branch merged to main
- Input: merged topic's design docs + current CORE docs
- Output: updated CORE docs + CLAUDE.md section

### Reference Collector
- Input: dependency manifests (package.json, pyproject.toml, Cargo.toml, go.mod, etc.)
- Output: reference files in `harness/references/`
- Modes: initial collection, incremental add, cleanup

## Data Models

### CORE Document
- Location: `harness/<NAME>.md` (uppercase)
- Types: always (PRODUCT, SECURITY) | conditional (DESIGN, FRONTEND, BACKEND, BATCH, INFRA, DATA, ...)
- Scope: product-level, not per-app
- Content: domain-specific rules/principles/decisions — realized facts only

### CLAUDE.md Harness Section
- Location: user project CLAUDE.md (appended block)
- Max: 100 lines
- Content: project description, CORE doc listing, pointers to topics/ and operational docs

### Reference File
- Location: `harness/references/<library-name>.md`
- Source: llms.txt (direct) or agent-generated
- Lifecycle: created on dependency detection, removed on dependency removal

### Detection Config
- Maps project signals → conditional CORE documents
- Signals: framework files, dependency names, directory patterns
- E.g., React/Vue/Angular → FRONTEND.md; Express/FastAPI → BACKEND.md

## Constraints

- CLAUDE.md harness section ≤ 100 lines
- Existing CLAUDE.md user content never modified (append only)
- CORE docs: realized facts only — no planned changes from unmerged topics
- Legacy migration: zero information loss
- Lint rules must trace to a specific CORE document principle
- Extensible without modifying existing docs or lint skills
