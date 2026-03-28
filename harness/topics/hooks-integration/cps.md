# CPS: Hooks Integration

## Context

Claude Code는 26가지 hook 이벤트를 지원하지만 Flow 플러그인은 `SessionStart` 환영 메시지 하나만 사용하고 있다. 특히 자율 실행 구간(`/implement` → `/lint`)에서 에이전트 완료, 머지 이벤트, 세션 복원 같은 상황에 대한 자동 반응이 없어 사용자가 수동으로 개입해야 하는 지점들이 존재한다.

## Problem

1. **머지 후 CORE 업데이트 누락** — 토픽 브랜치를 머지한 후 `/core-update`를 수동으로 실행해야 한다. 잊으면 CORE 문서가 실현된 설계 결정을 반영하지 못한다.
2. **세션 복원 시 컨텍스트 유실** — 세션이 resume되거나 compact될 때 현재 진행 중인 토픽 상태, harness 구조, 마지막 작업 컨텍스트가 사라진다. Claude가 처음부터 다시 파악해야 한다.
3. **자율 실행 완료 시 요약 부재** — `/implement` → `/lint` 자율 실행이 끝나도 최종 상태 요약이 자동으로 제공되지 않는다.
4. **kanban 업데이트 로직 중복** — 모든 스킬이 에이전트 완료 후 kanban.json을 수동으로 업데이트하는 코드를 각각 포함하고 있어 중복과 누락 위험이 있다.

## Solution

1. **PostToolUse hook (머지 감지)** — `Bash(git merge*)` 패턴을 감지하여 `/core-update`를 자동 트리거한다. 사용자 개입 없이 CORE 문서가 머지된 설계 결정을 즉시 반영한다.
2. **SessionStart hook (컨텍스트 재주입)** — 세션 시작 시 (신규, resume, compact 포함 — Claude Code의 `SessionStart` 이벤트는 `source` 필드로 startup/resume/clear/compact를 구분) 현재 진행 중인 토픽의 kanban 상태, harness CORE 문서 맵, 마지막 수정 파일과 커밋 정보를 Claude 컨텍스트에 자동 주입한다.
3. **Stop hook (kanban 요약)** — Claude 응답 완료 시 진행 중인 토픽이 있으면 kanban 상태를 한 줄 요약으로 표시한다.
4. **SubagentStop hook (kanban 자동 업데이트)** — implement 자율 실행 중 에이전트 완료 시 hook이 kanban.json을 직접 업데이트한다. implement SKILL.md에서만 kanban step 이동 로직을 제거한다 (meeting, design-doc 등 다른 스킬은 유지).
