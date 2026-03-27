# 파이프라인

## 순차 워크플로우

```
/harness-init -> /meeting -> /design-doc -> /implement -> /lint
```

- 단계를 건너뛸 수 없다. 각 단계의 출력은 다음 단계의 입력이 된다.
- **자율 실행 경계:** `/implement` 시작부터 `/lint` 완료까지 사용자 개입 없이 진행된다. 심각한 불일치나 해결 불가능한 차단 문제가 있을 때만 에스컬레이션한다.
- **사용자 승인 게이트:** 미팅과 설계 문서 단계에서 사용자 승인이 필요하다. CPS, PRD, 최종 설계 문서 세트를 승인해야 다음 단계로 진행할 수 있다. 이 게이트를 우회해서는 안 된다.

## 문서 흐름

```
harness/
├── PRODUCT.md, SECURITY.md, ARCHITECTURE.md, PIPELINE.md, OBSERVABILITY.md
├── rules/                          <- 도메인+스택별 규칙 파일
├── kanban.json, quality-score.md, tech-debt.md
└── topics/<topic>/
    ├── meetings/, cps.md, prd.md
    ├── spec.md, blueprint.md, architecture.md, code-dev-plan.md, test-cases.md
    ├── history/                        <- 버전 추적 (최대 2개)
    └── kanban.json                     <- 토픽 진행 추적
```

## 문서 이력

- **최대 2개 버전의 FIFO 순환:** 문서를 `history/`에 보관할 때 일관된 FIFO 순환을 사용한다: v1 = 가장 최근 이전 버전, v2 = 더 오래된 버전. 문서당 최대 2개의 보관 버전을 유지한다.
