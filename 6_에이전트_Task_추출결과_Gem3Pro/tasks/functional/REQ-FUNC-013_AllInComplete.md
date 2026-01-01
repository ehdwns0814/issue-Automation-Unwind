# REQ-FUNC-013: 올인 모드 전체 완료 감지 및 해제 구현

## 1. 개요
올인 모드에서 모든 스케줄이 완료되었을 때를 감지하고, 차단을 해제하며 축하 메시지를 표시하는 기능을 구현합니다.

## 2. 관련 요구사항
- **REQ-FUNC-013**: 시스템은 올인 모드의 모든 스케줄 완료 시 차단을 해제해야 함

## 3. 기능 범위
- **완료 감지**: 마지막 스케줄 완료 시 전체 완료 여부 확인 (n == m).
- **차단 해제**: `ManagedSettingsStore.clearAllSettings()` 호출.
- **축하 메시지**: "오늘 목표 달성! 이제 마음껏 즐기세요 🎉" 메시지 표시.
- **상태 저장**: `DailyRecord`를 성공 상태로 업데이트.

## 4. 구현 가이드 (Steps Hint)
1. **완료 감지 로직**:
   - REQ-FUNC-011의 완료 체크 후, `getCompletedCount(for: today)`와 `getTotalCount(for: today)` 비교.
   - `completedCount == totalCount`일 때 완료 이벤트 트리거.
2. **차단 해제**:
   - `ManagedSettingsStore.shared.clearAllSettings()` 호출.
   - `DeviceActivityCenter` 모니터링 중지.
3. **상태 업데이트**:
   - `DailyRecord`의 `status = "success"`, `completedSchedules = totalSchedules` 설정.
   - 올인 모드 활성화 상태 제거 (`isAllInModeActive = false`).
4. **UI 피드백**:
   - 축하 메시지 Alert 또는 Toast 표시.
   - 메인 화면으로 자동 전환.

## 5. 예외 처리
- 완료 처리 중 네트워크 오류 발생 시 로컬 저장은 완료하고 동기화는 재시도 큐에 추가.

---

```yaml
task_id: "REQ-FUNC-013"
title: "올인 모드 전체 완료 감지 및 해제 구현"
summary: >
  올인 모드에서 모든 스케줄이 완료되었을 때를 감지하고,
  차단을 해제하며 축하 메시지를 표시하는 기능을 구현한다.
type: "functional"
epic: "EPIC_2_FOCUS_MODE"
req_ids: ["REQ-FUNC-013"]
component: ["mobile.ios.ui", "mobile.ios.repository"]

context:
  srs_section: "4.1 기능 요구사항 Story 3"
  acceptance_criteria: >
    Given 올인 모드에서 n/m 스케줄 중일 때
    When 마지막 스케줄이 완료되면 (n=m)
    Then 축하 메시지, 차단 비활성화, 올인 모드 종료

inputs:
  description: "마지막 스케줄 완료 이벤트"
  state:
    - "완료된 스케줄 개수 = 전체 스케줄 개수"

outputs:
  description: "완료 처리 및 차단 해제"
  success_criteria:
    - "모든 스케줄 완료 시 자동으로 차단이 해제되어야 한다."
    - "축하 메시지가 표시되어야 한다."
    - "DailyRecord가 성공 상태로 저장되어야 한다."

preconditions:
  - "REQ-FUNC-011이 완료되어 완료 체크 로직이 존재해야 한다."

postconditions:
  - "올인 모드가 종료되고 차단이 해제된다."
  - "DailyRecord가 성공 상태로 업데이트된다."

exceptions:
  - "완료 처리 중 네트워크 오류 시 로컬 저장 완료 후 동기화 재시도."

config:
  feature_flags: []

tests:
  unit:
    - "전체 완료 감지 로직 테스트"
  manual:
    - "올인 모드에서 모든 스케줄 완료 시 자동 해제 확인."

dependencies: ["REQ-FUNC-011"]
parallelizable: false
estimated_effort: "M"
priority: "Must"
agent_profile: ["mobile_dev"]
required_tools:
  languages: ["Swift"]
  frameworks: ["SwiftUI", "ManagedSettings"]
```

