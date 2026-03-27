# Blueprint: Rules Extraction

## Components

- **PRODUCT.md** -- Product definition (reduced to identity, stack, agents, skills, doc flow, links)
- **ARCHITECTURE.md** -- Architecture rules CORE document (3-layer model, separation, dependencies, model assignment)
- **PIPELINE.md** -- Pipeline rules CORE document (sequential workflow, execution boundaries, history FIFO)
- **OBSERVABILITY.md** -- Observability CORE document (logging, error propagation, metrics)
- **harness/rules/** -- 12 domain+stack rule files extracted from PRODUCT.md conventions section
- **lint-architecture** -- Lint skill with updated upstream refs to ARCHITECTURE.md
- **lint-code-convention** -- Lint skill with updated upstream refs to rules/*.md
- **lint-plugin-structure** -- Lint skill with updated upstream refs to ARCHITECTURE.md and rules/*.md
- **lint-workflow-integrity** -- Lint skill with updated upstream refs to ARCHITECTURE.md and PIPELINE.md
- **lint-manage** -- Lint skill manager with updated CORE document requirement list
- **harness-initializer** -- Agent updated to generate new CORE docs and rules/
- **CLAUDE.md harness section** -- Updated CORE document table and rules/ reference

## Connections

- PRODUCT.md --links to--> ARCHITECTURE.md, PIPELINE.md, OBSERVABILITY.md, harness/rules/
- lint-architecture --upstream--> ARCHITECTURE.md
- lint-code-convention --upstream--> harness/rules/naming.common.md, harness/rules/formatting.javascript.md, harness/rules/output-language.md (and other rules/*.md)
- lint-plugin-structure --upstream--> ARCHITECTURE.md, harness/rules/*.md
- lint-workflow-integrity --upstream--> ARCHITECTURE.md, PIPELINE.md
- lint-manage --references--> ARCHITECTURE.md, PIPELINE.md, OBSERVABILITY.md, harness/rules/
- harness-initializer --generates--> ARCHITECTURE.md, PIPELINE.md, OBSERVABILITY.md, harness/rules/
- CLAUDE.md --links to--> ARCHITECTURE.md, PIPELINE.md, OBSERVABILITY.md, harness/rules/

## External Boundaries

- No external systems involved. All changes are within the Flow plugin repository.
- All files are Markdown or JSON -- no runtime services affected.

## Rules File Inventory (12 files)

| File | Source Section |
|------|---------------|
| naming.common.md | PRODUCT.md conventions: naming (files, dirs, agent/skill names) |
| naming.javascript.md | PRODUCT.md conventions: naming (JS functions, constants) |
| naming.shell.md | PRODUCT.md conventions: naming (shell variables) |
| formatting.javascript.md | PRODUCT.md conventions: formatting + typing + comments (JS) |
| formatting.shell.md | PRODUCT.md conventions: formatting + comments (shell) |
| formatting.markdown.md | PRODUCT.md conventions: comments (markdown prompts) |
| imports.javascript.md | PRODUCT.md conventions: imports/exports |
| error-handling.javascript.md | PRODUCT.md conventions: error handling (JS) |
| error-handling.shell.md | PRODUCT.md conventions: error handling (shell) |
| error-handling.agent.md | PRODUCT.md conventions: error handling (agent/skill) |
| git.md | PRODUCT.md conventions: git |
| output-language.md | PRODUCT.md conventions: output language |
