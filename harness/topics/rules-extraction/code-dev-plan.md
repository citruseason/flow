# Code Dev Plan: Rules Extraction

## Phase 1: Create CORE Documents

- What: Extract architecture, pipeline, and observability sections from PRODUCT.md into 3 new CORE documents
- Where: `harness/ARCHITECTURE.md`, `harness/PIPELINE.md`, `harness/OBSERVABILITY.md`
- How: Copy each section verbatim from PRODUCT.md lines 19-55 (architecture), 87-113 (pipeline), 167-222 (observability) into standalone files with appropriate top-level headings. Preserve Korean language.
- Verify:
  - ARCHITECTURE.md contains all subsections: 3-layer model, agent-skill separation, dependency direction, self-contained skills, model assignment
  - PIPELINE.md contains: sequential workflow, document flow, document history
  - OBSERVABILITY.md contains: logging format, log levels, logging rules, error propagation, metrics
  - No content lost compared to PRODUCT.md originals

## Phase 2: Create Rules Files

- What: Extract conventions section from PRODUCT.md into 12 domain+stack rule files
- Where: `harness/rules/` (new directory, 12 files)
- How: Split PRODUCT.md lines 115-165 (conventions section) by domain and stack. Each rule file gets a `# {Title}` heading and the relevant bullet points. Cross-reference the PRD R3.1-R3.5 for exact file-to-content mapping.
- Verify:
  - 12 files exist: naming.common, naming.javascript, naming.shell, formatting.javascript, formatting.shell, formatting.markdown, imports.javascript, error-handling.javascript, error-handling.shell, error-handling.agent, git, output-language
  - Each file is independently readable
  - All convention content from PRODUCT.md is present across the 12 files
  - No rule file references another rule file

## Phase 3: Reduce PRODUCT.md

- What: Remove extracted sections from PRODUCT.md and add a links section
- Where: `harness/PRODUCT.md`
- How: Delete architecture section (lines 19-55), pipeline section (lines 87-113), conventions section (lines 115-165), observability section (lines 167-222). Keep: overview, tech stack, agent table, skill table. Add a new section with links to ARCHITECTURE.md, PIPELINE.md, OBSERVABILITY.md, and harness/rules/.
- Verify:
  - PRODUCT.md has no architecture/pipeline/conventions/observability sections
  - PRODUCT.md has links to all 3 CORE docs and rules/
  - PRODUCT.md retains: overview, tech stack, agent table (7 agents), skill table (14 skills)

## Phase 4: Update lint-* Upstream References

- What: Change all upstream references in 4 lint-* skills from PRODUCT.md to new file paths
- Where: `.claude/skills/lint-architecture/SKILL.md`, `.claude/skills/lint-code-convention/SKILL.md`, `.claude/skills/lint-plugin-structure/SKILL.md`, `.claude/skills/lint-workflow-integrity/SKILL.md`
- How: Replace `harness/PRODUCT.md#architecture` with `harness/ARCHITECTURE.md` (or specific section). Replace `harness/PRODUCT.md#conventions` with the specific `harness/rules/*.md` file for each rule's domain.
- Verify:
  - No lint-* SKILL.md contains `harness/PRODUCT.md#architecture` or `harness/PRODUCT.md#conventions`
  - Every upstream reference points to an existing file
  - lint-architecture rules 1-4 point to ARCHITECTURE.md; rule 5 points to ARCHITECTURE.md#model-assignment
  - lint-code-convention rules point to specific rules/ files
  - lint-plugin-structure rules point to ARCHITECTURE.md or rules/ as appropriate
  - lint-workflow-integrity rules point to ARCHITECTURE.md or PIPELINE.md

## Phase 5: Update lint-manage

- What: Update lint-manage CORE Document Requirement to reflect new structure
- Where: `skills/lint-manage/SKILL.md`
- How: Update the CORE Document Requirement paragraph to list ARCHITECTURE.md, PIPELINE.md, OBSERVABILITY.md, and `harness/rules/` as valid upstream targets alongside existing CORE docs.
- Verify:
  - lint-manage mentions ARCHITECTURE.md, PIPELINE.md, OBSERVABILITY.md
  - lint-manage mentions harness/rules/ as upstream source
  - Existing functionality description is preserved

## Phase 6: Update CLAUDE.md Harness Section

- What: Add new CORE documents and rules/ reference to CLAUDE.md harness section
- Where: `CLAUDE.md` (between `<!-- harness:start -->` and `<!-- harness:end -->`)
- How: Add rows for ARCHITECTURE.md, PIPELINE.md, OBSERVABILITY.md to the CORE Documents table. Add a rules/ directory reference. Update PRODUCT.md purpose description to reflect reduced scope.
- Verify:
  - CORE Documents table lists PRODUCT.md, SECURITY.md, ARCHITECTURE.md, PIPELINE.md, OBSERVABILITY.md
  - Rules directory reference exists
  - Content outside harness markers is untouched
  - Harness section stays within 100-line limit

## Phase 7: Update harness-initializer Agent

- What: Update harness-initializer to generate new CORE structure and handle legacy migration
- Where: `agents/harness-initializer.md`
- How: In Phase 2, add generation steps for ARCHITECTURE.md, PIPELINE.md, OBSERVABILITY.md alongside PRODUCT.md. Add rules/ generation logic that creates domain+stack files based on detected stack. In Phase 6, add legacy detection (rules in PRODUCT.md) and migration to split structure.
- Verify:
  - Phase 2 mentions generating ARCHITECTURE.md, PIPELINE.md, OBSERVABILITY.md
  - Phase 2 mentions generating harness/rules/ files
  - Phase 6 handles legacy detection and migration
  - Existing phases are preserved
