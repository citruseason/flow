# CPS: Realtime Kanban

## Context

Flow 플러그인은 `kanban.json` 파일로 토픽 진행 상태를 추적한다. 각 스킬이 단계 완료 시 파일을 업데이트하지만, 사용자는 이 변경을 CLI 로그 사이에서 확인하거나 직접 파일을 열어야 한다. `/implement`처럼 자율 실행되는 단계에서는 수십 분간 진행 상황을 알 수 없다.

## Problem

1. **진행 상태 불투명** — 자율 실행 구간(`/implement` → `/lint`)에서 현재 어느 Phase의 어느 Step을 실행 중인지 사용자가 1초 이내의 지연으로 확인할 방법이 없다.
2. **세분화 부족** — 현재 kanban.json은 `steps.done/in_progress/backlog` 배열로 Step 수준 데이터를 이미 저장하지만, 이를 시각적으로 확인할 방법이 없다. 스킬이 Step을 이동할 때마다 파일이 업데이트되지만 사용자에게 노출되지 않는다.
3. **수동 확인 필요** — `kanban.json`을 직접 열어 확인하거나 CLI 출력을 스크롤해야 해서 사용자 경험이 좋지 않다.

## Solution

1. **kanban 전용 WebSocket 서버** — Visual Companion과 별도로 동작하는 전용 서버를 구현한다. `kanban.json` 파일 변경을 `fs.watch`로 감지하고, 변경 시 즉시 브라우저에 WebSocket push한다.
2. **트렐로 스타일 칸반 보드 UI** — Done/In Progress/Backlog 3컬럼에 카드를 배치하는 브라우저 대시보드를 제공한다. 현재 실행 중인 토픽의 Phase/Step을 실시간 반영한다.
3. **자동 라이프사이클 관리** — 스킬이 kanban 서버를 자동 시작/종료한다. 사용자는 브라우저 탭 하나만 열어두면 된다.
