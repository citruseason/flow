# Test Cases: Rules Extraction

## Unit Tests

| ID | Scenario | Input | Expected Output |
|----|----------|-------|-----------------|
| U-001 | ARCHITECTURE.md contains 3-layer model | Read ARCHITECTURE.md | Contains "skills/", "agents/", "scripts/" layer descriptions |
| U-002 | ARCHITECTURE.md contains agent-skill separation | Read ARCHITECTURE.md | Contains agent execution vs skill orchestration rules |
| U-003 | ARCHITECTURE.md contains dependency direction | Read ARCHITECTURE.md | Contains "skills -> agents -> references" flow rule |
| U-004 | ARCHITECTURE.md contains self-contained skills | Read ARCHITECTURE.md | Contains SKILL.md, frontmatter, references/ requirements |
| U-005 | ARCHITECTURE.md contains model assignment | Read ARCHITECTURE.md | Contains Opus for writers, Sonnet for reviewers |
| U-006 | PIPELINE.md contains sequential workflow | Read PIPELINE.md | Contains "/harness-init -> /meeting -> /design-doc -> /implement -> /lint" |
| U-007 | PIPELINE.md contains autonomous execution boundary | Read PIPELINE.md | Contains implement-to-lint autonomous, meeting/design-doc user-gated |
| U-008 | PIPELINE.md contains document history FIFO | Read PIPELINE.md | Contains v1 = most recent prior, v2 = older, max 2 |
| U-009 | OBSERVABILITY.md contains logging format | Read OBSERVABILITY.md | Contains JSON logging format with type/source fields |
| U-010 | OBSERVABILITY.md contains log levels | Read OBSERVABILITY.md | Contains ERROR, WARN, INFO, DEBUG levels |
| U-011 | OBSERVABILITY.md contains error propagation | Read OBSERVABILITY.md | Contains agent/server/shell/review/implement error flows |
| U-012 | OBSERVABILITY.md contains metrics | Read OBSERVABILITY.md | Contains "no metrics instrumentation" statement |
| U-013 | naming.common.md is self-contained | Read naming.common.md | File/directory kebab-case, agent/skill names; no references to other rule files |
| U-014 | naming.javascript.md is self-contained | Read naming.javascript.md | camelCase functions, UPPER_SNAKE_CASE constants; no references to other rule files |
| U-015 | naming.shell.md is self-contained | Read naming.shell.md | UPPER_SNAKE_CASE variables; no references to other rule files |
| U-016 | formatting.javascript.md covers all JS conventions | Read formatting.javascript.md | Indentation, semicolons, quotes, trailing commas, typing N/A, JS comments |
| U-017 | formatting.shell.md covers all shell conventions | Read formatting.shell.md | `[[ ]]`, `$()`, shebang, shell comments |
| U-018 | formatting.markdown.md covers markdown conventions | Read formatting.markdown.md | `##` sections, code blocks, tables, line length |
| U-019 | imports.javascript.md covers imports | Read imports.javascript.md | CommonJS, no ES modules, built-in first ordering |
| U-020 | error-handling.javascript.md covers JS errors | Read error-handling.javascript.md | try/catch, console.error, no propagation |
| U-021 | error-handling.shell.md covers shell errors | Read error-handling.shell.md | JSON error output, exit 1 |
| U-022 | error-handling.agent.md covers agent errors | Read error-handling.agent.md | PASS/WARNING/FAIL structured output, escalation |
| U-023 | git.md covers all git rules | Read git.md | Conventional Commits, branch naming, version sync, patch-only |
| U-024 | output-language.md covers language rules | Read output-language.md | CLAUDE.md language setting, English default |
| U-025 | PRODUCT.md has no architecture section | Read PRODUCT.md | No "## Architecture" heading (except agent/skill tables that were retained) |
| U-026 | PRODUCT.md has no pipeline section | Read PRODUCT.md | No "## Pipeline" heading |
| U-027 | PRODUCT.md has no conventions section | Read PRODUCT.md | No "## Rules" heading |
| U-028 | PRODUCT.md has no observability section | Read PRODUCT.md | No "## Observability" heading |
| U-029 | PRODUCT.md retains overview | Read PRODUCT.md | Contains name, version, description, type, license |
| U-030 | PRODUCT.md retains tech stack | Read PRODUCT.md | Contains language, framework, libraries, build, test sections |
| U-031 | PRODUCT.md retains agent table | Read PRODUCT.md | 7 agents listed in table |
| U-032 | PRODUCT.md retains skill table | Read PRODUCT.md | 14 skills listed in table |
| U-033 | PRODUCT.md has links section | Read PRODUCT.md | Links to ARCHITECTURE.md, PIPELINE.md, OBSERVABILITY.md, rules/ |
| U-034 | lint-architecture upstream updated | Read lint-architecture/SKILL.md | All upstream refs point to harness/ARCHITECTURE.md, not harness/PRODUCT.md |
| U-035 | lint-code-convention upstream updated | Read lint-code-convention/SKILL.md | Upstream refs point to harness/rules/*.md files, not harness/PRODUCT.md |
| U-036 | lint-plugin-structure upstream updated | Read lint-plugin-structure/SKILL.md | Upstream refs point to harness/ARCHITECTURE.md or harness/rules/*.md |
| U-037 | lint-workflow-integrity upstream updated | Read lint-workflow-integrity/SKILL.md | Upstream refs point to harness/ARCHITECTURE.md or harness/PIPELINE.md |
| U-038 | lint-manage lists new CORE docs | Read lint-manage/SKILL.md | Mentions ARCHITECTURE.md, PIPELINE.md, OBSERVABILITY.md, rules/ |

## Integration Tests

| ID | Scenario | Steps | Expected Result |
|----|----------|-------|-----------------|
| I-001 | CORE doc completeness | 1. Concatenate ARCHITECTURE.md + PIPELINE.md + OBSERVABILITY.md 2. Compare against original PRODUCT.md architecture + pipeline + observability sections | All original content present in new files |
| I-002 | Rules file completeness | 1. Concatenate all 12 rules/*.md files 2. Compare against original PRODUCT.md conventions section | All convention rules present across rule files |
| I-003 | Zero information loss | 1. Read original PRODUCT.md (pre-change) 2. Read reduced PRODUCT.md + all new files 3. Verify union contains all original content | No content lost |
| I-004 | lint-* upstream resolution | 1. Read all 4 lint-* SKILL.md files 2. Extract all upstream paths 3. Verify each path exists on disk | All upstream references resolve to existing files |
| I-005 | CLAUDE.md harness section validity | 1. Read CLAUDE.md 2. Parse harness section between markers 3. Verify CORE table has 5 entries 4. Verify rules/ reference | Harness section lists all CORE docs and rules/ |
| I-006 | harness-initializer Phase 2 coverage | 1. Read harness-initializer.md 2. Check Phase 2 for ARCHITECTURE.md, PIPELINE.md, OBSERVABILITY.md, rules/ | All new document types are mentioned in Phase 2 |
| I-007 | harness-initializer Phase 6 migration | 1. Read harness-initializer.md 2. Check Phase 6 for legacy detection and migration | Phase 6 handles rules-in-PRODUCT.md legacy case |
| I-008 | Cross-document naming consistency | 1. Collect all file references across PRODUCT.md, CLAUDE.md, lint-* skills, harness-initializer 2. Verify consistent naming | ARCHITECTURE.md, PIPELINE.md, OBSERVABILITY.md spelled identically everywhere |
| I-009 | Rules file count | 1. List files in harness/rules/ 2. Count .md files | Exactly 12 files |

## E2E Tests

| ID | Scenario | Action | Expected Outcome |
|----|----------|--------|------------------|
| E-001 | Post-extraction lint pass | Run all 4 lint-* skills against the modified codebase | All lint-* skills pass (no FAIL findings related to upstream references) |
| E-002 | PRODUCT.md is valid standalone | Read reduced PRODUCT.md top to bottom | Document reads coherently: overview, stack, agents, skills, links. No dangling references to removed sections. |
| E-003 | Rule file standalone readability | Read any single rules/*.md file without context | File is understandable in isolation -- contains heading, rules, and examples |
| E-004 | lint-manage CORE alignment | Run lint-manage CORE-Lint alignment check | All lint rules have valid upstream references to existing files |
| E-005 | harness-initializer fresh run | Simulate harness-initializer Phase 2 output list | Output includes ARCHITECTURE.md, PIPELINE.md, OBSERVABILITY.md, and rules/ files |
| E-006 | No SECURITY.md changes | Diff SECURITY.md before and after | Zero diff -- file is untouched |
