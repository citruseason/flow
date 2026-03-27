# Blueprint: Harness Gap Analysis

## Components

- **CoreDocGenerator** — 프로젝트 분석 후 CORE 도메인 문서 생성/업데이트
- **ProjectDetector** — 프로젝트 특성 감지 (프레임워크, 언어, 아키텍처 패턴)
- **ClaudeMdManager** — CLAUDE.md harness 섹션 생성/업데이트
- **LegacyMigrator** — index.md, golden-rules.md, observability.md → CORE 문서로 분배
- **CoreLintBridge** — CORE 문서 ↔ lint skill 규칙 간 추적성 관리
- **MergeHook** — 머지 이벤트 감지 → CORE 문서 업데이트 트리거
- **ReferenceCollector** — 의존성 분석 → llms.txt 수집 또는 레퍼런스 생성
- **ReferenceCleanup** — 제거된 의존성의 레퍼런스 파일 정리

## Hierarchy

```
harness-initializer (agent)
├── ProjectDetector
│   └── Detection rules (framework → CORE doc mapping)
├── CoreDocGenerator
│   └── CORE document templates (PRODUCT, SECURITY, FRONTEND, ...)
├── ClaudeMdManager
│   └── Harness section template (≤100 lines)
├── LegacyMigrator
│   └── Rule distribution logic
└── ReferenceCollector
    └── llms.txt fetcher + doc extractor

lint-manage (skill)
└── CoreLintBridge
    └── CORE-lint alignment checker

merge-hook (new)
└── MergeHook
    └── CORE updater (realized facts only)

ReferenceCleanup
└── dependency diff → stale file removal
```

## Connections

- ProjectDetector → CoreDocGenerator (감지된 특성이 생성할 CORE 문서 결정)
- CoreDocGenerator → ClaudeMdManager (생성된 CORE 문서 목록 → harness 섹션 업데이트)
- LegacyMigrator → CoreDocGenerator (마이그레이션된 규칙을 CORE 문서에 주입)
- CoreDocGenerator → CoreLintBridge (CORE 변경 → 영향받는 lint skill 식별)
- CoreLintBridge → lint-* skills (규칙 업데이트 + CORE 참조 추가)
- MergeHook → CoreDocGenerator (머지 이벤트 → 실현된 설계 결정으로 CORE 업데이트)
- MergeHook → ClaudeMdManager (CORE 맵 변경 시 harness 섹션 업데이트)
- ReferenceCollector → `harness/references/` (레퍼런스 파일 생성)
- ReferenceCleanup → `harness/references/` (스테일 파일 제거)

## External Boundaries

- **llms.txt endpoints** — 라이브러리 공식 llms.txt URL (fetch 대상)
- **Library documentation sites** — llms.txt 미제공 시 레퍼런스 생성 소스
- **Dependency manifest files** — package.json, pyproject.toml, Cargo.toml, go.mod 등
- **Git merge events** — 머지 감지 트리거 (hook 또는 CI)
- **User project CLAUDE.md** — harness 섹션 삽입 대상
