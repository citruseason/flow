#!/usr/bin/env bash
# SessionStart hook: Reinject context on resume/compact, welcome on startup
set +e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(cd "$SCRIPT_DIR/../.." && pwd)}"
ROOT_KANBAN="${PROJECT_DIR}/harness/kanban.json"

# Read stdin JSON
INPUT=$(cat)

# Extract source field
SOURCE=$(echo "$INPUT" | node -e "
  let d='';process.stdin.on('data',c=>d+=c);process.stdin.on('end',()=>{
    try{const j=JSON.parse(d);console.log(j.source||'startup')}catch(e){console.log('startup')}
  });
" 2>/dev/null)

# On startup: just welcome message
if [[ "$SOURCE" == "startup" ]]; then
  echo "[Flow] Plugin loaded. Use /harness-init to set up your project, then /meeting to start."
  exit 0
fi

# On resume/compact: full context reinjection
echo "[Flow] Session restored. Context summary:"
echo ""

# CORE documents
if [[ -d "${PROJECT_DIR}/harness" ]]; then
  CORE_DOCS=$(ls "${PROJECT_DIR}"/harness/*.md 2>/dev/null | xargs -I{} basename {} 2>/dev/null | tr '\n' ', ' | sed 's/,$//')
  if [[ -n "$CORE_DOCS" ]]; then
    echo "CORE docs: ${CORE_DOCS}"
  fi
fi

# Active topics
if [[ -f "$ROOT_KANBAN" ]]; then
  node -e "
    const fs=require('fs');
    const path=require('path');
    try{
      const root=JSON.parse(fs.readFileSync('${ROOT_KANBAN}','utf8'));
      const topics=root.topics||{};
      let hasActive=false;
      for(const[name,info]of Object.entries(topics)){
        if(info.phase==='done')continue;
        hasActive=true;
        const tPath=path.join('${PROJECT_DIR}','harness','topics',name,'kanban.json');
        if(!fs.existsSync(tPath)){console.log('Active topic: '+name+' (phase: '+info.phase+')');continue}
        const tk=JSON.parse(fs.readFileSync(tPath,'utf8'));
        const steps=tk.steps||{};
        const done=(steps.done||[]).length;
        const inProg=steps.in_progress||[];
        const backlog=(steps.backlog||[]).length;
        const total=done+inProg.length+backlog;
        const current=inProg.length>0?inProg[0].name:'(idle)';
        console.log('Active topic: '+name+' — phase: '+info.phase+', step: '+current+' ('+done+'/'+total+' done)');
      }
      if(!hasActive){console.log('No active topics.')}
    }catch(e){console.log('No active topics.')}
  " 2>/dev/null
fi

# Last commit and modified files
echo ""
LAST_COMMIT=$(cd "$PROJECT_DIR" && git log -1 --oneline 2>/dev/null)
if [[ -n "$LAST_COMMIT" ]]; then
  echo "Last commit: ${LAST_COMMIT}"
fi

MODIFIED=$(cd "$PROJECT_DIR" && git diff --name-only HEAD~1 2>/dev/null | head -10)
if [[ -n "$MODIFIED" ]]; then
  echo "Last modified files:"
  echo "$MODIFIED" | sed 's/^/  /'
fi

exit 0
