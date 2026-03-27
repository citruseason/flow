# Spec: Rules Extraction

## Features

### F1. PRODUCT.md Reduction
- Remove architecture, pipeline, conventions, observability sections from PRODUCT.md
- Retain only: overview (name, version, description, type, license), tech stack, agent table (7), skill table (14), document flow diagram
- Add links section pointing to extracted documents

### F2. CORE Document Extraction
- Create `harness/ARCHITECTURE.md` from PRODUCT.md architecture section (3-layer model, agent-skill separation, dependency direction, self-contained skills, model assignment)
- Create `harness/PIPELINE.md` from PRODUCT.md pipeline section (sequential workflow, autonomous execution boundary, user approval gates, document history FIFO)
- Create `harness/OBSERVABILITY.md` from PRODUCT.md observability section (logging format, log levels, logging rules, error propagation, metrics)
- Zero information loss -- every line from removed sections exists in new files

### F3. Rules File Extraction
- Create `harness/rules/` directory with 12 domain+stack rule files
- Naming rules: `naming.common.md`, `naming.javascript.md`, `naming.shell.md`
- Formatting rules: `formatting.javascript.md`, `formatting.shell.md`, `formatting.markdown.md`
- Import rules: `imports.javascript.md`
- Error handling rules: `error-handling.javascript.md`, `error-handling.shell.md`, `error-handling.agent.md`
- Common rules: `git.md`, `output-language.md`
- Each file is self-contained (no cross-references to other rule files)
- File naming convention: `{domain}.{stack}.md` (stack-specific) / `{domain}.md` (common)

### F4. lint-* Upstream Reference Update
- Update all 4 lint-* skills: lint-architecture, lint-code-convention, lint-plugin-structure, lint-workflow-integrity
- Change `upstream:` fields from `harness/PRODUCT.md#architecture` to `harness/ARCHITECTURE.md`
- Change `upstream:` fields from `harness/PRODUCT.md#conventions` to specific `harness/rules/*.md` files
- Update lint-manage SKILL.md CORE Document Requirement description

### F5. CLAUDE.md Harness Section Update
- Add ARCHITECTURE.md, PIPELINE.md, OBSERVABILITY.md to CORE Documents table
- Add `harness/rules/` reference pointer

### F6. harness-initializer Agent Update
- Phase 2: add ARCHITECTURE.md, PIPELINE.md, OBSERVABILITY.md generation
- Add rules/ file generation logic (stack-dependent)
- Phase 6: add legacy migration (detect rules in PRODUCT.md, split into new structure)

## Interfaces

### File Inputs (read)
- `harness/PRODUCT.md` -- source of all content to extract
- `.claude/skills/lint-*/SKILL.md` -- 4 lint skill files to update upstream refs
- `skills/lint-manage/SKILL.md` -- lint-manage to update CORE doc description
- `agents/harness-initializer.md` -- agent to update with new structure
- `CLAUDE.md` -- harness section to update

### File Outputs (write/modify)
- `harness/PRODUCT.md` -- reduced (sections removed, links added)
- `harness/ARCHITECTURE.md` -- new CORE document
- `harness/PIPELINE.md` -- new CORE document
- `harness/OBSERVABILITY.md` -- new CORE document
- `harness/rules/*.md` -- 12 new rule files
- `.claude/skills/lint-architecture/SKILL.md` -- updated upstream
- `.claude/skills/lint-code-convention/SKILL.md` -- updated upstream
- `.claude/skills/lint-plugin-structure/SKILL.md` -- updated upstream
- `.claude/skills/lint-workflow-integrity/SKILL.md` -- updated upstream
- `skills/lint-manage/SKILL.md` -- updated CORE doc description
- `agents/harness-initializer.md` -- updated phases
- `CLAUDE.md` -- updated harness section

## Data Models

### Rule File Structure
| Field | Type | Description |
|-------|------|-------------|
| title | string | `# {Domain} Rules: {Stack}` or `# {Domain} Rules` |
| rules | list | Bulleted rule items, each self-contained |

### CORE Document Structure
| Field | Type | Description |
|-------|------|-------------|
| title | string | `# {Section Name}` matching original PRODUCT.md heading |
| sections | list | Subsections preserved exactly as in PRODUCT.md |

### Upstream Reference
| Field | Type | Description |
|-------|------|-------------|
| path | string | `harness/ARCHITECTURE.md`, `harness/PIPELINE.md`, or `harness/rules/{file}.md` |
| section | string | Optional `#section` anchor |

## Constraints

- No content changes -- only structural moves (content is identical before and after)
- No SECURITY.md modifications
- No new rules added -- only existing rules relocated
- Each rule file must be independently readable without referencing other rule files
- PRODUCT.md retains Korean language (matching current state)
- New CORE documents (ARCHITECTURE.md, PIPELINE.md, OBSERVABILITY.md) retain Korean language
- Rule files retain Korean language
- CLAUDE.md harness section retains Korean language
- All 12 rule files must exist after completion
- All upstream references in lint-* skills must point to valid file paths
- lint-manage CORE Document Requirement must list new CORE documents (ARCHITECTURE.md, PIPELINE.md, OBSERVABILITY.md) and rules/ directory
- harness-initializer must generate new CORE docs in Phase 2 and handle legacy migration in Phase 6
