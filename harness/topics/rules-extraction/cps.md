# CPS: Rules Extraction

## Context

Flow 플러그인의 `harness/PRODUCT.md`가 제품 정의, 아키텍처 규칙, 파이프라인 규칙, 코드 컨벤션, 관찰 가능성 가이드를 모두 포함하고 있어 223줄로 비대해졌다. 에이전트가 PRODUCT.md를 읽을 때 제품 정보만 필요한 경우에도 모든 규칙을 함께 로딩해야 한다.

## Problem

1. **PRODUCT.md의 역할 혼합** — 제품 정의 문서가 아키텍처 규칙, 코드 컨벤션, 관찰 가능성 가이드까지 포함하고 있어 단일 책임 원칙을 위반한다.
2. **불필요한 컨텍스트 로딩** — 에이전트가 네이밍 규칙만 확인하려 해도 PRODUCT.md 전체를 읽어야 한다. progressive disclosure가 작동하지 않는다.
3. **규칙 관리 어려움** — 규칙을 추가/수정할 때 PRODUCT.md의 어느 섹션에 넣어야 하는지 모호하고, 파일이 계속 커진다.

## Solution

1. **PRODUCT.md를 순수 제품 정의로 축소** — 개요, 기술 스택, 에이전트/스킬 테이블, 문서 흐름만 남기고 나머지는 분리한 문서를 링크로 참조한다.
2. **아키텍처/파이프라인/관찰 가능성을 harness/ 루트 CORE 문서로 분리** — `ARCHITECTURE.md`, `PIPELINE.md`, `OBSERVABILITY.md`를 생성하여 각각의 도메인 규칙을 독립적으로 관리한다.
3. **코드 컨벤션을 harness/rules/ 디렉토리에 도메인+스택별 파일로 분리** — `{도메인}.{스택}.md` 네이밍 (예: `naming.javascript.md`, `formatting.shell.md`)으로 스택별 규칙을 독립 관리한다. 스택 무관 규칙은 `{도메인}.md` (예: `git.md`, `output-language.md`). 향후 `/harness-init`이 감지한 스택에 따라 해당 파일만 생성한다.
4. **lint-* 스킬의 upstream 참조를 새 파일 경로로 업데이트** — 기존 `harness/PRODUCT.md#architecture` 등의 참조를 `harness/ARCHITECTURE.md`, `harness/rules/naming.md` 등으로 변경한다.
5. **CLAUDE.md 하네스 섹션에 새 CORE 문서 반영** — ARCHITECTURE.md, PIPELINE.md, OBSERVABILITY.md를 CORE 문서 테이블에 추가한다.
6. **harness-initializer 에이전트가 새 구조를 생성하도록 업데이트** — 향후 `/harness-init` 실행 시 ARCHITECTURE.md, PIPELINE.md, OBSERVABILITY.md, rules/ 파일들을 생성하도록 에이전트 프롬프트를 수정한다.
