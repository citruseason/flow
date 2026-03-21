# Flow

**Brainstorming-first design workflow plugin for Claude Code.**

ECC(Everything Claude Code)의 컴패니언 플러그인으로, 구현 전 아이디어 탐색과 설계 검증 단계를 담당합니다.

```
/brainstorm (Flow)  -->  spec doc  -->  /plan (ECC)  -->  /tdd (ECC)  -->  /code-review (ECC)
   아이디어 탐색            산출물          구현 계획        TDD 구현         코드 리뷰
```

---

## Why Flow?

ECC는 구현 단계에 강력한 워크플로우를 제공하지만, **"무엇을 만들 것인가"** 를 결정하는 설계 단계는 다루지 않습니다. Flow는 이 공백을 채웁니다.

- 아이디어를 설계 문서로 구체화하는 구조화된 대화 프로세스
- 한 번에 하나의 질문, 2-3개 접근법 비교, 단계별 승인
- 브라우저 기반 시각적 목업/다이어그램 (Visual Companion)
- 서브에이전트 기반 스펙 검증 루프
- 완료 후 ECC의 `/plan`으로 자연스러운 핸드오프

---

## Quick Start

### Prerequisites

- [Claude Code](https://claude.ai/code) CLI 설치
- Node.js >= 18 (Visual Companion 서버용)

### Step 1: ECC 설치

Flow는 ECC와 함께 사용하도록 설계되었습니다. ECC가 먼저 설치되어 있어야 합니다.

```bash
# ECC 마켓플레이스 추가 및 플러그인 설치
/plugin marketplace add affaan-m/everything-claude-code
/plugin install everything-claude-code@everything-claude-code
```

ECC rules 수동 설치 (필수 - 프로젝트 레벨):

```bash
git clone https://github.com/affaan-m/everything-claude-code.git

# 현재 프로젝트에 rules 설치
mkdir -p .claude/rules
cp -r everything-claude-code/rules/common/* .claude/rules/

# 사용하는 언어 선택 (필요한 것만 복사)
cp -r everything-claude-code/rules/typescript/* .claude/rules/
cp -r everything-claude-code/rules/python/* .claude/rules/
cp -r everything-claude-code/rules/golang/* .claude/rules/
# cp -r everything-claude-code/rules/java/* .claude/rules/
# cp -r everything-claude-code/rules/kotlin/* .claude/rules/
# cp -r everything-claude-code/rules/rust/* .claude/rules/
# cp -r everything-claude-code/rules/cpp/* .claude/rules/
# cp -r everything-claude-code/rules/swift/* .claude/rules/
# cp -r everything-claude-code/rules/php/* .claude/rules/
# cp -r everything-claude-code/rules/perl/* .claude/rules/
```

> ECC 설치에 대한 자세한 내용은 [ECC README](https://github.com/affaan-m/everything-claude-code)를 참고하세요.

### Step 2: Flow 설치

**방법 A: 플러그인 설치 (권장)**

```bash
# Flow 마켓플레이스 추가 및 설치
/plugin marketplace add <your-username>/flow
/plugin install flow@flow-marketplace
```

**방법 B: 수동 설치**

```bash
git clone <flow-repo-url>
cd flow

# agents 복사 (명시적 파일 경로 필수)
cp agents/spec-reviewer.md ~/.claude/agents/
cp agents/design-facilitator.md ~/.claude/agents/

# commands 복사
cp -r commands/ ~/.claude/commands/

# skills 복사
cp -r skills/brainstorming/ ~/.claude/skills/brainstorming/
```

### Step 3: 사용 시작

```bash
# 브레인스토밍 시작
/brainstorm "사용자 인증 기능 추가"

# 설계 완료 후 ECC로 핸드오프
/plan    # ECC의 구현 계획
/tdd     # ECC의 TDD 워크플로우
```

---

## What's Inside

```
flow/
|-- .claude-plugin/
|   |-- plugin.json               # 플러그인 매니페스트
|   |-- marketplace.json          # 마켓플레이스 등록 정보
|
|-- agents/
|   |-- design-facilitator.md     # 브레인스토밍 진행 에이전트 (Opus)
|   |-- spec-reviewer.md          # 스펙 검증 에이전트 (Sonnet)
|
|-- commands/
|   |-- brainstorm.md             # /brainstorm 슬래시 명령어
|
|-- skills/
|   |-- brainstorming/
|       |-- SKILL.md              # 핵심 브레인스토밍 스킬
|       |-- visual-companion.md   # 브라우저 기반 시각적 동반자 가이드
|       |-- ecc-handoff.md        # ECC 연계 핸드오프 프로토콜
|       |-- scripts/
|           |-- server.cjs        # Zero-dep WebSocket 서버
|           |-- start-server.sh   # 서버 시작
|           |-- stop-server.sh    # 서버 종료
|           |-- helper.js         # 브라우저 클라이언트
|           |-- frame-template.html  # CSS 프레임
|
|-- hooks/
|   |-- hooks.json                # 세션 시작 알림
|
|-- CLAUDE.md                     # 프로젝트 가이드
|-- README.md
```

---

## How It Works

### Brainstorming Process

`/brainstorm` 명령어를 실행하면 다음 프로세스가 시작됩니다:

1. **프로젝트 탐색** - 파일, 문서, 최근 커밋 확인
2. **Visual Companion 제안** - 시각적 질문이 예상되면 브라우저 동반자 제안
3. **질문** - 한 번에 하나씩, 객관식 우선
4. **접근법 제시** - 2-3개 방안을 트레이드오프와 함께 비교
5. **설계 제시** - 섹션별 복잡도에 맞춰 단계적 승인
6. **스펙 작성** - `docs/specs/YYYY-MM-DD-<topic>-design.md`로 저장 및 커밋
7. **스펙 리뷰 루프** - `spec-reviewer` 에이전트가 검증 (최대 3회)
8. **사용자 최종 승인** - 사용자가 스펙 파일 직접 확인
9. **ECC 핸드오프** - `/plan` 명령어로 구현 계획 단계 전환

### Visual Companion

UI 목업, 와이어프레임, 아키텍처 다이어그램 등을 브라우저에서 실시간으로 보여주는 도구입니다.

- Zero-dependency Node.js WebSocket 서버
- HTML 파일 작성 -> 서버가 자동 감지 -> 브라우저에 표시
- 사용자 클릭/선택이 `.events` 파일로 기록
- 질문별로 브라우저/터미널 판단 (시각적 질문만 브라우저 사용)

```bash
# 수동 시작 (보통 스킬이 자동 관리)
skills/brainstorming/scripts/start-server.sh --project-dir /path/to/project

# 종료
skills/brainstorming/scripts/stop-server.sh $SCREEN_DIR
```

### ECC Integration

Flow는 ECC와 **역할이 겹치지 않도록** 설계되었습니다:

| 담당 | Flow | ECC |
|------|------|-----|
| 아이디어 탐색 | /brainstorm | - |
| 설계 문서 작성 | spec-reviewer | - |
| 구현 계획 | - | /plan |
| TDD 개발 | - | /tdd |
| 코드 리뷰 | - | /code-review |
| 빌드 에러 | - | /build-fix |
| E2E 테스트 | - | /e2e |
| 패턴 학습 | - | /learn, /evolve |

핸드오프 지점: Flow가 승인된 스펙 문서를 `docs/specs/`에 저장하면, ECC의 `/plan`이 이 문서를 입력으로 사용합니다.

---

## Configuration

### Hook Profile

Flow의 훅은 최소한으로 구성되어 있습니다 (세션 시작 알림 1개). ECC의 훅 프로필과 독립적으로 동작합니다.

### Spec Location

기본 스펙 저장 경로는 `docs/specs/`입니다. 프로젝트별로 변경하려면 브레인스토밍 중 위치를 지정하면 됩니다.

### Visual Companion Storage

Visual Companion의 목업 파일은 `.flow/brainstorm/` 디렉토리에 저장됩니다. `.gitignore`에 추가하는 것을 권장합니다:

```
.flow/
```

---

## Troubleshooting

### Flow와 ECC가 동시에 로드되지 않는 경우

두 플러그인 모두 설치되어 있는지 확인:

```bash
/plugin list
```

### Visual Companion 서버가 시작되지 않는 경우

Node.js >= 18이 설치되어 있는지 확인:

```bash
node --version
```

### /brainstorm 명령어가 인식되지 않는 경우

플러그인이 정상 설치되었는지 확인:

```bash
/plugin list flow@flow-marketplace
```

수동 설치의 경우 `commands/brainstorm.md`가 `~/.claude/commands/`에 복사되었는지 확인합니다.

---

## Credits

Core brainstorming methodology adapted from [Superpowers](https://github.com/obra/superpowers) by Jesse Vincent.

Designed to work alongside [Everything Claude Code](https://github.com/affaan-m/everything-claude-code) by Affaan Mustafa.

## License

MIT
