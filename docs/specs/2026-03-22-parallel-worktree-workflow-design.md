# Parallel Worktree Workflow Design

**Date:** 2026-03-22
**Status:** Draft

---

## Overview

Flow 플러그인 사용자가 여러 spec을 동시에 개발할 때, git worktree와 포트 자동 관리를 통해 격리된 병렬 개발 환경을 제공하는 기능.

## Problem

- 하나의 프로젝트에서 여러 기능을 동시에 개발할 때 브랜치 전환이 번거롭고 상태가 꼬임
- 여러 터미널에서 동시에 서버를 실행하면 포트 충돌 발생
- worktree 생성/정리, 포트 할당/해제를 수동으로 관리하는 오버헤드

## Target

Flow를 사용하는 사용자 프로젝트 (웹앱, API 서버 등)에서 여러 spec을 동시에 개발하는 시나리오.

---

## Workflow

각 터미널에서 하나의 spec을 시작부터 끝까지 독립적으로 진행한다.

```
Terminal 1:                              Terminal 2:
/spec "인증 기능"                         /spec "결제 기능"
  -> spec 완성                             -> spec 완성
  -> "worktree에서 작업?" -> Y              -> "worktree에서 작업?" -> Y
  -> /worktree-create 호출                  -> /worktree-create 호출
    -> /port-assign 호출                      -> /port-assign 호출
    -> 작업 디렉토리 자동 전환                  -> 작업 디렉토리 자동 전환
  -> /plan                                 -> /plan
  -> /tdd                                  -> /tdd
  -> /code-review                          -> /code-review
  -> (필요 시 /amend -> /tdd -> /code-review 반복)
  -> "PR 생성?" -> Y                        -> "PR 생성?" -> Y
  -> /pr-create 호출                        -> /pr-create 호출
  -> /worktree-remove                      -> /worktree-remove
    -> /port-release 호출                     -> /port-release 호출
```

- 하나의 터미널 = 하나의 spec = 하나의 worktree
- 각 worktree마다 별도의 Claude Code 세션
- merge는 사용자가 직접 수행

---

## Port Management System

### Configuration

사용자가 프로젝트 루트에 `.flow/config.json`을 작성하여 포트를 정의한다.

```json
{
  "ports": {
    "FRONTEND_PORT": 3000,
    "API_PORT": 8080,
    "DB_PORT": 5432
  }
}
```

### Allocation Logic (Hybrid: Block Offset + Collision Check)

1. worktree 생성 시 블록 번호 결정 (1번 -> 10000, 2번 -> 10100, ...)
2. 블록 내에서 config 순서대로 포트 매핑:
   - worktree-1: FRONTEND_PORT=10000, API_PORT=10001, DB_PORT=10002
   - worktree-2: FRONTEND_PORT=10100, API_PORT=10101, DB_PORT=10102
3. 할당 전에 `lsof` 또는 `nc`로 각 포트 사용 여부 체크
4. 충돌 시 다음 블록(10200~)으로 자동 이동
5. 최대 재시도: 10회 (10개 블록). 모두 충돌 시 에러 메시지와 함께 수동 포트 지정 안내
6. 포트 범위: 10000~20000

### State Tracking

`.flow/worktrees.json` (자동 관리):

```json
{
  "auth": {
    "branch": "feature/auth",
    "path": "/project/.worktrees/auth",
    "block": 10000,
    "ports": {
      "FRONTEND_PORT": 10000,
      "API_PORT": 10001,
      "DB_PORT": 10002
    }
  },
  "payments": {
    "branch": "feature/payments",
    "path": "/project/.worktrees/payments",
    "block": 10100,
    "ports": {
      "FRONTEND_PORT": 10100,
      "API_PORT": 10101,
      "DB_PORT": 10102
    }
  }
}
```

### Concurrent Access

여러 터미널에서 동시에 `worktrees.json`을 읽고 쓸 수 있다. 충돌 방지 전략:

1. **읽기 -> 검증 -> 쓰기** 패턴: 쓰기 직전에 파일을 다시 읽어서 블록 번호가 이미 점유되었는지 재확인
2. 블록 번호 충돌 감지 시 다음 빈 블록으로 자동 재시도
3. 파일 수준 락은 사용하지 않음 — worktree 생성은 수 초 내에 완료되므로 실질적 충돌 가능성이 매우 낮고, 충돌 시 재시도로 해결

### Port Injection

worktree 디렉토리에 `.env.flow` 파일을 생성하여 할당된 포트를 환경변수로 주입한다.

```
FRONTEND_PORT=10000
API_PORT=10001
DB_PORT=10002
```

`.flow/config.json`이 없으면 포트 관리 없이 worktree만 생성한다.

---

## New Skills (7)

### /worktree-create

worktree 생성 + 포트 할당.

**인자:**
- `name` (선택): worktree 이름. 미지정 시 spec 파일명에서 추출 (예: `2026-03-22-auth-design.md` -> `auth`)
- `branch` (선택): 브랜치명. 미지정 시 `feature/<name>`으로 자동 생성
- `spec` (선택): spec 파일 경로. `/spec`에서 체이닝 시 자동 전달

**동작:**
1. 인자에서 name/branch 결정. 인자 없으면 사용자에게 질문
2. `git worktree add .worktrees/<name> -b <branch>` 실행
3. `/port-assign` 스킬 호출 (`.flow/config.json` 존재 시)
4. `.flow/worktrees.json` 업데이트
5. spec 파일은 git worktree가 히스토리를 공유하므로 별도 복사 불필요
6. 현재 세션의 작업 디렉토리를 worktree로 전환 (`cd .worktrees/<name>`)
7. 이후 `/plan`, `/tdd` 등 모든 스킬이 worktree 컨텍스트에서 동작

**호출 방식:** `/spec` 완료 후 사용자 동의 시 자동 호출, 또는 직접 호출.

### /worktree-remove

worktree 정리 + 포트 해제.

**인자:**
- `name` (선택): worktree 이름. 미지정 시 자동 감지 시도

**자동 감지 메커니즘:**
현재 작업 디렉토리가 `.worktrees/` 하위인지 경로를 검사한다. 예: 현재 경로가 `/project/.worktrees/auth/...`이면 name은 `auth`. `.worktrees/` 하위가 아니면 `.flow/worktrees.json`에서 등록된 worktree 목록을 보여주고 사용자에게 선택을 요청한다.

**동작:**
1. 대상 worktree 결정 (자동 감지 또는 인자)
2. 실행 중인 서버 프로세스 확인 -> 있으면 종료 여부 확인
3. `/port-release` 스킬 호출
4. `git worktree remove` 실행
5. `.flow/worktrees.json`에서 항목 제거
6. 브랜치 삭제 여부는 사용자에게 확인

**호출 방식:** 직접 호출.

### /worktree-status

전체 worktree 현황 조회.

**동작:**
1. `.flow/worktrees.json` 읽기
2. 각 worktree에 대해 디렉토리 존재 여부 검증 (수동 삭제 감지)
3. 결과 표시:

```
NAME       BRANCH           BLOCK   PORTS                              STATUS
auth       feature/auth     10000   FRONTEND:10000,API:10001,DB:10002  active
payments   feature/payments 10100   FRONTEND:10100,API:10101,DB:10102  active
old-feat   feature/old      10200   FRONTEND:10200,API:10201,DB:10202  missing (directory not found)
```

4. `missing` 상태의 worktree가 있으면 정리 여부를 사용자에게 확인

**호출 방식:** 직접 호출.

### /port-assign

포트 블록 할당.

**인자:**
- `worktree` (필수): 대상 worktree 이름

**동작:**
1. `.flow/config.json`에서 포트 정의 읽기
2. `.flow/worktrees.json`에서 사용 중인 블록 확인
3. 다음 빈 블록 계산 (10000, 10100, 10200, ...)
4. 블록 내 각 포트에 대해 `lsof`/`nc`로 충돌 검증
5. 충돌 시 다음 블록으로 이동 (최대 10회 재시도)
6. 쓰기 직전에 `worktrees.json` 재확인 (동시 접근 방지)
7. worktree 디렉토리에 `.env.flow` 파일 생성
8. `.flow/worktrees.json` 포트 정보 업데이트

**호출 방식:** `/worktree-create`에서 체이닝, 또는 직접 호출.

### /port-release

포트 블록 해제.

**인자:**
- `worktree` (필수): 대상 worktree 이름

**동작:**
1. 대상 worktree의 포트 정보 조회
2. 해당 포트를 사용 중인 프로세스 확인 -> 있으면 종료 여부 확인
3. `.env.flow` 파일 삭제
4. `.flow/worktrees.json`에서 포트 정보 제거

**호출 방식:** `/worktree-remove`에서 체이닝, 또는 직접 호출.

### /port-status

현재 포트 할당 현황 조회.

**동작:** `.flow/worktrees.json`에서 포트 정보를 추출하고, 각 포트의 실제 사용 여부를 `lsof`로 확인하여 표시.

```
WORKTREE   ENV_VAR         PORT    IN_USE
auth       FRONTEND_PORT   10000   yes
auth       API_PORT        10001   yes
auth       DB_PORT         10002   no
payments   FRONTEND_PORT   10100   no
payments   API_PORT        10101   no
payments   DB_PORT         10102   no
```

**호출 방식:** 직접 호출.

### /pr-create

PR 생성 (템플릿 기반).

**PR 템플릿:**

```markdown
## Summary
spec: docs/specs/YYYY-MM-DD-<topic>-design.md
plan: docs/plans/YYYY-MM-DD-<topic>-plan.md

## Changes
(git diff 기반 자동 요약)

## Test
(테스트 커버리지 + 통과 여부)

## Review
(code-review 결과 요약)
```

**code-review 결과 수집 방법:**
`/code-review` 스킬이 완료 시 리뷰 결과를 `.flow/review-result.md` 파일로 저장하도록 수정한다. `/pr-create`는 이 파일을 읽어서 Review 섹션을 채운다. 파일이 없으면 Review 섹션을 "(code-review 결과 없음 — /code-review를 먼저 실행하세요)" 로 표시한다.

**동작:**
1. spec/plan 문서 경로 자동 탐지 (docs/specs/, docs/plans/ 스캔)
2. git diff 기반 변경사항 요약 생성
3. 테스트 실행 및 커버리지 수집
4. `.flow/review-result.md`에서 code-review 결과 읽기
5. 템플릿에 채워서 사용자에게 제목/본문 수정 기회 제공
6. 사용자 확인 후 `gh pr create` 실행

**호출 방식:** `/code-review` 완료 후 사용자 동의 시 자동 호출, 또는 직접 호출.

---

## Skill Chaining

스킬 체이닝은 각 스킬의 SKILL.md 안에 정의된다. Claude의 임의 판단이 아닌, 스킬 자체의 플로우로 동작한다.

```
/spec ──완료──> "worktree에서 작업?" ──Y──> /worktree-create ──> 경로 안내 후 종료
                                     ──N──> 기존대로 /plan 제안

/worktree-create ──> /port-assign (config 존재 시)

/code-review ──완료──> .flow/review-result.md 저장
             ──> "PR 생성?" ──Y──> /pr-create
                              ──N──> 종료

/worktree-remove ──> /port-release
```

**`/spec` 체이닝 상세:**
기존 `/spec`은 완료 후 `/plan` 실행을 제안한다. worktree 기능 추가 시:
1. spec 완료 후 먼저 "worktree에서 작업하시겠습니까?" 확인
2. Y -> `/worktree-create` 호출 -> worktree 경로 안내 -> 현재 세션 종료 (사용자가 새 세션에서 `/plan` 실행)
3. N -> 기존대로 `/plan` 실행 제안

---

## Modified Existing Skills

### /spec (수정)

완료 후 기존 `/plan` 제안 앞에 worktree 분기 추가:
1. 사용자에게 "이 spec을 worktree에서 작업하시겠습니까?" 확인
2. 사용자가 동의하면 `/worktree-create` 스킬 호출 (spec 경로 자동 전달)
3. 거부하면 기존대로 `/plan` 실행 제안

### /code-review (수정)

완료 후 다음 플로우 추가:
1. 리뷰 결과를 `.flow/review-result.md`에 저장
2. 사용자에게 "PR을 생성하시겠습니까?" 확인
3. 사용자가 동의하면 `/pr-create` 스킬 호출
4. 거부하면 종료 (추가 수정 가능)

---

## File Structure

### Flow Plugin Side (새로 추가)

```
flow/
  skills/
    worktree-create/
      SKILL.md
    worktree-remove/
      SKILL.md
    worktree-status/
      SKILL.md
    port-assign/
      SKILL.md
    port-release/
      SKILL.md
    port-status/
      SKILL.md
    pr-create/
      SKILL.md
```

### User Project Side (자동 생성)

```
user-project/
  .flow/
    config.json          # 포트 설정 (사용자 작성)
    worktrees.json       # worktree+포트 추적 (자동 관리, gitignore)
    review-result.md     # code-review 결과 (자동 생성, gitignore)
  .worktrees/
    <name>/
      .env.flow          # 할당된 포트 환경변수
  .gitignore             # .worktrees/, .flow/worktrees.json, .flow/review-result.md 추가
```

**`.gitignore` 정책:**
- `.flow/config.json` — 커밋 대상 (팀원 공유)
- `.flow/worktrees.json` — gitignore (로컬 상태)
- `.flow/review-result.md` — gitignore (임시 파일)
- `.worktrees/` — gitignore (로컬 worktree)

---

## Design Principles

- 새 에이전트 추가 없음 -- 스킬이 직접 수행
- `.flow/config.json`이 없으면 포트 관리 없이 worktree만 생성
- 스킬 체이닝은 각 스킬의 SKILL.md 안에 정의 (자율적 판단)
- 모든 신규 스킬은 직접 호출도 가능
- 네이밍: 리소스-액션 패턴 (worktree-create, port-assign, pr-create)
- 포트 범위: 10000~20000, 블록 단위 100, 최대 재시도 10회
- merge는 사용자가 직접 수행
- worktree 생성 후 현재 세션의 작업 디렉토리를 자동 전환 — 별도 세션 불필요
