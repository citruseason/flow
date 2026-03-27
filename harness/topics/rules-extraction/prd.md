# PRD: Rules Extraction

## Overview

PRODUCT.md에서 규칙 성격의 콘텐츠를 분리하여 도메인별 독립 문서로 관리한다. PRODUCT.md는 순수 제품 정의만 남기고, 분리된 문서를 링크로 참조한다.

## Goals

1. PRODUCT.md를 순수 제품 정의 문서로 축소
2. 아키텍처/파이프라인/관찰 가능성 규칙을 독립 CORE 문서로 관리
3. 코드 컨벤션을 도메인별 규칙 파일로 관리
4. lint-* 스킬이 정확한 upstream 소스를 참조

## Non-Goals

- 규칙 내용 변경 (구조만 변경, 내용은 그대로 이동)
- SECURITY.md 변경
- 새로운 규칙 추가

## Requirements

### R1. PRODUCT.md 축소

**R1.1** PRODUCT.md에는 다음만 남긴다: 개요(이름, 버전, 설명, 유형, 라이선스), 기술 스택, 에이전트 테이블(7개), 스킬 테이블(14개), 문서 흐름 다이어그램, 분리된 문서 링크.

**R1.2** 아키텍처, 파이프라인, 규칙, 관찰 가능성 섹션은 PRODUCT.md에서 제거한다.

**R1.3** 제거된 섹션 대신 링크 섹션을 추가한다:
- `harness/ARCHITECTURE.md`
- `harness/PIPELINE.md`
- `harness/OBSERVABILITY.md`
- `harness/rules/` 디렉토리 내 규칙 파일들

### R2. CORE 문서 분리 (harness/ 루트)

**R2.1** `harness/ARCHITECTURE.md` 생성 — PRODUCT.md의 "아키텍처" 섹션 전체 이동:
- 패턴, 모듈 구성, API 스타일
- 3계층 모델
- 에이전트-스킬 분리
- 의존성 방향
- 자기 완결적 스킬
- 모델 할당

**R2.2** `harness/PIPELINE.md` 생성 — PRODUCT.md의 "파이프라인" 섹션 전체 이동:
- 순차 워크플로우
- 자율 실행 경계, 사용자 승인 게이트
- 문서 이력 FIFO 순환

**R2.3** `harness/OBSERVABILITY.md` 생성 — PRODUCT.md의 "관찰 가능성" 섹션 전체 이동:
- 로깅 형식, 로그 수준, 로깅 규칙
- 에러 전파
- 메트릭

**R2.4** 분리 시 정보 손실 없음 — 모든 내용이 새 파일에 그대로 존재해야 한다.

### R3. 규칙 파일 분리 (harness/rules/)

파일 네이밍 컨벤션: 스택별 규칙은 `{도메인}.{스택}.md`, 공통 규칙은 `{도메인}.md`.

**R3.1** 네이밍 규칙 (스택별 분리):
- `harness/rules/naming.common.md` — 파일/디렉토리 네이밍 (kebab-case), 에이전트/스킬 이름
- `harness/rules/naming.javascript.md` — JS 함수 camelCase, 모듈 수준 상수 UPPER_SNAKE_CASE
- `harness/rules/naming.shell.md` — 셸 변수 UPPER_SNAKE_CASE

**R3.2** 포맷팅 규칙 (스택별 분리):
- `harness/rules/formatting.javascript.md` — 들여쓰기, 세미콜론, 따옴표, 후행 쉼표, 타이핑(해당 없음), 주석 스타일
- `harness/rules/formatting.shell.md` — `[[ ]]` 조건문, `$()` 명령 치환, shebang, 주석 스타일
- `harness/rules/formatting.markdown.md` — `##` 섹션 구조, 코드 블록 예시, 표 데이터, 줄 길이

**R3.3** 임포트 규칙 (스택별):
- `harness/rules/imports.javascript.md` — CommonJS (`require`/`module.exports`), 임포트 순서 (내장 먼저)

**R3.4** 에러 처리 규칙 (스택별 분리):
- `harness/rules/error-handling.javascript.md` — try/catch, console.error, 비전파
- `harness/rules/error-handling.shell.md` — JSON 에러 출력, exit 1
- `harness/rules/error-handling.agent.md` — 구조화된 출력 (PASS/WARNING/FAIL), 에스컬레이션

**R3.5** 공통 규칙 (스택 무관):
- `harness/rules/git.md` — 커밋 형식, 브랜치 네이밍, 버전 동기화, 패치 전용 버전 관리
- `harness/rules/output-language.md` — CLAUDE.md 언어 설정 시스템

**R3.6** 각 규칙 파일은 독립적으로 읽을 수 있어야 한다 (다른 규칙 파일 참조 불필요).

**R3.7** 향후 `/harness-init` 실행 시 감지된 스택에 따라 해당 스택의 규칙 파일만 생성한다 (예: Python 프로젝트 → `naming.python.md`, `formatting.python.md`).

### R4. lint-* upstream 참조 업데이트

**R4.1** 이 프로젝트의 `.claude/skills/lint-*/` 에 존재하는 모든 lint-* 스킬의 `upstream:` 필드를 새 파일 경로로 변경:
- `harness/PRODUCT.md#architecture` → `harness/ARCHITECTURE.md`
- `harness/PRODUCT.md#conventions` → 해당 `harness/rules/*.md` 파일
- 대상: `.claude/skills/lint-architecture/`, `.claude/skills/lint-code-convention/`, `.claude/skills/lint-plugin-structure/`, `.claude/skills/lint-workflow-integrity/`

**R4.2** lint-manage의 CORE Document Requirement 설명도 새 구조를 반영하도록 업데이트.

### R5. CLAUDE.md 하네스 섹션 업데이트

**R5.1** CORE 문서 테이블에 ARCHITECTURE.md, PIPELINE.md, OBSERVABILITY.md 추가.

**R5.2** 규칙 디렉토리 참조 추가 (`harness/rules/` 포인터).

### R6. harness-initializer 에이전트 업데이트

**R6.1** 에이전트가 새 구조를 인식하도록 Phase 2 (CORE Document Generation) 업데이트 — ARCHITECTURE.md, PIPELINE.md, OBSERVABILITY.md를 항상 생성하도록 추가.

**R6.2** 규칙 파일 생성 로직 추가 — `harness/rules/` 디렉토리에 컨벤션 규칙 파일 생성.

**R6.3** Phase 6 (Re-run) 업데이트 — 레거시 구조(규칙이 PRODUCT.md에 있는 경우) 감지 시 분리 마이그레이션 수행.

## Acceptance Criteria

- [ ] AC1: PRODUCT.md에 아키텍처/파이프라인/규칙/관찰 가능성 섹션이 없다
- [ ] AC2: PRODUCT.md에 분리된 문서들의 링크가 있다
- [ ] AC3: ARCHITECTURE.md에 기존 아키텍처 섹션의 모든 내용이 있다
- [ ] AC4: PIPELINE.md에 기존 파이프라인 섹션의 모든 내용이 있다
- [ ] AC5: OBSERVABILITY.md에 기존 관찰 가능성 섹션의 모든 내용이 있다
- [ ] AC6: harness/rules/에 도메인+스택별 규칙 파일이 있다 (naming.common, naming.javascript, naming.shell, formatting.javascript, formatting.shell, formatting.markdown, imports.javascript, error-handling.javascript, error-handling.shell, error-handling.agent, git, output-language)
- [ ] AC7: 기존 규칙 섹션의 모든 내용이 rules/ 파일들에 존재한다
- [ ] AC8: `.claude/skills/lint-*/` 의 모든 lint-* 스킬 upstream 참조가 새 파일 경로를 가리킨다
- [ ] AC9: lint-manage SKILL.md의 CORE Document Requirement 설명이 새 구조를 반영한다
- [ ] AC10: CLAUDE.md 하네스 섹션에 새 CORE 문서와 rules/ 참조가 나열된다
- [ ] AC11: harness-initializer가 새 구조(ARCHITECTURE.md, PIPELINE.md, OBSERVABILITY.md, rules/)를 생성한다
- [ ] AC12: 정보 손실 없음 — PRODUCT.md에서 제거된 모든 내용이 분리된 파일에 존재한다
