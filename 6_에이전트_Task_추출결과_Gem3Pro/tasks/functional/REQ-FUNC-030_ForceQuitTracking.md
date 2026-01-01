# REQ-FUNC-030: 앱 강제 종료 횟수 추적 및 전송 구현

## 1. 개요
집중 세션 중 사용자가 앱을 강제 종료한 횟수를 감지하고 서버에 전송하는 기능을 구현합니다.

## 2. 관련 요구사항
- **REQ-FUNC-030**: 시스템은 앱 강제 종료 횟수를 카운트하고 서버에 전송해야 함

## 3. 기능 범위
- **강제 종료 감지**: 앱 생명주기 이벤트를 모니터링하여 비정상 종료 감지.
- **카운트 저장**: 강제 종료 이벤트를 로컬에 저장.
- **서버 전송**: `POST /api/stats/force-quit` 엔드포인트 호출.

## 4. 구현 가이드 (Steps Hint)
1. **생명주기 모니터링**:
   - `AppDelegate` 또는 `SceneDelegate`에서 `applicationWillTerminate` 또는 `sceneDidDisconnect` 이벤트 감지.
   - 집중 세션이 활성화된 상태(`isSessionActive == true`)에서 종료되면 강제 종료 의심.
2. **상태 저장**:
   - 앱 종료 시점에 `forceQuitDetected = true` 플래그를 UserDefaults에 저장.
   - 또는 `MetricKit`을 사용하여 크래시 리포트 분석 (선택 사항).
3. **재실행 시 감지**:
   - 앱 실행 시(`didFinishLaunching`) `forceQuitDetected` 플래그 확인.
   - 플래그가 true이고 이전에 집중 세션이 활성화되어 있었다면 강제 종료로 간주.
4. **카운트 및 전송**:
   - 강제 종료 카운트 증가.
   - `POST /api/stats/force-quit` 호출: `{ timestamp, sessionType }`.
   - 전송 후 플래그 초기화.

## 5. 예외 처리
- 정상 종료와 강제 종료를 구분하기 위한 휴리스틱 로직 적용.

---

```yaml
task_id: "REQ-FUNC-030"
title: "앱 강제 종료 횟수 추적 및 서버 전송 구현"
summary: >
  집중 세션 중 사용자가 앱을 강제 종료한 횟수를 감지하고
  서버에 전송하는 기능을 구현한다. MetricKit을 활용할 수 있다.
type: "functional"
epic: "EPIC_7_STATS"
req_ids: ["REQ-FUNC-030"]
component: ["mobile.ios.analytics", "mobile.ios.lifecycle"]

context:
  srs_section: "4.1 기능 요구사항 통계 전송"
  acceptance_criteria: >
    Given 사용자가 집중 세션 중 앱을 강제 종료할 때
    When 앱이 재실행되면
    Then 강제 종료 이벤트를 감지하고 서버에 카운트 전송

inputs:
  description: "앱 생명주기 이벤트"
  state:
    - "이전 세션 활성화 여부"
    - "앱 종료 방식"

outputs:
  description: "서버로 전송되는 강제 종료 카운트"
  success_criteria:
    - "집중 세션 중 강제 종료 시 카운트가 증가해야 한다."
    - "강제 종료 이벤트가 서버에 전송되어야 한다."

preconditions:
  - "REQ-FUNC-006 또는 REQ-FUNC-010이 완료되어 집중 세션 시작 로직이 존재해야 한다."

postconditions:
  - "강제 종료 카운트가 서버에 전송된다."

exceptions:
  - "정상 종료와 강제 종료를 구분하기 위한 휴리스틱 로직 적용."

config:
  feature_flags: ["enable_force_quit_tracking"]

tests:
  unit:
    - "강제 종료 감지 로직 테스트"
  manual:
    - "타이머 실행 중 앱 스위처에서 앱을 날리고 재실행하여 카운트 증가 확인."

dependencies: ["REQ-FUNC-006", "REQ-FUNC-027"]
parallelizable: false
estimated_effort: "M"
priority: "Should"
agent_profile: ["mobile_dev"]
required_tools:
  languages: ["Swift"]
  frameworks: ["MetricKit(Optional)"]
```

