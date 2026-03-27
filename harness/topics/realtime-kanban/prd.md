# PRD: Realtime Kanban

## Overview

kanban.json 변경을 실시간으로 감지하여 브라우저에 트렐로 스타일 칸반 보드로 표시하는 전용 서버와 대시보드를 구현한다.

## Goals

1. 사용자가 브라우저에서 토픽 진행 상태를 실시간으로 확인
2. Phase/Step 단위의 세분화된 트래킹
3. 각 단계 시작/완료 시 자동으로 UI 반영

## Non-Goals

- 전체 토픽 조감도 (현재 실행 중인 토픽만 표시)
- 완료 이력/통계
- 사용자가 UI에서 직접 kanban 조작 (읽기 전용)
- 기존 Visual Companion 서버 수정

## Requirements

### R1. Kanban WebSocket Server

**R1.1** 독립 서버로 구현한다. 기존 Visual Companion 서버(`server.cjs`)와 별도 프로세스/포트로 실행.

**R1.2** Zero-dependency Node.js (기존 프로젝트 패턴 유지). 내장 모듈(`http`, `fs`, `path`, `crypto`)만 사용.

**R1.3** 토픽 kanban 파일 경로를 인자로 받는다: `--kanban <path>` (예: `harness/topics/<topic>/kanban.json`)

**R1.4** `fs.watch`로 kanban.json 변경을 감지하고, 변경 시 파일을 읽어 JSON 파싱 후 연결된 모든 WebSocket 클라이언트에 push한다.

**R1.5** 서버 시작 시 kanban.json의 초기 상태를 읽어 첫 연결 클라이언트에 즉시 전송한다.

**R1.6** HTML 대시보드 파일을 서빙한다 (내장 또는 별도 파일).

**R1.7** 서버 포트는 자동 할당 (0 포트 바인딩) 또는 `--port` 인자로 지정 가능.

**R1.8** idle timeout으로 자동 종료 (kanban.json이 일정 시간 변경 없으면 종료). 기본값 30분.

### R2. Kanban Dashboard UI

**R2.1** 트렐로 스타일 3컬럼 레이아웃: **Backlog** (왼쪽), **In Progress** (가운데), **Done** (오른쪽). 좌→우 진행 흐름.

**R2.2** 각 Step은 카드로 표시. 카드에는 `id`와 `name`을 표시.

**R2.3** WebSocket 메시지 수신 시 카드를 즉시 이동한다 (페이지 새로고침 없이 DOM 업데이트).

**R2.4** 현재 `in_progress` 카드에 시각적 강조 (애니메이션 또는 하이라이트).

**R2.5** 토픽 이름과 현재 phase를 헤더에 표시.

**R2.6** 연결 상태 표시기: 연결됨(초록)/끊김(빨강)/재연결 중(노랑).

**R2.7** WebSocket 연결이 끊기면 자동 재연결 (exponential backoff).

**R2.8** 데스크톱 브라우저 최적화 (최소 너비 800px).

### R3. 서버 라이프사이클 관리

**R3.1** 시작 스크립트: `start-kanban.sh --kanban <path> [--port <port>]`
- 서버를 백그라운드로 시작
- PID 파일에 프로세스 ID 저장
- 브라우저 URL 출력

**R3.2** 종료 스크립트: `stop-kanban.sh`
- PID 파일에서 프로세스 ID 읽기
- SIGTERM 전송, 2초 후 SIGKILL

**R3.3** 스크립트 위치: `skills/meeting/scripts/` (기존 인프라 디렉토리 활용)

### R4. 스킬 통합

**R4.1** `/implement` 스킬이 실행 시작 시 kanban 서버를 자동 시작한다.

**R4.2** `/lint` 완료 시 kanban 서버를 자동 종료한다.

**R4.3** 사용자에게 대시보드 URL을 안내한다: "Kanban dashboard: http://localhost:{port}"

**R4.4** 서버 시작/종료는 best-effort — 실패해도 메인 워크플로우를 차단하지 않는다.

### R5. kanban.json 호환성

**R5.1** 기존 kanban.json 스키마를 그대로 사용한다. 서버는 read-only.

**R5.2** 서버가 kanban.json을 수정하지 않는다.

**R5.3** `steps.done`, `steps.in_progress`, `steps.backlog` 배열의 아이템을 각각 Done/In Progress/Backlog 컬럼에 매핑한다.

## Acceptance Criteria

- [ ] AC1: kanban 서버가 지정된 kanban.json을 감시하고 변경 후 1초 이내에 WebSocket으로 브라우저에 push
- [ ] AC2: 브라우저에 3컬럼 칸반 보드가 표시되고 Done/In Progress/Backlog에 카드가 올바르게 배치
- [ ] AC3: kanban.json 변경 시 페이지 새로고침 없이 카드가 실시간 이동
- [ ] AC4: in_progress 카드에 시각적 강조가 있음
- [ ] AC5: 토픽 이름과 phase가 헤더에 표시
- [ ] AC6: 연결 상태 표시기가 동작 (연결/끊김/재연결)
- [ ] AC7: start-kanban.sh로 서버 시작, stop-kanban.sh로 종료 가능
- [ ] AC8: /implement 시작 시 kanban 서버 자동 시작, /lint 완료 시 자동 종료
- [ ] AC9: 서버가 kanban.json을 수정하지 않음 (read-only)
- [ ] AC10: zero-dependency (Node.js 내장 모듈만 사용)
- [ ] AC11: 서버 시작 시 kanban.json 초기 상태를 첫 연결 클라이언트에 즉시 전송
- [ ] AC12: idle timeout(기본 30분) 후 서버 자동 종료
- [ ] AC13: 서버가 이미 실행 중일 때 재시작 요청 시 기존 서버를 종료 후 새로 시작
