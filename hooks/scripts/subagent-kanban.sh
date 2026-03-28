#!/usr/bin/env bash
# SubagentStop hook: Auto-update kanban.json step transitions during implement phase
# Reads stdin JSON for agent_name and exit_reason
# Only operates when a topic is in implement phase
set +e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(cd "$SCRIPT_DIR/../.." && pwd)}"
ROOT_KANBAN="${PROJECT_DIR}/harness/kanban.json"

# Read stdin JSON
INPUT=$(cat)

# Extract exit_reason using Node.js inline
EXIT_REASON=$(echo "$INPUT" | node -e "
  let d='';process.stdin.on('data',c=>d+=c);process.stdin.on('end',()=>{
    try{const j=JSON.parse(d);console.log(j.exit_reason||'')}catch(e){console.log('')}
  });
" 2>/dev/null)

# Skip if agent failed
if [[ -n "$EXIT_REASON" ]] && [[ "$EXIT_REASON" != "completed" ]] && [[ "$EXIT_REASON" != "" ]]; then
  exit 0
fi

# Check root kanban for implement-phase topic
if [[ ! -f "$ROOT_KANBAN" ]]; then
  exit 0
fi

IMPLEMENT_TOPIC=$(node -e "
  const fs=require('fs');
  try{
    const k=JSON.parse(fs.readFileSync('${ROOT_KANBAN}','utf8'));
    const topics=k.topics||{};
    for(const[name,info]of Object.entries(topics)){
      if(info.phase==='implement'){console.log(name);process.exit(0)}
    }
  }catch(e){}
" 2>/dev/null)

if [[ -z "$IMPLEMENT_TOPIC" ]]; then
  exit 0
fi

# Read and update topic kanban
TOPIC_KANBAN="${PROJECT_DIR}/harness/topics/${IMPLEMENT_TOPIC}/kanban.json"

if [[ ! -f "$TOPIC_KANBAN" ]]; then
  exit 0
fi

node -e "
  const fs=require('fs');
  try{
    const k=JSON.parse(fs.readFileSync('${TOPIC_KANBAN}','utf8'));
    const steps=k.steps;
    if(!steps||!steps.in_progress||steps.in_progress.length===0){process.exit(0)}

    // Move first in_progress to done
    const completed=steps.in_progress.shift();
    steps.done.push(completed);

    // Move first backlog to in_progress
    if(steps.backlog&&steps.backlog.length>0){
      const next=steps.backlog.shift();
      steps.in_progress.push(next);
    }

    // Update timestamp
    k.last_updated=new Date().toISOString().split('T')[0];

    fs.writeFileSync('${TOPIC_KANBAN}',JSON.stringify(k,null,2)+'\n');
  }catch(e){
    process.stderr.write('subagent-kanban: '+e.message+'\n');
  }
" 2>/dev/null

exit 0
