# PRD: Hooks Integration

## Overview

Claude Code hook 시스템을 활용하여 머지 감지 → CORE 업데이트 자동화, 세션 복원 컨텍스트 재주입, 자율 실행 요약, kanban 자동 업데이트를 구현한다.

## Goals

1. 머지 후 CORE 문서 업데이트가 자동으로 수행됨
2. 세션 복원/compact 후 진행 상태가 즉시 복구됨
3. 자율 실행 완료 시 kanban 상태 요약이 자동 제공됨
4. 스킬 내 kanban 업데이트 중복 코드 제거

## Non-Goals

- 모든 26가지 hook 이벤트 활용 (4개만 구현)
- hook으로 lint 실행 자동화 (이미 /implement에서 처리)
- UI/대시보드 변경 (kanban 대시보드는 별도 토픽)
- 기존 스킬의 기능 변경 (kanban 로직 제거만)

## Requirements

### R1. PostToolUse Hook — 머지 감지 및 CORE 자동 업데이트

**R1.1** `PostToolUse` hook을 `hooks/hooks.json`에 추가한다. matcher: `"Bash"`, if: `"Bash(git merge *)"`. (Claude Code의 `if` 필드는 permission rule 문법을 사용한다.)

**R1.2** hook은 머지된 브랜치명에서 토픽 이름을 추출한다. `feature/<topic>` 패턴에서 `<topic>` 부분을 파싱.

**R1.3** 토픽의 kanban.json에서 lint 단계가 done인지 확인한다. done이 아니면 아무 작업도 하지 않는다.

**R1.4** 조건이 충족되면 stdout에 시스템 메시지를 출력한다: `"[Flow] Topic <topic> merged. Running /core-update <topic> automatically."` Claude는 이 메시지를 컨텍스트로 받아 `/core-update`를 실행한다. 이것은 모델 행동 기반 트리거이며, 프로그래매틱 명령 실행이 아니다.

**R1.5** `git pull` 명령에도 동일하게 반응한다 (원격 머지 포함): 별도 hook 항목으로 if에 `"Bash(git pull *)"` 추가.

### R2. SessionStart Hook — 컨텍스트 재주입

**R2.1** `SessionStart` hook을 `hooks/hooks.json`에 추가한다. matcher를 빈 문자열로 설정 (모든 세션 시작에 반응). 스크립트 내부에서 stdin의 `source` 필드를 확인하여 `resume`과 `compact`일 때만 전체 컨텍스트를 주입하고, `startup`일 때는 기존 환영 메시지만 출력한다.

**R2.2** hook 스크립트가 다음 정보를 수집하여 stdout에 출력한다 (Claude 컨텍스트에 주입됨):
- 현재 in_progress 토픽 (harness/kanban.json에서 phase != "done"인 토픽)
- 해당 토픽의 kanban.json 상태 (현재 단계, backlog 항목)
- harness CORE 문서 목록 (ls harness/*.md)
- 마지막 수정 파일 (git diff --name-only HEAD~1)
- 마지막 커밋 메시지 (git log -1 --oneline)

**R2.3** in_progress 토픽이 없으면 harness 요약만 출력한다.

**R2.4** 출력은 간결하게 — 전체 파일 내용이 아닌 요약 정보만.

### R3. Stop Hook — Kanban 상태 요약

**R3.1** `Stop` hook을 `hooks/hooks.json`에 추가한다.

**R3.2** hook 스크립트가 harness/kanban.json에서 in_progress 토픽을 확인한다.

**R3.3** in_progress 토픽이 있으면 해당 토픽의 현재 단계를 한 줄 요약으로 stdout에 출력한다: `[Flow] <topic>: <current_step> (<done_count>/<total_count> done)`

**R3.4** in_progress 토픽이 없으면 아무것도 출력하지 않는다 (불필요한 노이즈 방지).

**R3.5** `stop_hook_active` 필드를 확인하여 무한 루프를 방지한다.

### R4. SubagentStop Hook — Kanban 자동 업데이트

**R4.1** `SubagentStop` hook을 `hooks/hooks.json`에 추가한다. matcher는 빈 문자열 (모든 에이전트).

**R4.2** hook 스크립트가 stdin의 JSON에서 `agent_name`과 `exit_reason`을 읽는다.

**R4.3** harness/kanban.json에서 현재 implement 중인 토픽을 찾는다.

**R4.4** 해당 토픽의 kanban.json에서 현재 `in_progress` 단계를 `done`으로 이동하고, 다음 `backlog` 항목을 `in_progress`로 이동한다.

**R4.5** `last_updated` 필드를 현재 날짜로 갱신한다.

**R4.6** 에이전트가 실패한 경우 (`exit_reason`이 에러) kanban을 업데이트하지 않는다.

**R4.7** implement phase가 아닌 경우 (meeting, design-doc 등) kanban 업데이트를 하지 않는다. 스크립트는 `harness/kanban.json`에서 `phase: "implement"`인 토픽을 찾아 해당 토픽의 kanban.json만 업데이트한다. implement phase 토픽이 없으면 아무 작업도 하지 않는다.

### R5. Hook 스크립트 인프라

**R5.1** 모든 hook 스크립트는 `hooks/scripts/` 디렉토리에 배치한다.

**R5.2** 스크립트는 Bash로 작성하고, jq 없이 동작해야 한다 (Node.js 내장 JSON 파싱 또는 grep/sed 활용).

**R5.3** 각 스크립트는 실행 권한(+x)이 있어야 한다.

**R5.4** 스크립트 에러가 메인 워크플로우를 차단하지 않도록 한다 (exit 0 유지, 에러는 stderr로 출력).

### R6. 스킬 kanban 로직 정리

**R6.1** implement SKILL.md에서만 에이전트 완료 후 kanban step 이동 로직을 제거한다 (SubagentStop hook이 대신 처리).

**R6.2** meeting, design-doc, lint 등 다른 스킬의 kanban 로직은 유지한다. SubagentStop hook은 implement phase에서만 동작하므로 (R4.7) 다른 스킬은 여전히 자체 kanban 관리가 필요하다.

## Acceptance Criteria

- [ ] AC1: `git merge feature/<topic>` 실행 후 `/core-update <topic>`이 자동 트리거됨
- [ ] AC2: `git pull`로 원격 머지 시에도 동일하게 동작함
- [ ] AC3: lint가 done이 아닌 토픽의 머지에서는 core-update가 트리거되지 않음
- [ ] AC4: 세션 resume 시 in_progress 토픽 상태가 Claude 컨텍스트에 주입됨
- [ ] AC5: 세션 compact 시 동일하게 컨텍스트가 재주입됨
- [ ] AC6: 재주입 내용에 harness CORE 문서 목록, 마지막 수정 파일, 마지막 커밋이 포함됨
- [ ] AC7: 자율 실행 완료 시 kanban 상태 한 줄 요약이 표시됨
- [ ] AC8: in_progress 토픽이 없으면 Stop hook이 아무것도 출력하지 않음
- [ ] AC9: SubagentStop 시 kanban.json의 in_progress → done 이동이 자동으로 수행됨
- [ ] AC10: 에이전트 실패 시 kanban이 업데이트되지 않음
- [ ] AC11: implement phase 외에서는 SubagentStop kanban 업데이트가 동작하지 않음
- [ ] AC12: implement SKILL.md에서 kanban step 이동 로직이 제거됨
- [ ] AC13: 모든 hook 스크립트 에러가 메인 워크플로우를 차단하지 않음
- [ ] AC14: hooks/hooks.json에 4개 hook이 등록됨 (PostToolUse, SessionStart, Stop, SubagentStop)
