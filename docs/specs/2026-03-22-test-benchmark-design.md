# Flow Plugin Test & Benchmark Design Spec

## Overview

Three-tier test system to prove Flow plugin works in practice: structural validation, execution scenarios, and quality benchmarking. Uses a "Todo CLI app" as the end-to-end test scenario.

## Test Tiers

### Tier 1: Structural Validation

Programmatic checks that run instantly:

- All 5 skills have SKILL.md with valid frontmatter (name, description)
- All 7 agents have .md with valid frontmatter (name, description, tools, model)
- Skill-to-agent dispatch references are valid (referenced agents exist)
- File path references within skills/agents resolve to real files
- plugin.json agents array matches actual agent files
- No stale references to deleted entities (`/brainstorm`, `brainstorming/`, `commands/`, `tdd-workflow`)

### Tier 2: Execution Scenarios

Sequential `claude -p` runs with the Flow plugin loaded:

1. `/spec` with "Node.js Todo CLI app" prompt -> verify spec document created in `docs/specs/`
2. `/plan` with the generated spec path -> verify plan document created in `docs/plans/`
3. `/tdd` -> verify test and implementation files created
4. `/amend` with "add priority feature" -> verify spec/plan updated + implementation
5. `/code-review` -> verify review report generated

Each step captures: success/failure, duration, token usage, output files.

### Tier 3: Quality Benchmark

Grade each skill's output against quality criteria:

| Skill | Assertions |
|-------|-----------|
| `/spec` | Has Overview section, Has Architecture section, Has Error handling, Has Testing approach, No TODO/TBD placeholders, Internal consistency |
| `/plan` | All steps have file paths, Dependencies stated, Phases independently deliverable, Testing strategy included, Success criteria present |
| `/tdd` | Test files exist, Tests written before implementation (git log order), Coverage target mentioned |
| `/amend` | Spec document updated with new content, Plan document updated, Implementation reflects changes |
| `/code-review` | Severity classifications present, File/line references included, Summary table present |

## Test Scenario: Todo CLI App

```
Prompt 1 (/spec): "Node.js로 간단한 Todo CLI 앱. 할일 추가/삭제/목록/완료 기능. JSON 파일에 저장."
Prompt 2 (/plan): "<path to spec from step 1>"
Prompt 3 (/tdd): "플랜에 따라 TDD로 구현해줘"
Prompt 4 (/amend): "할일에 우선순위(high/medium/low) 기능을 추가해줘"
Prompt 5 (/code-review): "변경사항 리뷰해줘"
```

## File Structure

```
tests/
├── structural/
│   └── validate.sh
├── scenarios/
│   └── todo-cli/
│       ├── run.sh
│       └── prompts/
│           ├── 01-spec.txt
│           ├── 02-plan.txt
│           ├── 03-tdd.txt
│           ├── 04-amend.txt
│           └── 05-code-review.txt
├── benchmark/
│   ├── grade.sh
│   └── results/
└── README.md
```

## Execution

1. `bash tests/structural/validate.sh` -- instant structural checks
2. `bash tests/scenarios/todo-cli/run.sh` -- end-to-end flow (uses claude -p)
3. `bash tests/benchmark/grade.sh` -- quality grading of outputs

## Output

```
tests/benchmark/results/
├── structural-report.json
├── scenario-report.json
├── quality-report.json
└── benchmark.md
```
