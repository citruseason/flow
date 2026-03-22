# Flow Plugin Tests

## Quick Start

```bash
# Tier 1: Structural validation (instant)
bash tests/structural/validate.sh

# Tier 2: E2E scenario test (requires claude -p, takes several minutes)
bash tests/scenarios/todo-cli/run.sh

# Tier 3: Quality benchmark (run after Tier 2)
bash tests/benchmark/grade.sh
```

## Test Tiers

### Tier 1: Structural Validation
Verifies plugin integrity: skill/agent files exist, frontmatter valid, references consistent, no stale paths.

### Tier 2: Execution Scenarios
Runs the full `/spec` -> `/plan` -> `/tdd` -> `/amend` -> `/code-review` flow on a Todo CLI app project using `claude -p`.

### Tier 3: Quality Benchmark
Grades each skill's output against quality criteria (spec completeness, plan actionability, TDD compliance, etc.).

## Results

All reports are saved to `tests/benchmark/results/`:
- `structural-report.json` - Tier 1
- `scenario-report.json` - Tier 2
- `quality-report.json` - Tier 3
