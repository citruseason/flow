#!/usr/bin/env bash
# PostToolUse hook: Detect git merge/pull and trigger /core-update for completed topics
set +e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(cd "$SCRIPT_DIR/../.." && pwd)}"

# Read stdin JSON
INPUT=$(cat)

# Extract the command that was executed
COMMAND=$(echo "$INPUT" | node -e "
  let d='';process.stdin.on('data',c=>d+=c);process.stdin.on('end',()=>{
    try{const j=JSON.parse(d);console.log(j.tool_input&&j.tool_input.command||'')}catch(e){console.log('')}
  });
" 2>/dev/null)

if [[ -z "$COMMAND" ]]; then
  exit 0
fi

# Extract branch name from merge command
# Patterns: "git merge feature/<topic>", "git merge origin/feature/<topic>"
TOPIC=""
if echo "$COMMAND" | grep -q "git merge"; then
  BRANCH=$(echo "$COMMAND" | grep -oE 'feature/[^ ]+' | head -1)
  TOPIC="${BRANCH#feature/}"
elif echo "$COMMAND" | grep -q "git pull"; then
  # For git pull, check the last merged branch from git log
  BRANCH=$(cd "$PROJECT_DIR" && git log -1 --merges --format="%s" 2>/dev/null | grep -oE 'feature/[^ ]+' | head -1)
  TOPIC="${BRANCH#feature/}"
fi

if [[ -z "$TOPIC" ]]; then
  exit 0
fi

# Check if topic exists and lint is done
TOPIC_KANBAN="${PROJECT_DIR}/harness/topics/${TOPIC}/kanban.json"

if [[ ! -f "$TOPIC_KANBAN" ]]; then
  exit 0
fi

LINT_DONE=$(node -e "
  const fs=require('fs');
  try{
    const k=JSON.parse(fs.readFileSync('${TOPIC_KANBAN}','utf8'));
    const done=k.steps&&k.steps.done||[];
    const hasLint=done.some(s=>s.id==='lint');
    console.log(hasLint?'true':'false');
  }catch(e){console.log('false')}
" 2>/dev/null)

if [[ "$LINT_DONE" != "true" ]]; then
  exit 0
fi

echo "[Flow] Topic ${TOPIC} merged. Running /core-update ${TOPIC} automatically."

exit 0
