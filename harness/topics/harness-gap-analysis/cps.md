# CPS: Harness Gap Analysis

## Context

Flow is a Claude Code plugin implementing the Harness Engineering methodology. An analysis comparing Flow against the original OpenAI Harness Engineering article revealed 16 gaps across knowledge base structure, execution autonomy, tooling, and quality systems.

Two critical gaps stand out:

1. **No CORE knowledge layer:** When `/meeting` and `/design-doc` produce requirements and design documents, the knowledge stays siloed in topic directories. There is no project-level knowledge accumulation. Agents working on a new topic have no way to understand the product holistically without reading every past topic.

2. **No agent entry point:** Flow does not touch the user project's CLAUDE.md. There is no lightweight map that lets agents quickly understand what the project is, what design decisions have been made, and where to find deeper context. The original article emphasizes that a monolithic instructions file fails — agents need a short map (~100 lines) pointing to structured, deeper sources.

Additionally, the current `harness/` structure uses monolithic cross-cutting files (`golden-rules.md`, `observability.md`) instead of domain-specific documents. This makes it harder for agents to load only the context relevant to their current task.

## Problem

1. **Agents cannot quickly understand user projects.** Without CORE domain documents and a CLAUDE.md map, agents must either receive excessive context (entire harness/) or insufficient context (nothing), with no middle ground for progressive disclosure.

2. **Product knowledge does not accumulate.** Design decisions, product definitions, security principles, UI/UX direction — all remain locked in per-topic documents. There is no single source of truth at the product level that grows as topics are completed and merged.

3. **Knowledge structure is not domain-oriented.** Files like `golden-rules.md` and `observability.md` mix concerns from multiple domains. Agents working on frontend tasks must parse backend rules and vice versa. This wastes context and increases error risk.

4. **Lint skills lack an authoritative upstream source.** Current lint rules are generated from code pattern detection during `/harness-init`. They capture "what is" but not "what should be." Without CORE domain documents defining design intent, lint skills cannot distinguish intentional patterns from accidental ones.

5. **External references are not managed.** The `harness/references/` directory is empty. Agents working with project dependencies (frameworks, libraries, design systems) have no curated reference material. They must rely on training data or fetch documentation on the fly, leading to inconsistent or outdated knowledge about the tools the project uses.

## Solution

### 1. Introduce CORE Domain Documents at `harness/` Root

Add product-level knowledge documents directly under `harness/`:

- **Always generated:** `PRODUCT.md` (product definition, purpose, users, core value), `SECURITY.md` (security principles and constraints)
- **Conditionally generated** based on project analysis: `DESIGN.md` (UI/UX direction, design system, brand), `FRONTEND.md` (frontend tech rules, component patterns, observability), `BACKEND.md` (backend tech rules, API patterns, logging/metrics), `BATCH.md`, `INFRA.md`, `DATA.md`, etc.

Documents are product-level, not per-app. Even in monorepos, CORE represents the whole product.

### 2. Add Harness Map Section to CLAUDE.md

During `/harness-init`, automatically add a harness section to the user project's CLAUDE.md that:
- Describes the project at a glance (from PRODUCT.md)
- Lists available CORE domain documents with one-line descriptions
- Acts as a lightweight map (100 lines or fewer) for progressive disclosure
- Points agents to specific domain docs based on their task

### 3. Restructure `harness/` by Removing Legacy Files

- `index.md` → removed (CLAUDE.md takes over)
- `golden-rules.md` → rules distributed to relevant domain documents
- `observability.md` → absorbed into domain documents (FRONTEND.md, BACKEND.md, etc.)
- `quality-score.md` and `tech-debt.md` → retained as cross-cutting operational documents

### 4. CORE as Upstream Source for Lint Skills

CORE domain documents define "why and what" (design decisions). Lint skills reference CORE to generate "how" (mechanical checks). When CORE is updated, affected lint rules are updated accordingly.

### 5. Merge-Time CORE Update Trigger

CORE documents are updated when code is actually merged — not at meeting or design-doc completion. Only realized facts enter CORE, ensuring it remains a trusted source of truth.

### 6. Automated Reference Management

`harness/references/` becomes an actively managed directory of external reference material:

- **Initial collection:** `/harness-init` analyzes project dependencies (package.json, pyproject.toml, etc.) and automatically collects reference material for major libraries and frameworks. Where a library provides an official llms.txt, it is fetched directly. Where llms.txt is unavailable, the agent extracts key content from official documentation to generate a reference file.
- **Manual addition:** Users can add references at any time (e.g., design system documentation, internal API specs).
- **Ongoing maintenance:** When new dependencies are added during development, references are automatically collected and added. Stale references for removed dependencies are cleaned up.

### 7. No Dedicated OBSERVABILITY.md

Observability concerns (logging, metrics, tracing, error tracking) are domain-specific: frontend error tracking belongs in FRONTEND.md, backend logging/metrics belongs in BACKEND.md, etc. Rather than creating a separate OBSERVABILITY.md, observability content is included within each relevant domain document. This is a distinct decision from the legacy migration of the existing `harness/observability.md` file (Solution 3), which also distributes its content to domain documents.
