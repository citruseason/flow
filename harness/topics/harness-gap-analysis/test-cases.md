# Test Cases: Harness Gap Analysis

## Unit Tests

| ID | Scenario | Input | Expected Output |
|----|----------|-------|-----------------|
| U-001 | Always-generated CORE docs | 아무 프로젝트 | PRODUCT.md, SECURITY.md 생성 |
| U-002 | Frontend detection | React 의존성 존재 | FRONTEND.md 생성 |
| U-003 | Backend detection | Express 의존성 존재 | BACKEND.md 생성 |
| U-004 | Design detection | UI 프레임워크 존재 | DESIGN.md 생성 |
| U-005 | Batch detection | 스케줄러/파이프라인 설정 존재 | BATCH.md 생성 |
| U-006 | No false positives | Python CLI (프론트엔드 없음) | FRONTEND.md, DESIGN.md 미생성 |
| U-007 | Monorepo product-level | 다중 apps/ 디렉토리 | 앱별이 아닌 product-level CORE 생성 |
| U-008 | CLAUDE.md creation | CLAUDE.md 미존재 | 새 CLAUDE.md 생성 + harness 섹션 |
| U-009 | CLAUDE.md append | 기존 CLAUDE.md 존재 | 기존 내용 불변 + harness 섹션 추가 |
| U-010 | CLAUDE.md update | 마커 존재 + CORE 변경 | 마커 사이 내용만 교체 |
| U-011 | CLAUDE.md line limit | CORE 문서 10개 이상 | harness 섹션 ≤ 100줄 |
| U-012 | Legacy migration - golden-rules | golden-rules.md 존재 | 규칙이 CORE 문서에 분배 + 원본 삭제 |
| U-013 | Legacy migration - observability | observability.md 존재 | 내용이 도메인 문서에 분배 + 원본 삭제 |
| U-014 | Legacy migration - index | index.md 존재 | 삭제됨 (CLAUDE.md로 대체) |
| U-015 | Retained files | quality-score.md, tech-debt.md | 마이그레이션 후에도 유지 |
| U-016 | Zero information loss | golden-rules.md 전체 규칙 | 마이그레이션 후 모든 규칙이 CORE에 존재 |
| U-017 | Lint upstream reference | lint skill 정의 | `upstream:` 필드에 CORE 문서 참조 존재 |
| U-018 | Reference - llms.txt available | llms.txt 제공 라이브러리 | llms.txt 직접 fetch → references/ 저장 |
| U-019 | Reference - no llms.txt | llms.txt 미제공 라이브러리 | 공식 문서 기반 레퍼런스 생성 |
| U-020 | Reference file format | 생성된 레퍼런스 | `harness/references/<name>.md` 형식 |

## Integration Tests

| ID | Scenario | Steps | Expected Result |
|----|----------|-------|-----------------|
| I-001 | Full harness-init (React+Express) | 1. React+Express 프로젝트에서 `/harness-init` 실행 | PRODUCT, SECURITY, DESIGN, FRONTEND, BACKEND 생성 + CLAUDE.md 섹션 + 레퍼런스 |
| I-002 | Full harness-init (Python CLI) | 1. Python CLI 프로젝트에서 `/harness-init` 실행 | PRODUCT, SECURITY만 생성 + CLAUDE.md 섹션 |
| I-003 | Re-run with legacy files | 1. 기존 harness/ (index, golden-rules, observability) 존재 2. `/harness-init` 재실행 | legacy 파일 마이그레이션 + CORE 생성 + legacy 삭제 |
| I-004 | CORE change → lint update | 1. CORE 문서 수정 2. `/lint-manage` 실행 | 영향받는 lint skill 식별 + 규칙 업데이트 |
| I-005 | Merge → CORE update | 1. 토픽 브랜치 작업 완료 2. main에 머지 | 관련 CORE 문서 업데이트 + CLAUDE.md 갱신 + 미머지 토픽 내용 CORE에 미반영 확인 |
| I-006 | Dependency add → reference | 1. `pnpm add zod` 2. `/harness-init` 재실행 | `harness/references/zod.md` 생성 |
| I-007 | Dependency remove → cleanup | 1. 의존성 제거 2. `/harness-init` 재실행 | 해당 레퍼런스 파일 삭제 |
| I-008 | CORE-lint alignment check | 1. CORE 참조 없는 lint rule 생성 시도 | lint-manage가 경고 |
| I-009 | New CORE doc → CLAUDE.md update | 1. 새 CORE 문서 (e.g., MOBILE.md) 추가 2. CLAUDE.md 갱신 트리거 | harness 섹션에 새 문서 포함 확인 |

## E2E Tests

| ID | Scenario | Action | Expected Outcome |
|----|----------|--------|------------------|
| E-001 | Full pipeline - new project | `/harness-init` → `/meeting` → `/design-doc` → `/implement` → 머지 | CORE 문서가 실현된 설계 반영, lint skills에 CORE 참조, CLAUDE.md 최신 |
| E-002 | Extensibility | 새 CORE 문서 타입 (e.g., MOBILE.md) 추가 | 기존 CORE 문서/lint skills 수정 불필요 |
| E-003 | Multi-characteristic project | React + Express + Tailwind 프로젝트 | FRONTEND, BACKEND, DESIGN 모두 생성 + 각 레퍼런스 |
