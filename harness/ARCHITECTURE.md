# 아키텍처

- **패턴:** 계층형 플러그인 -- 오케스트레이션(skills/) -> 실행(agents/) -> 인프라(scripts/)
- **모듈 구성:** 역할별 구분 (agents/, skills/, hooks/, harness/)
- **API 스타일:** 슬래시 명령 호출과 구조화된 문서 I/O

## 3계층 모델

```
skills/       오케스트레이션 계층 -- 에이전트 디스패치, 확인 게이트 관리, 칸반 업데이트, git 처리
agents/       실행 계층 -- 분석, 생성, 검토 수행
scripts/      인프라 계층 -- WebSocket 서버, 프로세스 관리
```

## 에이전트-스킬 분리

- 에이전트는 작업을 실행한다 (분석, 작성, 검토). 스킬은 오케스트레이션한다 (에이전트 디스패치, 확인 게이트 관리, 칸반 업데이트, git 커밋 처리).
- 에이전트는 오케스트레이션 작업을 절대 수행하지 않으며, 스킬은 실행 로직을 절대 포함하지 않는다.

## 의존성 방향

- 스킬은 슬래시 명령으로 다른 스킬을 참조할 수 있다.
- 에이전트는 다른 에이전트를 참조해서는 안 된다.
- 스크립트는 에이전트나 스킬을 참조해서는 안 된다.
- 의존성 흐름: skills -> agents -> references, 역방향 불가.

## 자기 완결적 스킬

- 모든 스킬 디렉토리에는 유효한 YAML 프론트매터(`name`, `description`)가 포함된 SKILL.md가 있어야 한다.
- `references/` 디렉토리는 보조 문서용으로 선택 사항이다.
- 스킬은 자체 디렉토리 또는 `harness/` 외부의 파일에 의존해서는 안 된다.

## 모델 할당

- **작성 에이전트는 Opus 사용:** harness-initializer, meeting-facilitator, design-doc-writer -- 콘텐츠를 생성하는 모든 에이전트는 `model: opus`를 사용해야 한다.
- **검토 에이전트는 Sonnet 사용:** meeting-reviewer, design-doc-reviewer, doc-gardener, lint-reviewer -- 검증 또는 검토하는 모든 에이전트는 `model: sonnet`을 사용해야 한다.
