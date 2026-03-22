#!/usr/bin/env bash
# Tier 1: Structural validation for Flow plugin
# Usage: bash tests/structural/validate.sh
set -euo pipefail

FLOW_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
PASS=0
FAIL=0
RESULTS=()

check() {
  local desc="$1" result="$2"
  if [ "$result" = "pass" ]; then
    PASS=$((PASS + 1))
    RESULTS+=("{\"check\":\"$desc\",\"status\":\"pass\"}")
  else
    FAIL=$((FAIL + 1))
    RESULTS+=("{\"check\":\"$desc\",\"status\":\"fail\"}")
    echo "FAIL: $desc"
  fi
}

# --- Skills ---
EXPECTED_SKILLS=("spec" "plan" "tdd" "amend" "code-review")
for skill in "${EXPECTED_SKILLS[@]}"; do
  if [ -f "$FLOW_DIR/skills/$skill/SKILL.md" ]; then
    check "skill/$skill/SKILL.md exists" "pass"
    # Check frontmatter has name field
    if head -10 "$FLOW_DIR/skills/$skill/SKILL.md" | grep -q "^name:"; then
      check "skill/$skill has name in frontmatter" "pass"
    else
      check "skill/$skill has name in frontmatter" "fail"
    fi
    # Check frontmatter has description field
    if head -10 "$FLOW_DIR/skills/$skill/SKILL.md" | grep -q "^description:"; then
      check "skill/$skill has description in frontmatter" "pass"
    else
      check "skill/$skill has description in frontmatter" "fail"
    fi
  else
    check "skill/$skill/SKILL.md exists" "fail"
  fi
done

# --- Agents ---
EXPECTED_AGENTS=("design-facilitator" "spec-reviewer" "planner" "plan-reviewer" "tdd-guide" "code-reviewer" "amender")
for agent in "${EXPECTED_AGENTS[@]}"; do
  if [ -f "$FLOW_DIR/agents/$agent.md" ]; then
    check "agent/$agent.md exists" "pass"
    if head -10 "$FLOW_DIR/agents/$agent.md" | grep -q "^name:"; then
      check "agent/$agent has name in frontmatter" "pass"
    else
      check "agent/$agent has name in frontmatter" "fail"
    fi
  else
    check "agent/$agent.md exists" "fail"
  fi
done

# --- plugin.json ---
PLUGIN_JSON="$FLOW_DIR/.claude-plugin/plugin.json"
if [ -f "$PLUGIN_JSON" ]; then
  check "plugin.json exists" "pass"
  # Verify all agents in plugin.json exist on disk
  for agent in "${EXPECTED_AGENTS[@]}"; do
    if grep -q "$agent.md" "$PLUGIN_JSON"; then
      check "plugin.json references agent/$agent" "pass"
    else
      check "plugin.json references agent/$agent" "fail"
    fi
  done
  # Verify no commands entry
  if grep -q '"commands"' "$PLUGIN_JSON"; then
    check "plugin.json has no commands entry" "fail"
  else
    check "plugin.json has no commands entry" "pass"
  fi
else
  check "plugin.json exists" "fail"
fi

# --- No stale references ---
STALE_PATTERNS=("/brainstorm " "/brainstorm\"" "brainstorming/" "commands/" "tdd-workflow")
for pattern in "${STALE_PATTERNS[@]}"; do
  # Search active files only (exclude docs/, .git/)
  matches=$(grep -r "$pattern" "$FLOW_DIR" \
    --include="*.md" --include="*.json" --include="*.sh" --include="*.js" --include="*.cjs" --include="*.html" \
    -l 2>/dev/null | grep -v "docs/" | grep -v ".git/" | grep -v "tests/" || true)
  if [ -z "$matches" ]; then
    check "no stale reference: $pattern" "pass"
  else
    check "no stale reference: $pattern" "fail"
    echo "  Found in: $matches"
  fi
done

# --- Path references ---
# Check visual-companion.md exists where spec skill references it
if [ -f "$FLOW_DIR/skills/spec/visual-companion.md" ]; then
  check "skills/spec/visual-companion.md exists" "pass"
else
  check "skills/spec/visual-companion.md exists" "fail"
fi
# Check scripts exist
for script in start-server.sh stop-server.sh; do
  if [ -f "$FLOW_DIR/skills/spec/scripts/$script" ]; then
    check "skills/spec/scripts/$script exists" "pass"
  else
    check "skills/spec/scripts/$script exists" "fail"
  fi
done

# --- Commands directory should not exist ---
if [ -d "$FLOW_DIR/commands" ]; then
  check "commands/ directory deleted" "fail"
else
  check "commands/ directory deleted" "pass"
fi

# --- Output ---
TOTAL=$((PASS + FAIL))
echo ""
echo "=== Structural Validation ==="
echo "PASS: $PASS / $TOTAL"
echo "FAIL: $FAIL / $TOTAL"

# Write JSON report
REPORT="$FLOW_DIR/tests/benchmark/results/structural-report.json"
mkdir -p "$(dirname "$REPORT")"
echo "{" > "$REPORT"
echo "  \"total\": $TOTAL," >> "$REPORT"
echo "  \"pass\": $PASS," >> "$REPORT"
echo "  \"fail\": $FAIL," >> "$REPORT"
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
exit $FAIL
