# REQ-FUNC-023: 타이머 실행 중 크래시 복구 기능 구현

## 1. 개요
타이머 실행 중 앱이 크래시되었을 때, 재실행 시 남은 시간을 복원하거나 세션 중단 안내를 표시하는 복구 기능을 구현합니다.

## 2. 관련 요구사항
- **REQ-FUNC-023**: 시스템은 타이머 실행 중 크래시 시 복구 기능을 제공해야 함

## 3. 기능 범위
- **상태 저장**: 타이머 실행 중 주기적으로(예: 1분마다) 스냅샷 저장.
- **복구 감지**: 앱 실행 시 저장된 스냅샷 확인.
- **복구 로직**: 남은 시간 계산 및 타이머 재개 또는 중단 안내.

## 4. 구현 가이드 (Steps Hint)
1. **상태 저장**:
   - 타이머 실행 중 `TimerSnapshot` 구조체에 다음 정보 저장:
     - `scheduleId`, `startTime`, `totalDuration`, `lastSavedTime`.
   - UserDefaults에 저장 (키: `unwind_active_timer_snapshot`).
2. **복구 감지**:
   - 앱 실행 시(`didFinishLaunching` 또는 `onAppear`) 스냅샷 존재 여부 확인.
   - 스냅샷이 있고 `isRunning` 플래그가 true이면 복구 필요.
3. **복구 로직**:
   - 현재 시간과 `lastSavedTime` 비교하여 경과 시간 계산.
   - `remainingTime = totalDuration - (currentTime - startTime)`.
   - 남은 시간이 0 이상이면 타이머 재개, 음수이면 "세션이 중단되었습니다" 안내.

## 5. 예외 처리
- 스냅샷 데이터가 손상된 경우 안전하게 처리.

---

```yaml
task_id: "REQ-FUNC-023"
title: "타이머 실행 중 크래시 복구 기능 구현"
summary: >
  타이머 실행 중 앱이 크래시되었을 때, 재실행 시 남은 시간을 복원하거나
  세션 중단 안내를 표시하는 복구 기능을 구현한다.
type: "functional"
epic: "EPIC_8_STABILITY"
req_ids: ["REQ-FUNC-023"]
component: ["mobile.ios.logic", "mobile.ios.ui"]

context:
  srs_section: "4.1 기능 요구사항 예외 처리"
  acceptance_criteria: >
    Given 타이머 실행 중 앱 크래시 발생 시
    When 앱 재실행되면
    Then 남은 시간 복원 또는 "세션이 중단되었습니다" 안내

inputs:
  description: "앱 재실행 시점의 저장된 스냅샷"
  state:
    - "TimerSnapshot 데이터 (UserDefaults)"

outputs:
  description: "복구된 타이머 상태 또는 중단 안내"
  success_criteria:
    - "크래시 후 재실행 시 타이머 상태가 복원되어야 한다."
    - "남은 시간이 정확하게 계산되어야 한다."

preconditions:
  - "REQ-FUNC-006이 완료되어 타이머 실행 로직이 존재해야 한다."

postconditions:
  - "타이머 스냅샷 저장 로직이 추가되어 있다."
  - "앱 실행 시 복구 로직이 실행된다."

exceptions:
  - "스냅샷 데이터가 손상된 경우 안전하게 처리."

config:
  feature_flags: []

tests:
  unit:
    - "타이머 스냅샷 저장/로드 테스트"
    - "남은 시간 계산 로직 테스트"
  manual:
    - "타이머 실행 중 앱을 강제 종료 후 재실행하여 복구 확인."

dependencies: ["REQ-FUNC-006"]
parallelizable: false
estimated_effort: "M"
priority: "Could"
agent_profile: ["mobile_dev"]
required_tools:
  languages: ["Swift"]
  frameworks: ["SwiftUI"]
```

