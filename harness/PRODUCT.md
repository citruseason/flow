# 제품 정의

## 개요

- **이름:** Flow
- **버전:** 0.0.12
- **설명:** Claude Code용 완전한 개발 워크플로우 플러그인 -- 하네스 설정부터 미팅 기반 요구사항 정의, 설계 문서 작성, 자율 구현, 린트 검증까지 전 과정을 지원한다.
- **유형:** Claude Code 플러그인 (프롬프트 기반 CLI 워크플로우 도구)
- **라이선스:** MIT

## 기술 스택

- **언어:** Markdown (주요 -- 에이전트/스킬 프롬프트), JavaScript-CJS (서버, 헬퍼), Bash (셸 스크립트), JSON (설정, 칸반)
- **프레임워크:** 없음 (의존성 없는 Node.js WebSocket 서버)
- **주요 라이브러리:** Node.js 내장 모듈만 사용 (`crypto`, `http`, `fs`, `path`)
- **빌드 도구:** 없음 (컴파일 및 번들링 불필요)
- **테스트 프레임워크:** 현재 없음 (권장: `node:test` 내장 테스트 러너)

## 에이전트 (7개)

| 에이전트 | 모델 | 역할 |
|----------|------|------|
| harness-initializer | Opus | 코드베이스 분석, harness/ 스캐폴딩, lint-* 스킬 생성 |
| meeting-facilitator | Opus | 미팅 대화, 미팅 로그/CPS/PRD 생성 |
| meeting-reviewer | Sonnet | CPS/PRD 검증 |
| design-doc-writer | Opus | PRD 기반 설계 문서 작성 (5개 문서) |
| design-doc-reviewer | Sonnet | 문서 간 일관성 검증, PRD 커버리지 검증 |
| doc-gardener | Sonnet | 문서/규칙 최신성 검증 |
| lint-reviewer | Sonnet | lint-* 스킬 종합, 품질 점수 산출 |

## 스킬 (14개)

| 스킬 | 경로 | 목적 |
|------|------|------|
| harness-init | skills/harness-init/ | 코드베이스 분석 및 하네스 지식 베이스 스캐폴딩 |
| meeting | skills/meeting/ | 비주얼 컴패니언을 활용한 미팅 기반 요구사항 정의 |
| design-doc | skills/design-doc/ | PRD에서 설계 문서로 변환 (Spec, Blueprint, Architecture, Code-Dev-Plan, Test-Cases) |
| implement | skills/implement/ | SDD + TDD를 활용한 자율 실행 및 칸반 추적 |
| lint | skills/lint/ | 요구사항 검증 + 프로젝트 lint-* 스킬 실행 |
| lint-manage | skills/lint-manage/ | 린트 스킬 진화 (코드 변경 기반 규칙 생성/업데이트) |
| lint-integrate | skills/lint-integrate/ | 외부 스킬을 린트 워크플로우에 통합 |
| lint-validate | skills/lint-validate/ | 린트 스킬 상태 검증 (구조, 최신성, 감지) |
| core-update | skills/core-update/ | 병합 후 CORE 문서를 실현된 결정으로 업데이트 |
| doc-garden | skills/doc-garden/ | 하네스 문서 최신성 검증 |
| sdd | skills/sdd/ | 서브에이전트 기반 개발 패턴 (디스패치 + 리뷰 게이트) |
| tdd | skills/tdd/ | TDD 방법론 (RED -> GREEN -> REFACTOR) |
| using-worktree | skills/using-worktree/ | 격리된 개발을 위한 워크트리 설정 + 작업 컨텍스트 |
| update-plugin | skills/update-plugin/ | 수동 플러그인 업데이트 |

## 관련 문서

### CORE 문서
| 문서 | 목적 |
|------|------|
| [ARCHITECTURE.md](ARCHITECTURE.md) | 3계층 모델, 에이전트-스킬 분리, 의존성 방향, 모델 할당 |
| [PIPELINE.md](PIPELINE.md) | 순차 워크플로우, 자율 실행 경계, 문서 이력 |
| [OBSERVABILITY.md](OBSERVABILITY.md) | 로깅 형식, 에러 전파, 메트릭 |
| [SECURITY.md](SECURITY.md) | 보안 원칙, 입력 검증, 프로세스 격리 |

### 규칙
`harness/rules/` 디렉토리에서 도메인+스택별 규칙 파일을 관리한다:

| 파일 | 내용 |
|------|------|
| [naming.common.md](rules/naming.common.md) | 파일/디렉토리/에이전트 네이밍 |
| [naming.javascript.md](rules/naming.javascript.md) | JS 함수/상수 네이밍 |
| [naming.shell.md](rules/naming.shell.md) | 셸 변수 네이밍 |
| [formatting.javascript.md](rules/formatting.javascript.md) | JS 포맷팅, 타이핑, 주석 |
| [formatting.shell.md](rules/formatting.shell.md) | 셸 포맷팅, 주석 |
| [formatting.markdown.md](rules/formatting.markdown.md) | Markdown 구조화 |
| [imports.javascript.md](rules/imports.javascript.md) | CommonJS 임포트 |
| [error-handling.javascript.md](rules/error-handling.javascript.md) | JS 에러 처리 |
| [error-handling.shell.md](rules/error-handling.shell.md) | 셸 에러 처리 |
| [error-handling.agent.md](rules/error-handling.agent.md) | 에이전트 에러 처리 |
| [git.md](rules/git.md) | 커밋, 브랜치, 버전 관리 |
| [output-language.md](rules/output-language.md) | 출력 언어 설정 |
