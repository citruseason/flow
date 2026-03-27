# Code Dev Plan: Harness Gap Analysis

## Phase 1: ProjectDetector + CORE Document Generation

- What: 프로젝트 특성 감지 로직과 CORE 도메인 문서 생성을 harness-initializer에 추가
- Where: `agents/harness-initializer.md`, `skills/harness-init/SKILL.md`
- How: agent 프롬프트에 detection rules(프레임워크/언어 신호 → CORE 문서 매핑) 추가. always-generated(PRODUCT, SECURITY)와 conditional(FRONTEND, BACKEND 등) 분기. 생성된 문서는 `harness/` 루트에 배치.
- Verify:
  - React+Express 프로젝트에서 PRODUCT, SECURITY, FRONTEND, BACKEND 생성 확인
  - Python CLI에서 PRODUCT, SECURITY만 생성 확인
  - 모노레포에서 product-level(per-app 아닌) 문서 생성 확인

## Phase 2: CLAUDE.md Harness Section

- What: CLAUDE.md에 harness 섹션 자동 삽입/업데이트
- Where: `agents/harness-initializer.md`, `skills/harness-init/SKILL.md`
- How: `<!-- harness:start -->` / `<!-- harness:end -->` 마커로 섹션 경계 관리. CLAUDE.md 없으면 생성, 있으면 마커 사이만 교체. 프로젝트 설명 + CORE 문서 목록 + 포인터 포함. 100줄 이내.
- Verify:
  - CLAUDE.md 없는 프로젝트에서 새 파일 생성 확인
  - 기존 CLAUDE.md에 harness 섹션 추가 시 기존 내용 불변 확인
  - 섹션 100줄 이내 확인
  - 재실행 시 마커 사이 내용만 업데이트 확인

## Phase 3: Legacy File Migration

- What: index.md, golden-rules.md, observability.md를 CORE 문서로 분배 후 제거
- Where: `agents/harness-initializer.md`, `skills/harness-init/SKILL.md`
- How: harness-initializer 재실행 모드에서 legacy 파일 감지 → 규칙/내용을 해당 CORE 문서에 분배 → 원본 삭제. quality-score.md, tech-debt.md는 유지. 정보 손실 없음 검증.
- Verify:
  - 마이그레이션 후 index.md, golden-rules.md, observability.md 부재 확인
  - golden-rules.md의 모든 규칙이 CORE 문서에 존재 확인
  - observability.md 내용이 FRONTEND.md/BACKEND.md 등에 분배 확인
  - quality-score.md, tech-debt.md 유지 확인

## Phase 4: CORE-Lint Traceability

- What: lint skill 규칙에 CORE 문서 참조 추가, lint-manage에 alignment 체크 로직 추가
- Where: `skills/lint-manage/SKILL.md`, `.claude/skills/lint-*/SKILL.md`
- How: lint skill SKILL.md에 `upstream:` 필드 추가. lint-manage가 규칙 생성/업데이트 시 CORE 문서 참조 필수 확인. CORE 변경 시 영향받는 lint skill 식별 → 규칙 업데이트.
- Verify:
  - 각 lint skill에 upstream CORE 참조 존재 확인
  - CORE 문서 변경 후 lint-manage가 영향받는 skill 식별 확인
  - 참조 없는 lint rule 생성 시도 시 경고 확인

## Phase 5: Reference Management

- What: 의존성 분석 → 레퍼런스 자동 수집, llms.txt 우선, 수동 추가 지원, 스테일 정리
- Where: `agents/harness-initializer.md`, `skills/harness-init/SKILL.md`
- How: harness-initializer가 dependency manifest 파싱 → 각 라이브러리의 llms.txt URL 시도 → 성공 시 저장, 실패 시 공식 문서에서 레퍼런스 생성. `harness/references/<name>.md` 형식. 재실행 시 새 의존성 추가, 제거된 의존성 정리.
- Verify:
  - package.json의 주요 라이브러리에 대한 레퍼런스 파일 생성 확인
  - llms.txt 있는 라이브러리는 직접 fetch 확인
  - 의존성 제거 후 재실행 시 레퍼런스 정리 확인

## Phase 6: Merge-Time CORE Update Hook

- What: 토픽 브랜치 머지 시 CORE 문서 자동 업데이트
- Where: settings.json (Claude Code hook), `agents/harness-initializer.md`
- How: Claude Code의 hook 시스템으로 머지 이벤트 감지. 머지된 토픽의 설계 문서에서 실현된 결정 추출 → 해당 CORE 문서 업데이트. CLAUDE.md harness 섹션도 필요 시 갱신. realized facts만 반영.
- Verify:
  - 토픽 머지 후 관련 CORE 문서 업데이트 확인
  - 미머지 토픽의 내용이 CORE에 반영되지 않음 확인
  - CORE 문서 추가/제거 시 CLAUDE.md 섹션 갱신 확인
