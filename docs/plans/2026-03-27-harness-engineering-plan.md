# Implementation Plan: Harness Engineering Integration

## Overview

5 phases: harness-init foundation first, then meeting and design-doc skills, then lint/doc-garden, finally implement modification and cleanup. Each phase is independently verifiable. All changes are prompt files (SKILL.md, agent .md) and config — no application code.

## Spec Reference

`docs/specs/2026-03-27-harness-engineering-design.md`

## Implementation Steps

### Phase 1: Foundation — `/harness-init` Skill & Agent (3 files)

이 Phase 완료 후 검증: `/harness-init` 실행 시 harness-initializer 에이전트가 디스패치되고, 스킬 프롬프트가 올바른 흐름(코드베이스 분석 → 스캐폴딩 → lint-* 생성)을 안내하는지 확인

1. **Create harness-initializer agent** (File: `agents/harness-initializer.md`)
   - Action: Opus 모델 에이전트 프롬프트 작성. 코드베이스 분석(구조, 스택, 아키텍처, 컨벤션), harness/ 스캐폴딩, lint-* 스킬 생성 역할 정의. lint-* 출력 계약(Status/Findings/Summary 마크다운 형식)을 생성 스킬 SKILL.md에 포함하도록 명시. 재실행 시 기존 내용 보존 로직 포함. 도구: Read, Write, Edit, Bash, Grep, Glob
   - Why: harness-init의 핵심 작업을 수행하는 에이전트
   - Dependencies: None
   - Risk: Medium — 코드베이스 분석 품질이 전체 하네스의 기반이 됨

2. **Create harness-init skill** (File: `skills/harness-init/SKILL.md`)
   - Action: 스킬 프롬프트 작성. 실행 흐름 정의: harness-initializer 디스패치 → 분석 결과 사용자 확인 → harness/ 디렉터리 구조 생성(index.md, kanban.json, quality-score.md, observability.md, golden-rules.md, tech-debt.md, references/) → 사용자 프로젝트의 .claude/skills/에 lint-architecture/, lint-code-convention/, lint-{framework}/ 생성 → 사용자 리뷰 → git commit. 재실행 시 diff 기반 업데이트 모드 포함
   - Why: 하네스 세팅의 진입점 스킬
   - Dependencies: Step 1 (에이전트가 먼저 있어야 디스패치 가능)
   - Risk: Low

3. **Update plugin.json — add harness-initializer agent** (File: `.claude-plugin/plugin.json`)
   - Action: agents 배열에 `"./agents/harness-initializer.md"` 추가
   - Why: 플러그인이 새 에이전트를 인식하려면 매니페스트에 등록 필요
   - Dependencies: Step 1
   - Risk: Low

### Phase 2: `/meeting` Skill & Agents (3 files)

이 Phase 완료 후 검증: `/meeting "test-topic"` 실행 시 meeting-facilitator가 대화를 진행하고, Meeting Log → CPS → PRD 생성 흐름이 올바르게 안내되는지 확인. 후속 실행 시 미확인 사항 검토 흐름 포함 여부 확인

4. **Create meeting-facilitator agent** (File: `agents/meeting-facilitator.md`)
   - Action: Opus 모델 에이전트 프롬프트 작성. 기존 spec-facilitator의 대화 패턴(한 번에 하나씩 질문, 객관식 선호, 2-3가지 접근 제안)을 계승하되, 산출물을 Meeting Log → CPS → PRD로 변경. 미확인 사항 추적 로직(대화 중단 시 기록, 유효성 판단, 해소 기록) 포함. 후속 실행 시 기존 Meeting Log/CPS/PRD 읽기 + 미확인 사항 검토 + history/ 보관 후 업데이트 흐름 포함. 토픽 kanban.json 생성/업데이트 로직 포함. 도구: Read, Write, Edit, Bash, Grep, Glob
   - Why: /meeting의 핵심 대화 및 문서 생성 에이전트
   - Dependencies: None
   - Risk: High — 가장 중요한 단계의 에이전트, 대화 품질이 전체 워크플로 품질 결정

5. **Create meeting-reviewer agent** (File: `agents/meeting-reviewer.md`)
   - Action: Sonnet 모델 에이전트 프롬프트 작성. CPS 검증 기준(Context 정확성, Problem 명확성/측정가능성, Solution이 Problem을 직접 해결하는지) 및 PRD 검증 기준(CPS Solution→기능 요구사항 전환 완전성, 수용 기준 검증가능성, 기능/비기능 모순 부재, 미확인 사항 표기) 정의. 최대 3회 반복 후 사용자 에스컬레이션. 도구: Read, Grep, Glob
   - Why: CPS/PRD 품질 보장
   - Dependencies: None
   - Risk: Low

6. **Create meeting skill** (File: `skills/meeting/SKILL.md`)
   - Action: 스킬 프롬프트 작성. 신규 실행 흐름(토픽 디렉터리 생성 → meeting-facilitator 디스패치 → Meeting Log 저장 → CPS/PRD 생성 → meeting-reviewer 디스패치 → 사용자 리뷰 → kanban 업데이트 → /design-doc 안내)과 후속 실행 흐름(기존 문서 읽기 → 미확인 사항 검토 → 대화 → history/ 보관 → CPS/PRD 업데이트 → 리뷰) 정의. Meeting Log 형식 템플릿(논의 사항, 결정 사항, 미확인 사항, 해소된 미확인 사항) 포함. kanban.json 업데이트 시 스펙의 정규 스키마 참조 (spec lines 112-142: topic, phase, last_updated, meetings, steps.done/in_progress/backlog). 루트 kanban.json도 동기 업데이트
   - Why: 기존 /spec을 대체하는 핵심 스킬
   - Dependencies: Steps 4, 5 (에이전트가 먼저 있어야 함)
   - Risk: Medium

### Phase 3: `/design-doc` Skill & Agents (3 files)

이 Phase 완료 후 검증: `/design-doc <topic>` 실행 시 design-doc-writer가 PRD를 읽고 4개 문서(spec, blueprint, architecture, code-dev-plan)를 순차 생성하는 흐름이 올바른지 확인

7. **Create design-doc-writer agent** (File: `agents/design-doc-writer.md`)
   - Action: Opus 모델 에이전트 프롬프트 작성. PRD 읽기 → 4개 문서 순차 생성(spec.md, blueprint.md, architecture.md, code-dev-plan.md). 각 문서 생성 후 사용자 승인 게이트. code-dev-plan 형식(Phase별 방향/위치/접근법/테스트). 기존 문서 업데이트 시 history/ 보관 후 갱신. PRD 변경 시 diff 기반 영향 분석 → 해당 문서만 업데이트. 도구: Read, Write, Edit, Bash, Grep, Glob
   - Why: /design-doc의 핵심 문서 작성 에이전트
   - Dependencies: None
   - Risk: Medium — 4개 문서 간 일관성 유지가 관건

8. **Create design-doc-reviewer agent** (File: `agents/design-doc-reviewer.md`)
   - Action: Sonnet 모델 에이전트 프롬프트 작성. 4개 문서 간 일관성 검증, PRD 요구사항 누락 체크, code-dev-plan의 phase가 architecture와 정합하는지 확인. 최대 3회 반복. 도구: Read, Grep, Glob
   - Why: 설계 문서 품질 보장
   - Dependencies: None
   - Risk: Low

9. **Create design-doc skill** (File: `skills/design-doc/SKILL.md`)
   - Action: 스킬 프롬프트 작성. 실행 흐름(PRD 읽기 → 미확인 사항 경고 → 기존 문서 history/ 보관 → design-doc-writer 디스패치 → design-doc-reviewer 검증 → 사용자 리뷰 → kanban 업데이트 → /implement 안내). PRD 변경 시 연동 흐름(history/ diff → design-doc-writer가 영향 문서 식별 → 업데이트 제안). kanban.json 업데이트 시 스펙의 정규 스키마 참조 (spec lines 112-142)
   - Why: 기존 /plan을 대체하는 스킬
   - Dependencies: Steps 7, 8
   - Risk: Low

### Phase 4: `/lint` & `/doc-garden` Skills & Agents (4 files)

이 Phase 완료 후 검증: `/lint <topic>` 실행 시 lint-requirements 로직 → lint-* 스킬 탐색/호출 → doc-gardener → 통합 리포트 흐름이 올바른지 확인. `/doc-garden` 독립 실행 가능 여부 확인

10. **Create lint-reviewer agent** (File: `agents/lint-reviewer.md`)
    - Action: Sonnet 모델 에이전트 프롬프트 작성. lint-requirements 검증 로직(PRD 수용 기준 대비 구현 확인, spec 인터페이스/데이터 모델 준수). lint-* 스킬 자동 탐색(.claude/skills/lint-* glob) 및 순차 호출 → 출력 계약 파싱 → 결과 통합. quality-score.md 점수 산출(항목별 배점 기반 에이전트 판단, 근거 기록). 통합 리포트 생성(PASS/WARNING/FAIL). 도구: Read, Write, Edit, Bash, Grep, Glob
    - Why: /lint의 핵심 검증 에이전트
    - Dependencies: None
    - Risk: High — lint-* 스킬 출력 파싱과 통합 리포트 생성의 정확성이 중요

11. **Create doc-gardener agent** (File: `agents/doc-gardener.md`)
    - Action: Sonnet 모델 에이전트 프롬프트 작성. harness/ 문서와 현재 코드 구조 비교, lint-* references/ 규칙과 실제 패턴 비교, quality-score.md staleness 플래그(점수 재산출은 안 함), tech-debt.md 해소 항목 체크. harness/ 문서와 lint-* references/만 수정 가능(코드베이스 자체 수정 금지). 도구: Read, Write, Edit, Grep, Glob
    - Why: 문서/규칙 최신 상태 유지
    - Dependencies: None
    - Risk: Low

12. **Create lint skill** (File: `skills/lint/SKILL.md`)
    - Action: 스킬 프롬프트 작성. 실행 흐름: ① /lint 스킬이 직접 lint-requirements 로직 실행(PRD/spec 대비 구현 확인 — 별도 에이전트 없이 스킬 프롬프트 내에서 처리) → ② lint-reviewer 에이전트 디스패치(lint-* 스킬 탐색/호출/통합 + quality-score 산출) → ③ doc-gardener 에이전트 디스패치 → 통합 리포트 → PASS/WARNING/FAIL 분기. FAIL 시 SDD worker로 코드 수정 → 재실행(최대 2회) → 에스컬레이션. kanban 업데이트. 자율 실행 원칙(implement에서 자동 호출 시 사용자 개입 없음) 명시
    - Why: 기존 /code-review를 대체하는 스킬
    - Dependencies: Steps 10, 11
    - Risk: Medium

13. **Create doc-garden skill** (File: `skills/doc-garden/SKILL.md`)
    - Action: 스킬 프롬프트 작성. doc-gardener 에이전트 디스패치 → 결과 사용자에게 알림. /lint 내에서 자동 호출될 때와 독립 실행될 때 모두 동일 에이전트 사용
    - Why: 독립적 문서 정리 스킬
    - Dependencies: Step 11
    - Risk: Low

### Phase 5: `/implement` 수정 & 정리 (8 files 수정/삭제)

이 Phase 완료 후 검증: plugin.json에 새 에이전트만 등록, 기존 에이전트/스킬 파일 삭제 확인, hooks 메시지 업데이트 확인, CLAUDE.md 업데이트 확인

14. **Modify implement skill for harness integration** (File: `skills/implement/SKILL.md`)
    - Action: 기존 SKILL.md 수정. .progress.md 참조를 kanban.json으로 교체. docs/plans/ 참조를 harness/topics/<topic>/ 참조로 변경. history/ diff 기반 변경 감지 스텝 추가(history 있으면 diff → 변경 phase만 재작업, 없으면 전체 실행). phase 완료 시 lint-* references/ 영향 분석 → 자동 업데이트 로직 추가. 전체 phase 완료 시 /lint 자동 실행. 자율 실행 원칙(사용자 개입 없이 lint까지 진행, 에스컬레이션 시에만 보고) 명시. SDD + TDD 패턴과 2단계 리뷰 게이트는 유지. 기존 Worktree Mode는 제거 — 새 워크플로에서는 토픽 kanban.json이 진행 추적을 담당하므로 .progress.md 기반 worktree 분기 로직이 불필요. /using-worktree 스킬은 독립적으로 유지되므로 사용자가 필요 시 수동으로 조합 가능
    - Why: 하네스 토픽/칸반 시스템과 연동
    - Dependencies: Phase 4 완료 (lint 스킬이 있어야 자동 호출 가능)
    - Risk: High — 가장 많은 기존 로직 변경, 기존 SDD/TDD/리뷰 패턴과의 호환 필요

15. **Move visual-companion assets and delete old skills**
    - Action-a: spec/의 visual-companion.md 및 scripts/를 meeting/ 하위로 이동할지 사용자에게 확인. 승인 시 `skills/meeting/visual-companion.md`, `skills/meeting/scripts/`로 복사
    - Action-b: 4개 스킬 디렉터리 전체 삭제 (`skills/spec/`, `skills/plan/`, `skills/code-review/`, `skills/amend/`)
    - Note: `skills/update-plugin/`은 유지 (하네스 변경과 무관한 플러그인 관리 스킬)
    - Why: 새 스킬로 대체됨
    - Dependencies: Steps 6, 9, 12 (대체 스킬이 모두 준비된 후)
    - Risk: Medium — visual-companion 자산 이동 판단 필요

16. **Delete old agents** (Files: `agents/spec-facilitator.md`, `agents/spec-reviewer.md`, `agents/plan-writer.md`, `agents/plan-reviewer.md`, `agents/code-reviewer.md`, `agents/amend-orchestrator.md`)
    - Action: 6개 에이전트 파일 삭제
    - Why: 새 에이전트로 대체됨
    - Dependencies: Step 15 (스킬 삭제 후)
    - Risk: Low

17. **Update plugin.json — final agent/skill list** (File: `.claude-plugin/plugin.json`)
    - Action: agents 배열을 새 에이전트 7개(harness-initializer, meeting-facilitator, meeting-reviewer, design-doc-writer, design-doc-reviewer, doc-gardener, lint-reviewer)로 교체. description을 새 워크플로 반영으로 업데이트 (예: "Complete development workflow — harness setup, meeting-driven requirements, design docs, implementation, and lint review"). keywords 배열도 업데이트 ("harness", "meeting", "design-doc", "lint" 등). version 범프 (0.0.6). marketplace.json도 동일하게 version, description 업데이트
    - Why: 플러그인 매니페스트를 새 구조에 맞춤
    - Dependencies: Steps 15, 16
    - Risk: Low

18. **Update hooks** (File: `hooks/hooks.json`)
    - Action: SessionStart 메시지를 `"[Flow] Plugin loaded. Use /harness-init to set up your project, then /meeting to start."` 로 변경
    - Why: 새 워크플로 진입점 안내
    - Dependencies: None
    - Risk: Low

19. **Update CLAUDE.md** (File: `CLAUDE.md`)
    - Action: Workflow 섹션을 새 워크플로(harness-init → meeting → design-doc → implement → lint)로 교체. Architecture 섹션의 에이전트/스킬 테이블 업데이트. Document Flow 섹션을 harness/ 구조로 변경. 기타 참조 업데이트
    - Why: 프로젝트 문서를 새 구조에 맞춤
    - Dependencies: Steps 15-17 (구조 확정 후)
    - Risk: Low

20. **Update README.md** (File: `README.md`)
    - Action: 사용자 대면 문서를 새 워크플로로 업데이트. 설치/사용법, 스킬 목록, 워크플로 다이어그램 변경
    - Why: 외부 사용자를 위한 문서 업데이트
    - Dependencies: Step 19
    - Risk: Low

## Testing Strategy

이 프로젝트는 프롬프트 파일과 설정 파일로만 구성되어 코드 테스트는 해당 없음. 대신:

- **Prompt validation**: 각 SKILL.md와 에이전트 .md가 올바른 frontmatter(name, description, tools, model)를 포함하는지 확인
- **Integration validation**: plugin.json의 agents 배열이 실제 파일과 매칭하는지, skills/ 디렉터리 구조가 올바른지 확인
- **Workflow validation**: 각 Phase 완료 후 해당 스킬의 기본 실행 흐름을 수동 테스트
- **Regression check**: /sdd, /tdd, /using-worktree, /update-plugin 이 기존대로 동작하는지 확인

## Risks & Mitigations

- **Risk**: Visual companion 자산(scripts/, visual-companion.md) 처리
  - Mitigation: Phase 5에서 사용자에게 /meeting으로 이동할지 확인 후 처리
- **Risk**: 기존 사용자가 docs/specs/, docs/plans/ 경로를 사용 중
  - Mitigation: 기존 docs/ 디렉터리는 삭제하지 않음. 새 프로젝트는 harness/ 사용, 기존 문서는 참조용으로 유지
- **Risk**: /implement 수정 시 기존 SDD/TDD 패턴과의 호환
  - Mitigation: SDD/TDD 참조 파일(references/)은 변경하지 않음. 참조 경로와 진행 추적만 변경

## Success Criteria

- [ ] plugin.json에 새 에이전트 7개만 등록되고 기존 6개는 제거됨
- [ ] skills/ 에 새 스킬 5개(harness-init, meeting, design-doc, lint, doc-garden)가 존재하고 기존 4개(spec, plan, code-review, amend)는 삭제됨
- [ ] 각 스킬 SKILL.md에 올바른 frontmatter와 실행 흐름이 포함됨
- [ ] hooks 메시지가 새 워크플로를 안내함
- [ ] CLAUDE.md와 README.md가 새 구조를 반영함

## Execution Strategy

- type: direct
- branch_prefix: feature/harness-engineering
