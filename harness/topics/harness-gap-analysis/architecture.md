# Architecture: Harness Gap Analysis

## Stack

- Markdown — CORE 문서, CLAUDE.md harness 섹션, 레퍼런스 파일
- JSON — kanban
- Bash — merge hook, 레퍼런스 수집 스크립트
- Agent prompts (Markdown frontmatter) — harness-initializer 확장, lint-manage 확장

## Structure

```
harness/
├── PRODUCT.md, SECURITY.md          ← always-generated CORE
├── FRONTEND.md, BACKEND.md, ...     ← conditional CORE
├── quality-score.md, tech-debt.md   ← cross-cutting (retained)
├── kanban.json                      ← topic tracking
├── references/                      ← external library refs
│   └── <library-name>.md
└── topics/<topic>/                  ← per-topic artifacts

user-project/
└── CLAUDE.md                        ← harness section appended

.claude/skills/lint-*/
└── SKILL.md                         ← CORE doc references added
```

기존 `index.md`, `golden-rules.md`, `observability.md`는 제거되고 CORE 문서 + CLAUDE.md로 대체된다.

## Patterns

- **Detection → Generation** — ProjectDetector가 프로젝트 신호를 감지하고 해당하는 CORE 문서만 생성. 불필요한 문서 생성 방지.
- **Append-only CLAUDE.md** — 기존 사용자 내용을 건드리지 않고 harness 섹션만 추가/업데이트. 마커 주석(`<!-- harness:start -->` / `<!-- harness:end -->`)으로 섹션 경계 표시.
- **Realized facts only** — CORE 문서는 머지된 코드에서 파생된 사실만 포함. 미머지 토픽의 계획/제안은 포함하지 않음.
- **Traceability** — 모든 lint rule → CORE 문서 원칙으로 역추적 가능. `upstream: harness/BACKEND.md#api-patterns` 형식.
- **Progressive disclosure** — CLAUDE.md(100줄) → CORE 문서(도메인별) → topic 문서(상세). 에이전트가 필요한 깊이만큼만 읽음.

## Constraints

- CLAUDE.md harness 섹션은 마커 주석 사이에만 존재. 마커 밖의 사용자 내용 불변.
- CORE 문서 파일명은 대문자 (PRODUCT.md, SECURITY.md, ...). 소문자 파일은 cross-cutting 운영 문서 (quality-score.md, tech-debt.md).
- Merge hook은 settings.json의 Claude Code hook으로 구현. Git post-merge hook이 아닌 Claude Code의 hook 시스템 사용.
- Detection config는 harness-initializer agent 프롬프트에 내장. 별도 JSON 파일 불필요.
- 레퍼런스 파일은 `harness/references/<library-name>.md` 형식. 하나의 라이브러리 = 하나의 파일.
