# REQ-FUNC-014: 올인 모드 중단 및 실패 기록 구현

## 1. 개요
사용자가 올인 모드를 중도에 포기할 수 있는 기능을 구현합니다. 경고 메시지를 표시하고, 중단 시 해당 일자를 실패로 기록합니다.

## 2. 관련 요구사항
- **REQ-FUNC-014**: 시스템은 올인 모드 중단 시 경고 및 실패 기록 기능을 제공해야 함

## 3. 기능 범위
- **중단 버튼**: 올인 모드 화면에 "정지" 또는 "포기" 버튼 제공.
- **경고 팝업**: "올인 모드를 중단하면 오늘은 실패로 기록됩니다" 경고 메시지 표시.
- **차단 해제**: `ManagedSettingsStore.clearAllSettings()` 호출.
- **실패 기록**: `DailyRecord`를 실패 상태로 업데이트.

## 4. 구현 가이드 (Steps Hint)
1. **중단 버튼 UI**:
   - 올인 모드 화면 상단 또는 하단에 "정지" 버튼 추가.
   - 버튼 탭 시 경고 Alert 표시.
2. **경고 다이얼로그**:
   - SwiftUI의 `.alert` 모디파이어 사용.
   - "취소"와 "중단" 버튼 제공.
   - 경고 문구: "올인 모드를 중단하면 오늘은 실패로 기록됩니다. 정말 중단하시겠습니까?"
3. **중단 로직**:
   - `ManagedSettingsStore.shared.clearAllSettings()` 호출하여 차단 해제.
   - `DeviceActivityCenter` 모니터링 중지.
   - 올인 모드 활성화 상태 제거 (`isAllInModeActive = false`).
4. **실패 기록**:
   - `DailyRecord`의 `status = "failure"` 설정.
   - `completedSchedules`는 현재 완료된 개수 유지.

## 5. 예외 처리
- 중단 처리 중 네트워크 오류 발생 시 로컬 저장은 완료하고 동기화는 재시도 큐에 추가.

---

```yaml
task_id: "REQ-FUNC-014"
title: "올인 모드 중단 및 실패 기록 구현"
summary: >
  사용자가 올인 모드를 중도에 포기할 수 있으며, 경고 메시지를 표시하고
  중단 시 해당 일자를 실패로 기록하는 기능을 구현한다.
type: "functional"
epic: "EPIC_2_FOCUS_MODE"
req_ids: ["REQ-FUNC-014"]
component: ["mobile.ios.ui", "mobile.ios.repository"]

context:
  srs_section: "4.1 기능 요구사항 Story 3"
  acceptance_criteria: >
    Given 올인 모드가 활성화되었을 때
    When 사용자가 "정지"를 탭하고 경고 확인하면
    Then 해당 일자 실패 표시, 차단 비활성화, 올인 모드 종료

inputs:
  description: "사용자의 올인 모드 중단 액션"
  state:
    - "올인 모드 활성화 상태"

outputs:
  description: "중단 처리 및 실패 기록"
  success_criteria:
    - "중단 버튼 탭 시 경고 팝업이 표시되어야 한다."
    - "확인 시 차단이 즉시 해제되어야 한다."
    - "DailyRecord가 실패 상태로 저장되어야 한다."

preconditions:
  - "REQ-FUNC-010이 완료되어 올인 모드가 시작되어 있어야 한다."

postconditions:
  - "올인 모드가 종료되고 차단이 해제된다."
  - "DailyRecord가 실패 상태로 업데이트된다."

exceptions:
  - "중단 처리 중 네트워크 오류 시 로컬 저장 완료 후 동기화 재시도."

config:
  feature_flags: []

tests:
  unit:
    - "중단 로직 테스트"
    - "실패 기록 로직 테스트"
  manual:
    - "올인 모드 시작 후 중단 버튼을 눌러 실패 기록 확인."

dependencies: ["REQ-FUNC-010"]
parallelizable: false
estimated_effort: "M"
priority: "Must"
agent_profile: ["mobile_dev"]
required_tools:
  languages: ["Swift"]
  frameworks: ["SwiftUI", "ManagedSettings"]
```

