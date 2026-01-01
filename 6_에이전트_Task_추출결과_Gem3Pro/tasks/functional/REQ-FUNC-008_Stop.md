# REQ-FUNC-008: 개별 스케줄 수동 정지 기능 구현

## 1. 개요
사용자가 실행 중인 개별 스케줄 타이머를 중도에 정지할 수 있는 기능을 구현합니다. 확인 절차를 거쳐 실수로 인한 중단을 방지합니다.

## 2. 관련 요구사항
- **REQ-FUNC-008**: 시스템은 개별 스케줄의 수동 정지 기능을 제공해야 함

## 3. 기능 범위
- **정지 버튼**: 타이머 화면에 "정지" 버튼 표시.
- **확인 팝업**: 정지 시 "정말 그만두시겠습니까?" 확인 Alert 표시.
- **차단 해제**: `ManagedSettingsStore.clearAllSettings()` 호출하여 앱 차단 비활성화.
- **상태 저장**: 미완료 상태로 기록하고 통계에 반영.

## 4. 구현 가이드 (Steps Hint)
1. **정지 버튼 UI**:
   - 타이머 화면에 "정지" 버튼 추가.
   - 버튼 탭 시 확인 Alert 표시.
2. **확인 다이얼로그**:
   - SwiftUI의 `.alert` 모디파이어 사용.
   - "취소"와 "정지" 버튼 제공.
3. **정지 로직**:
   - 타이머 취소 (`Timer.invalidate()`).
   - `ManagedSettingsStore.shared.clearAllSettings()` 호출하여 차단 해제.
   - 실행 중인 스케줄 상태를 UserDefaults에서 제거.
4. **미완료 기록**:
   - 스케줄의 `isCompleted = false` 유지.
   - 통계 전송을 위해 `DailyRecord`에 실패 기록 (REQ-FUNC-029에서 처리).

## 5. 예외 처리
- 정지 중 앱이 백그라운드로 전환될 경우 상태 정리 완료 보장.

---

```yaml
task_id: "REQ-FUNC-008"
title: "개별 스케줄 수동 정지 기능 구현"
summary: >
  사용자가 실행 중인 개별 스케줄 타이머를 중도에 정지할 수 있으며,
  확인 절차를 거쳐 실수로 인한 중단을 방지하는 기능을 구현한다.
type: "functional"
epic: "EPIC_2_FOCUS_MODE"
req_ids: ["REQ-FUNC-008"]
component: ["mobile.ios.ui", "mobile.ios.screentime"]

context:
  srs_section: "4.1 기능 요구사항 Story 2"
  acceptance_criteria: >
    Given 개별 스케줄 타이머가 실행 중일 때
    When 사용자가 "정지"를 탭하고 확인하면
    Then 타이머 취소, 차단 비활성화, 미완료로 표시, 목록 복귀

inputs:
  description: "사용자의 정지 액션"
  state:
    - "실행 중인 타이머 및 스케줄 정보"

outputs:
  description: "정지 완료 및 상태 업데이트"
  success_criteria:
    - "정지 버튼 탭 시 확인 팝업이 표시되어야 한다."
    - "확인 시 타이머가 즉시 중지되어야 한다."
    - "앱 차단이 해제되어야 한다."
    - "스케줄이 미완료 상태로 기록되어야 한다."

preconditions:
  - "REQ-FUNC-006이 완료되어 타이머 실행 로직이 존재해야 한다."

postconditions:
  - "타이머가 중지되고 차단이 해제된다."
  - "스케줄이 미완료 상태로 저장된다."
  - "실행 중인 스케줄 정보가 UserDefaults에서 제거된다."

exceptions:
  - "정지 중 백그라운드 전환 시 상태 정리 완료 보장."

config:
  feature_flags: []

tests:
  unit:
    - "타이머 취소 로직 테스트"
  manual:
    - "타이머 실행 중 정지 버튼을 눌러 정상 중지되는지 확인."

dependencies: ["REQ-FUNC-006"]
parallelizable: false
estimated_effort: "S"
priority: "Must"
agent_profile: ["mobile_dev"]
required_tools:
  languages: ["Swift"]
  frameworks: ["SwiftUI", "ManagedSettings"]
```

