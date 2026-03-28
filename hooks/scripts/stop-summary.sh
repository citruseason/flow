#!/usr/bin/env bash
# Stop hook: Output one-line kanban progress summary for active topics
# Silent when no in_progress topics
set +e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(cd "$SCRIPT_DIR/../.." && pwd)}"
ROOT_KANBAN="${PROJECT_DIR}/harness/kanban.json"

# Read stdin to check stop_hook_active
INPUT=$(cat)
STOP_ACTIVE=$(echo "$INPUT" | node -e "
  let d='';process.stdin.on('data',c=>d+=c);process.stdin.on('end',()=>{
    try{const j=JSON.parse(d);console.log(j.stop_hook_active?'true':'false')}catch(e){console.log('false')}
  });
" 2>/dev/null)

# Prevent infinite loop
if [[ "$STOP_ACTIVE" == "true" ]]; then
  exit 0
fi

if [[ ! -f "$ROOT_KANBAN" ]]; then
  exit 0
fi

# Find active topics and output summary
node -e "
  const fs=require('fs');
  const path=require('path');
  try{
    const root=JSON.parse(fs.readFileSync('${ROOT_KANBAN}','utf8'));
    const topics=root.topics||{};
    for(const[name,info]of Object.entries(topics)){
      if(info.phase==='done')continue;
      const tPath=path.join('${PROJECT_DIR}','harness','topics',name,'kanban.json');
      if(!fs.existsSync(tPath))continue;
      const tk=JSON.parse(fs.readFileSync(tPath,'utf8'));
      const steps=tk.steps||{};
      const done=(steps.done||[]).length;
      const inProg=steps.in_progress||[];
      const backlog=(steps.backlog||[]).length;
      const total=done+inProg.length+backlog;
      const current=inProg.length>0?inProg[0].name:'(none)';
      console.log('[Flow] '+name+': '+current+' ('+done+'/'+total+' done)');
    }
  }catch(e){}
" 2>/dev/null

exit 0
