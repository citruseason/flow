#!/usr/bin/env bash
# Tier 3: Quality benchmark - grade skill outputs against quality criteria
# Must be run AFTER tests/scenarios/todo-cli/run.sh
# Usage: bash tests/benchmark/grade.sh
set -euo pipefail

FLOW_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
WORK_DIR="$FLOW_DIR/tests/scenarios/todo-cli/workspace"
RESULTS_DIR="$FLOW_DIR/tests/benchmark/results"
REPORT="$RESULTS_DIR/quality-report.json"

if [ ! -d "$WORK_DIR" ]; then
  echo "ERROR: Workspace not found. Run tests/scenarios/todo-cli/run.sh first."
  exit 1
fi

PASS=0
FAIL=0
RESULTS=()

check() {
  local skill="$1" desc="$2" result="$3"
  if [ "$result" = "pass" ]; then
    PASS=$((PASS + 1))
    RESULTS+=("{\"skill\":\"$skill\",\"check\":\"$desc\",\"status\":\"pass\"}")
  else
    FAIL=$((FAIL + 1))
    RESULTS+=("{\"skill\":\"$skill\",\"check\":\"$desc\",\"status\":\"fail\"}")
    echo "FAIL [$skill]: $desc"
  fi
}

echo "=== Quality Benchmark ==="
echo ""

# --- /spec quality ---
echo "Grading /spec output..."
SPEC_FILE=$(find "$WORK_DIR/docs/specs" -name "*.md" -type f 2>/dev/null | head -1 || true)
if [ -n "$SPEC_FILE" ] && [ -f "$SPEC_FILE" ]; then
  # Check required sections
  for section in "Overview" "Architecture" "Error" "Test"; do
    if grep -qi "$section" "$SPEC_FILE" 2>/dev/null; then
      check "spec" "has $section section" "pass"
    else
      check "spec" "has $section section" "fail"
    fi
  done
  # Check no TODO/TBD
  if grep -qi "TODO\|TBD" "$SPEC_FILE" 2>/dev/null; then
    check "spec" "no TODO/TBD placeholders" "fail"
  else
    check "spec" "no TODO/TBD placeholders" "pass"
  fi
  # Check minimum length (a real spec should be at least 500 chars)
  SPEC_LEN=$(wc -c < "$SPEC_FILE")
  if [ "$SPEC_LEN" -gt 500 ]; then
    check "spec" "sufficient detail (>500 chars)" "pass"
  else
    check "spec" "sufficient detail (>500 chars)" "fail"
  fi
else
  check "spec" "spec file exists" "fail"
  echo "  Skipping /spec quality checks - no spec file found"
fi

# --- /plan quality ---
echo "Grading /plan output..."
PLAN_FILE=$(find "$WORK_DIR/docs/plans" -name "*.md" -type f 2>/dev/null | head -1 || true)
if [ -n "$PLAN_FILE" ] && [ -f "$PLAN_FILE" ]; then
  # Check for file paths in steps
  if grep -qE "File:|path/|\.ts|\.js|\.md" "$PLAN_FILE" 2>/dev/null; then
    check "plan" "steps have file paths" "pass"
  else
    check "plan" "steps have file paths" "fail"
  fi
  # Check for dependencies
  if grep -qi "dependenc\|requires\|after step\|phase" "$PLAN_FILE" 2>/dev/null; then
    check "plan" "dependencies stated" "pass"
  else
    check "plan" "dependencies stated" "fail"
  fi
  # Check for phases
  if grep -qi "phase\|step" "$PLAN_FILE" 2>/dev/null; then
    check "plan" "phased breakdown" "pass"
  else
    check "plan" "phased breakdown" "fail"
  fi
  # Check for testing strategy
  if grep -qi "test" "$PLAN_FILE" 2>/dev/null; then
    check "plan" "testing strategy included" "pass"
  else
    check "plan" "testing strategy included" "fail"
  fi
  # Check minimum length
  PLAN_LEN=$(wc -c < "$PLAN_FILE")
  if [ "$PLAN_LEN" -gt 500 ]; then
    check "plan" "sufficient detail (>500 chars)" "pass"
  else
    check "plan" "sufficient detail (>500 chars)" "fail"
  fi
else
  check "plan" "plan file exists" "fail"
  echo "  Skipping /plan quality checks - no plan file found"
fi

# --- /tdd quality ---
echo "Grading /tdd output..."
TEST_FILES=$(find "$WORK_DIR" -name "*.test.*" -o -name "*.spec.*" 2>/dev/null | grep -v node_modules | grep -v ".git" || true)
IMPL_FILES=$(find "$WORK_DIR/src" -name "*.js" -o -name "*.ts" 2>/dev/null | grep -v node_modules | grep -v ".git" 2>/dev/null || true)
if [ -n "$TEST_FILES" ]; then
  check "tdd" "test files exist" "pass"
else
  check "tdd" "test files exist" "fail"
fi
if [ -n "$IMPL_FILES" ] || find "$WORK_DIR" -maxdepth 2 -name "*.js" -not -path "*/node_modules/*" 2>/dev/null | grep -q .; then
  check "tdd" "implementation files exist" "pass"
else
  check "tdd" "implementation files exist" "fail"
fi
# Check if package.json has test script
if [ -f "$WORK_DIR/package.json" ] && grep -q '"test"' "$WORK_DIR/package.json" 2>/dev/null; then
  check "tdd" "package.json has test script" "pass"
else
  check "tdd" "package.json has test script" "fail"
fi

# --- /amend quality ---
echo "Grading /amend output..."
# Check if spec was updated with priority content
if [ -n "$SPEC_FILE" ] && [ -f "$SPEC_FILE" ] && grep -qi "priorit" "$SPEC_FILE" 2>/dev/null; then
  check "amend" "spec updated with priority feature" "pass"
else
  check "amend" "spec updated with priority feature" "fail"
fi
# Check if any source file mentions priority
if grep -rqi "priorit" "$WORK_DIR" --include="*.js" --include="*.ts" --exclude-dir=node_modules --exclude-dir=.git 2>/dev/null; then
  check "amend" "implementation includes priority" "pass"
else
  check "amend" "implementation includes priority" "fail"
fi

# --- /code-review quality ---
echo "Grading /code-review output..."
REVIEW_OUTPUT="$WORK_DIR/.test-output-05-code-review.txt"
if [ -f "$REVIEW_OUTPUT" ]; then
  # Check severity classifications
  if grep -qi "CRITICAL\|HIGH\|MEDIUM\|LOW" "$REVIEW_OUTPUT" 2>/dev/null; then
    check "code-review" "severity classifications present" "pass"
  else
    check "code-review" "severity classifications present" "fail"
  fi
  # Check file references
  if grep -qE "\.(js|ts|json):" "$REVIEW_OUTPUT" 2>/dev/null || grep -qi "file:" "$REVIEW_OUTPUT" 2>/dev/null; then
    check "code-review" "file references included" "pass"
  else
    check "code-review" "file references included" "fail"
  fi
  # Check summary
  if grep -qi "summary\|verdict\|approve" "$REVIEW_OUTPUT" 2>/dev/null; then
    check "code-review" "summary/verdict present" "pass"
  else
    check "code-review" "summary/verdict present" "fail"
  fi
else
  check "code-review" "review output exists" "fail"
  echo "  Skipping /code-review quality checks - no output found"
fi

# --- Output ---
TOTAL=$((PASS + FAIL))
echo ""
echo "=== Quality Benchmark ==="
echo "PASS: $PASS / $TOTAL"
echo "FAIL: $FAIL / $TOTAL"
echo "Score: $(echo "scale=1; $PASS * 100 / $TOTAL" | bc)%"

# Write JSON report
mkdir -p "$RESULTS_DIR"
echo "{" > "$REPORT"
echo "  \"total\": $TOTAL," >> "$REPORT"
echo "  \"pass\": $PASS," >> "$REPORT"
echo "  \"fail\": $FAIL," >> "$REPORT"
echo "  \"score_percent\": $(echo "scale=1; $PASS * 100 / $TOTAL" | bc)," >> "$REPORT"
echo "  \"checks\": [" >> "$REPORT"
for i in "${!RESULTS[@]}"; do
  if [ $i -lt $((${#RESULTS[@]} - 1)) ]; then
    echo "    ${RESULTS[$i]}," >> "$REPORT"
  else
    echo "    ${RESULTS[$i]}" >> "$REPORT"
  fi
done
echo "  ]" >> "$REPORT"
echo "}" >> "$REPORT"

echo "Report: $REPORT"
