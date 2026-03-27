# PRD: Harness Gap Analysis

## Overview

Introduce a CORE knowledge layer and agent entry point to the Flow plugin, enabling agents to quickly understand user projects and accumulate product-level knowledge across topics.

## Goals

1. Agents can understand any user project with minimal initial context through progressive disclosure
2. Product-level knowledge accumulates as topics are completed and merged
3. Domain-specific documents replace monolithic cross-cutting files
4. Lint skills reference authoritative design intent, not just detected patterns
5. Support diverse project types including monorepos, web apps, backend services, batch systems
6. External references for project dependencies are automatically collected, maintained, and kept up to date

## Non-Goals

- Execution plans as first-class artifacts
- Background/periodic agent execution (garbage collection)
- Agent self-review loop (Ralph Wiggum Loop)
- Structural tests (ArchUnit-style)
- Agent-optimized lint error messages
- Per-domain quality grades

## Requirements

### R1. CORE Domain Documents

**R1.1** `/harness-init` MUST generate CORE domain documents at `harness/` root based on project analysis.

**R1.2** The following documents MUST always be generated regardless of project type:
- `PRODUCT.md` — Product definition (purpose, target users, core value proposition, domain terminology)
- `SECURITY.md` — Security principles and constraints

**R1.3** The following documents MUST be conditionally generated based on detected project characteristics:
- `DESIGN.md` — UI/UX design direction (design system, visual patterns, brand, accessibility)
- `FRONTEND.md` — Frontend technical rules (component patterns, state management, styling, routing, frontend observability/error tracking)
- `BACKEND.md` — Backend technical rules (API patterns, logging, metrics, tracing, data access)
- `BATCH.md` — Batch processing rules (scheduling, error handling, idempotency)
- `INFRA.md` — Infrastructure rules (deployment, CI/CD, environments)
- `DATA.md` — Data management rules (schema, migrations, storage)
- Additional domain documents as project characteristics warrant

**R1.4** CORE documents MUST be product-level, not per-app or per-package. In monorepo projects, CORE describes the unified product across all apps/packages.

**R1.5** Detection criteria for conditional documents MUST be defined for each document type (e.g., detect React/Vue/Angular → generate FRONTEND.md, detect Express/FastAPI/Spring → generate BACKEND.md).

### R2. CLAUDE.md Agent Entry Point

**R2.1** `/harness-init` MUST add a harness section to the user project's CLAUDE.md.

**R2.2** If CLAUDE.md does not exist, it MUST be created.

**R2.3** If CLAUDE.md already exists, the harness section MUST be appended without modifying existing content.

**R2.4** The harness section MUST include:
- One-line project description (derived from PRODUCT.md)
- List of generated CORE domain documents with one-line descriptions
- Pointers to harness/topics/ for ongoing work
- Pointer to harness/quality-score.md and harness/tech-debt.md

**R2.5** The harness section MUST be 100 lines or fewer to avoid context bloat.

**R2.6** The harness section MUST be updated when CORE documents change (added, removed, or significantly modified).

### R3. Legacy File Migration

**R3.1** `harness/index.md` MUST be removed. Its map/navigation role is replaced by the CLAUDE.md harness section.

**R3.2** `harness/golden-rules.md` MUST be decomposed. Each rule MUST be distributed to the relevant CORE domain document (e.g., security rules → SECURITY.md, backend architecture rules → BACKEND.md). The file MUST be removed after distribution.

**R3.3** `harness/observability.md` MUST be absorbed into relevant domain documents (e.g., frontend error tracking → FRONTEND.md, backend logging/metrics → BACKEND.md). The file MUST be removed after absorption.

**R3.4** `harness/quality-score.md` and `harness/tech-debt.md` MUST be retained as cross-cutting operational documents.

**R3.5** Migration MUST preserve all existing information — no rules or guidelines may be lost during restructuring.

### R4. CORE as Lint Skill Upstream Source

**R4.1** Lint skill rules MUST be derived from CORE domain documents. Each lint rule MUST trace back to a specific principle or decision in a CORE document.

**R4.2** Lint skill definition files MUST include explicit references to the CORE document(s) from which their rules are derived.

**R4.3** When a CORE domain document is updated, `/lint-manage` MUST identify affected lint skills and update their rules to reflect the change.

**R4.4** `/lint-manage` MUST check for CORE-lint alignment when creating or updating lint skills.

### R5. Merge-Time CORE Update

**R5.1** CORE documents MUST be updated when topic-related code is merged, not at meeting or design-doc completion.

**R5.2** The system MUST detect merge events and trigger CORE updates automatically.

**R5.3** On merge, the system MUST identify which CORE documents are affected by the merged topic and update them with realized design decisions and patterns.

**R5.4** CORE updates MUST only contain realized facts (code that exists), not planned or proposed changes.

**R5.5** The CLAUDE.md harness section MUST be updated if CORE document changes affect the map (e.g., new domain document added).

### R6. Reference Management

**R6.1** `/harness-init` MUST analyze project dependency files (package.json, pyproject.toml, Cargo.toml, go.mod, etc.) and automatically collect reference material for detected libraries and frameworks into `harness/references/`.

**R6.2** For libraries that provide an official llms.txt, the system MUST fetch and store it directly.

**R6.3** For libraries that do not provide llms.txt, the system MUST extract key content from official documentation to generate a reference file.

**R6.4** Users MUST be able to manually add reference files at any time.

**R6.5** When new dependencies are added to the project during development, the system MUST automatically collect and add corresponding references.

**R6.6** When dependencies are removed from the project, the system MUST clean up stale reference files.

**R6.7** Reference files MUST be stored in a consistent, agent-readable format in `harness/references/`.

### R7. Diverse Project Type Support

**R7.1** CORE document generation MUST support at minimum: web apps (SPA, SSR), backend services (REST, GraphQL), CLI tools, libraries/packages, monorepos, mobile apps, batch/data pipelines.

**R7.2** `/harness-init` MUST correctly detect and handle projects with multiple characteristics (e.g., a project that is both frontend and backend).

**R7.3** The document structure MUST be extensible. Adding a new domain document type MUST NOT require modifications to existing CORE documents or lint skills.

## Acceptance Criteria

- [ ] AC1: Running `/harness-init` on a React+Express project generates PRODUCT.md, SECURITY.md, DESIGN.md, FRONTEND.md, BACKEND.md at `harness/` root
- [ ] AC2: Running `/harness-init` on a Python CLI tool generates PRODUCT.md, SECURITY.md at `harness/` root (no DESIGN.md, FRONTEND.md, etc.)
- [ ] AC3: CLAUDE.md contains a harness section listing all generated CORE documents with one-line descriptions
- [ ] AC4: `harness/index.md`, `harness/golden-rules.md`, `harness/observability.md` do not exist after migration
- [ ] AC5: All rules from former golden-rules.md are present in the appropriate CORE domain documents
- [ ] AC6: Each lint skill definition file includes explicit references to the CORE document(s) from which its rules are derived
- [ ] AC7: After a topic branch is merged, affected CORE documents are updated with realized design decisions only — no planned or proposed changes from unmerged topics appear in CORE
- [ ] AC8: CLAUDE.md harness section is 100 lines or fewer
- [ ] AC9: Running `/harness-init` on a monorepo generates product-level (not per-app) CORE documents
- [ ] AC10: When a CORE document is updated, `/lint-manage` identifies and updates affected lint skills
- [ ] AC11: When a new CORE domain document is added, the CLAUDE.md harness section is updated to include it
- [ ] AC12: Adding a new domain document type does not require modifications to existing CORE documents or lint skills
- [ ] AC13: Running `/harness-init` on a project with React, Express, and Tailwind dependencies generates reference files for each in `harness/references/`
- [ ] AC14: Adding a new dependency (e.g., `pnpm add zod`) results in a corresponding reference file being added to `harness/references/`
- [ ] AC15: Removing a dependency results in its reference file being cleaned up from `harness/references/`
- [ ] AC16: Libraries with official llms.txt have that content fetched directly; libraries without llms.txt have agent-generated reference files from official documentation
