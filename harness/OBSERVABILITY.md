# 관찰 가능성

## 로깅 형식

모든 런타임 로깅은 구조화된 JSON을 사용한다. WebSocket 서버(`skills/meeting/scripts/server.cjs`)는 stdout에 한 줄당 하나의 JSON 객체를 출력한다:

```json
{"type": "server-started", "port": 52341, "host": "127.0.0.1", "url": "http://localhost:52341", "screen_dir": "/path/to/session"}
{"type": "screen-added", "file": "/path/to/file.html"}
{"type": "screen-updated", "file": "/path/to/file.html"}
{"source": "user-event", "type": "click", "choice": "a", "text": "Option A", "timestamp": 1706000101}
{"type": "server-stopped", "reason": "idle timeout"}
```

셸 스크립트는 에러에 대해 JSON을 출력한다:

```json
{"error": "Server failed to start within 5 seconds"}
{"error": "Unknown argument: --bad-flag"}
{"status": "stopped"}
{"status": "not_running"}
```

## 로그 수준

- **ERROR:** 주의가 필요한 예기치 않은 장애 (예: WebSocket 디코드 실패, fs.watch 에러)
- **WARN:** 복구 가능한 문제 또는 성능 저하 (현재 미사용 -- 향후 추가 권장)
- **INFO:** 중요한 상태 변경 및 비즈니스 이벤트 (server-started, screen-added, server-stopped)
- **DEBUG:** 개발용 진단 정보 (현재 미사용 -- 향후 추가 권장)

## 로깅 규칙

- 서버는 구조화된 이벤트에 `console.log(JSON.stringify({...}))`를, 파싱 실패에 `console.error(...)`를 사용한다
- 셸 스크립트는 에러 출력에 `echo '{"error": "..."}'`를, 상태에 `echo '{"status": "..."}'`를 사용한다
- 로그 수준을 명시적으로 설정하지 않는다 -- 모든 출력은 stdout 또는 stderr로 전달된다
- 세션 생명주기 이벤트(started, stopped)에는 항상 `type` 필드를 포함한다
- 사용자 상호작용 이벤트에는 항상 `source: "user-event"` 필드를 포함한다

## 에러 전파

```
에이전트 출력 에러       -> 스킬이 구조화된 소견을 읽고 처리
서버 런타임 에러         -> stdout/stderr에 JSON 출력, 서버는 계속 실행
셸 스크립트 에러         -> JSON 에러 출력 + 0이 아닌 종료 코드
검토 실패               -> 작성자-검토자 루프 (최대 3회) -> 사용자 에스컬레이션
구현 실패               -> SDD 재시도 (최대 2회) -> 사용자 에스컬레이션
```

## 메트릭

메트릭 계측 없음. 이 프로젝트는 영구 런타임이 없는 프롬프트 기반 CLI 플러그인이다. 관찰 가능성은 다음을 통해 달성한다:

- WebSocket 서버의 구조화된 JSON 로깅
- 린트 스킬 출력 계약 (Status/Findings/Summary)
- `harness/quality-score.md`의 품질 점수 산출
- `harness/kanban.json` 및 토픽 수준 칸반 파일의 상태 추적
