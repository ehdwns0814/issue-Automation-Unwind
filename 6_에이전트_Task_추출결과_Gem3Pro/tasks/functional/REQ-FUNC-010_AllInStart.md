# REQ-FUNC-010: 올인 모드 시작 기능 구현

## 1. 개요
사용자가 하루 전체 스케줄을 완료할 때까지 앱 차단을 유지하는 "올인 모드"를 시작할 수 있는 기능을 구현합니다.

## 2. 관련 요구사항
- **REQ-FUNC-010**: 시스템은 하루 전체 스케줄을 위한 올인 모드를 제공해야 함

## 3. 기능 범위
- **올인 모드 토글**: 메인 화면 상단에 올인 모드 ON/OFF 스위치 또는 버튼.
- **시작 로직**: 오늘 날짜의 모든 스케줄 조회 및 상태 초기화.
- **차단 활성화**: `DeviceActivityCenter`를 사용하여 종료 시간 없이 차단 시작.
- **상태 표시**: "모든 일정 완료 시까지 차단됩니다" 메시지 및 전체 개수 표시.

## 4. 구현 가이드 (Steps Hint)
1. **UI 컴포넌트**:
   - 메인 화면 상단에 올인 모드 토글 버튼 추가.
   - 토글 ON 시 "시작" 버튼 표시.
2. **시작 로직**:
   - `ScheduleRepository.getSchedules(for: today)` 호출하여 오늘 스케줄 목록 조회.
   - 모든 스케줄의 `isCompleted = false`로 초기화 (이미 완료된 것은 유지).
   - `DailyRecord` 생성 또는 업데이트: `allInModeUsed = true`, `status = "in_progress"`.
3. **차단 활성화**:
   - `DeviceActivityCenter`를 사용하여 모니터링 시작.
   - 종료 시간 없이 시작 (모든 스케줄 완료 시까지 유지).
   - `ManagedSettingsStore`에 차단 앱 목록 설정.
4. **상태 관리**:
   - 올인 모드 활성화 상태를 UserDefaults에 저장 (`isAllInModeActive = true`).

## 5. 예외 처리
- 오늘 스케줄이 없을 경우 "오늘 스케줄이 없습니다" 메시지 표시 및 시작 불가.

---

```yaml
task_id: "REQ-FUNC-010"
title: "올인 모드 시작 기능 구현"
summary: >
  사용자가 하루 전체 스케줄을 완료할 때까지 앱 차단을 유지하는 올인 모드를
  시작할 수 있는 기능을 구현한다. 이는 올인 모드의 기반이 되는 Task이다.
type: "functional"
epic: "EPIC_2_FOCUS_MODE"
req_ids: ["REQ-FUNC-010"]
component: ["mobile.ios.ui", "mobile.ios.viewmodel"]

context:
  srs_section: "4.1 기능 요구사항 Story 3"
  acceptance_criteria: >
    Given 사용자가 올인 모드를 ON하고 "시작"을 탭할 때
    When 앱 차단이 활성화되면
    Then "모든 일정 완료 시까지 차단됩니다" 메시지와 전체 개수 표시

inputs:
  description: "사용자의 올인 모드 시작 액션"
  preloaded_state:
    - "오늘 날짜에 스케줄이 하나 이상 존재해야 한다."
    - "Screen Time 권한이 승인되어 있어야 한다."

outputs:
  description: "올인 모드 활성화 및 차단 시작"
  success_criteria:
    - "올인 모드 시작 시 앱 차단이 활성화되어야 한다."
    - "전체 스케줄 개수와 완료 개수(0/n)가 표시되어야 한다."
    - "모든 스케줄 완료 전까지 차단이 유지되어야 한다."

preconditions:
  - "REQ-FUNC-001이 완료되어 Schedule 엔티티와 Repository가 존재해야 한다."
  - "REQ-FUNC-006이 완료되어 차단 시작 로직이 존재해야 한다."

postconditions:
  - "올인 모드가 활성화된 상태로 저장된다."
  - "DailyRecord에 올인 모드 사용 기록이 저장된다."
  - "앱 차단이 시작된다."

exceptions:
  - "오늘 스케줄이 없을 경우 시작 불가 안내."

config:
  feature_flags: []

tests:
  unit:
    - "올인 모드 시작 로직 테스트"
    - "스케줄 조회 및 초기화 테스트"
  manual:
    - "올인 모드 시작 후 차단이 정상 작동하는지 확인."

dependencies: ["REQ-FUNC-001", "REQ-FUNC-006"]
parallelizable: false
estimated_effort: "M"
priority: "Must"
agent_profile: ["mobile_dev"]
required_tools:
  languages: ["Swift"]
  frameworks: ["SwiftUI", "DeviceActivity"]
```

