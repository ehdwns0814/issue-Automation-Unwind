# REQ-FUNC-011: 올인 모드 중 개별 스케줄 완료 체크 기능 구현

## 1. 개요
올인 모드가 활성화된 상태에서 사용자가 개별 스케줄을 완료 체크할 수 있는 기능을 구현합니다. 완료 시 카운트가 증가하고, 모든 스케줄 완료 시 차단이 해제됩니다.

## 2. 관련 요구사항
- **REQ-FUNC-011**: 시스템은 올인 모드 중 개별 스케줄 완료 체크 기능을 제공해야 함

## 3. 기능 범위
- **완료 체크 UI**: 스케줄 상세 화면 또는 리스트에서 체크박스/완료 버튼 제공.
- **완료 처리**: 스케줄의 `isCompleted = true` 설정 및 `completedAt` 기록.
- **카운트 업데이트**: 완료된 스케줄 개수 증가 (n+1/m).
- **전체 완료 감지**: 모든 스케줄 완료 시 REQ-FUNC-013으로 전달.

## 4. 구현 가이드 (Steps Hint)
1. **완료 체크 UI**:
   - 스케줄 리스트 아이템에 체크박스 추가 또는 상세 화면에 "완료" 버튼 추가.
   - 체크 상태는 `isCompleted` 필드와 바인딩.
2. **완료 처리 로직**:
   - `ScheduleRepository.markAsCompleted(scheduleId: UUID)` 호출.
   - `isCompleted = true`, `completedAt = Date().iso8601String` 설정.
3. **카운트 계산**:
   - `getCompletedCount(for: date)` 메서드로 완료 개수 조회.
   - 전체 개수와 비교하여 진행률 계산 (n/m).
4. **UI 업데이트**:
   - 완료 카운트를 메인 화면 상단에 표시 (예: "완료: 3/5").
   - 완료된 스케줄은 시각적으로 구분 (예: 취소선 또는 회색 처리).

## 5. 예외 처리
- 이미 완료된 스케줄을 다시 체크 해제하는 경우 처리 (선택 사항).

---

```yaml
task_id: "REQ-FUNC-011"
title: "올인 모드 중 개별 스케줄 완료 체크 기능 구현"
summary: >
  올인 모드가 활성화된 상태에서 사용자가 개별 스케줄을 완료 체크할 수 있으며,
  완료 시 카운트가 증가하고 진행 상황이 업데이트되는 기능을 구현한다.
type: "functional"
epic: "EPIC_2_FOCUS_MODE"
req_ids: ["REQ-FUNC-011"]
component: ["mobile.ios.ui", "mobile.ios.repository"]

context:
  srs_section: "4.1 기능 요구사항 Story 3"
  acceptance_criteria: >
    Given 올인 모드가 활성화되었을 때
    When 사용자가 스케줄을 탭하고 상세에서 "완료" 체크하면
    Then 완료 상태 저장, 카운트 증가 (n+1/m), 목록 복귀

inputs:
  description: "사용자의 완료 체크 액션"
  fields:
    - name: "scheduleId"
      type: "UUID"
      required: true

outputs:
  description: "완료 처리 및 카운트 업데이트"
  success_criteria:
    - "완료 체크 시 스케줄이 완료 상태로 저장되어야 한다."
    - "완료 카운트가 증가하여 표시되어야 한다 (예: 1/5 → 2/5)."
    - "완료된 스케줄이 시각적으로 구분되어야 한다."

preconditions:
  - "REQ-FUNC-010이 완료되어 올인 모드가 시작되어 있어야 한다."

postconditions:
  - "스케줄의 isCompleted가 true로 설정된다."
  - "완료 카운트가 업데이트된다."
  - "모든 스케줄 완료 시 REQ-FUNC-013이 트리거된다."

exceptions:
  - "이미 완료된 스케줄 재체크 처리 (선택 사항)."

config:
  feature_flags: []

tests:
  unit:
    - "완료 체크 로직 테스트"
    - "카운트 계산 로직 테스트"
  manual:
    - "올인 모드에서 스케줄을 완료 체크하며 카운트 증가 확인."

dependencies: ["REQ-FUNC-010"]
parallelizable: false
estimated_effort: "M"
priority: "Must"
agent_profile: ["mobile_dev"]
required_tools:
  languages: ["Swift"]
  frameworks: ["SwiftUI"]
```

