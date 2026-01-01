# REQ-FUNC-005: 스케줄 삭제 기능 구현

## 1. 개요
사용자가 스케줄을 삭제할 수 있는 기능을 구현합니다. 확인 절차를 거쳐 실수로 인한 삭제를 방지합니다.

## 2. 관련 요구사항
- **REQ-FUNC-005**: 시스템은 확인 절차를 거쳐 스케줄을 삭제할 수 있어야 함

## 3. 기능 범위
- **삭제 옵션**: 컨텍스트 메뉴에서 "삭제" 옵션 제공.
- **확인 팝업**: 삭제 시 "정말 삭제하시겠습니까?" 확인 Alert 표시.
- **Repository 삭제**: UserDefaults에서 해당 스케줄 제거 또는 Soft Delete 처리.

## 4. 구현 가이드 (Steps Hint)
1. **삭제 옵션**:
   - 컨텍스트 메뉴에 "삭제" 항목 추가 (REQ-FUNC-004와 동일한 메뉴 구조).
2. **확인 팝업**:
   - SwiftUI의 `.alert` 모디파이어를 사용하여 확인 다이얼로그 표시.
   - "취소"와 "삭제" 버튼 제공.
3. **Repository 확장**:
   - `ScheduleRepository`에 `delete(scheduleId: UUID)` 메서드 추가.
   - SRS에 따르면 로컬 삭제 후 서버 전송이므로 Soft Delete 권장 (`deletedAt` 필드 설정).
   - 또는 로컬 전용이면 완전 삭제 (배열에서 제거).
4. **동기화 상태**:
   - 삭제된 스케줄의 `syncStatus = "pending"` 설정하여 서버 동기화 대기열에 추가.

## 5. 예외 처리
- 존재하지 않는 ID로 삭제 시도 시 에러 처리.
- 삭제 중 다른 프로세스에서 수정된 경우 충돌 처리.

---

```yaml
task_id: "REQ-FUNC-005"
title: "스케줄 삭제 기능 구현"
summary: >
  사용자가 스케줄을 삭제할 수 있으며, 확인 절차를 거쳐
  실수로 인한 삭제를 방지하는 기능을 구현한다.
type: "functional"
epic: "EPIC_1_SCHEDULE"
req_ids: ["REQ-FUNC-005"]
component: ["mobile.ios.ui", "mobile.ios.repository"]

context:
  srs_section: "4.1 기능 요구사항 Story 1"
  acceptance_criteria: >
    Given 사용자가 스케줄 아이템을 길게 누를 때
    When 삭제 옵션을 선택하고 확인 팝업에서 확인하면
    Then 스케줄이 목록과 로컬/서버에서 제거됨

inputs:
  description: "사용자의 삭제 액션"
  fields:
    - name: "scheduleId"
      type: "UUID"
      required: true

outputs:
  description: "삭제 완료 및 목록 업데이트"
  success_criteria:
    - "삭제 옵션 선택 시 확인 팝업이 표시되어야 한다."
    - "확인 시 스케줄이 목록에서 즉시 제거되어야 한다."
    - "앱 재시작 후에도 삭제된 스케줄이 나타나지 않아야 한다."

preconditions:
  - "REQ-FUNC-001이 완료되어 Schedule 엔티티와 Repository가 존재해야 한다."

postconditions:
  - "ScheduleRepository에 delete() 메서드가 추가되어 있다."
  - "삭제된 스케줄이 UserDefaults에서 제거되거나 Soft Delete 처리된다."
  - "삭제된 스케줄의 syncStatus가 pending으로 설정되어 서버 동기화 대기열에 추가된다."

exceptions:
  - "존재하지 않는 ID로 삭제 시도 시 에러 처리."
  - "삭제 중 수정된 경우 충돌 처리."

config:
  feature_flags: []

tests:
  unit:
    - "ScheduleRepository.delete() 메서드 단위 테스트"
    - "Soft Delete vs Hard Delete 정책 테스트"
  integration:
    - "삭제 플로우 전체 검증"

dependencies: ["REQ-FUNC-001"]
parallelizable: true
estimated_effort: "M"
priority: "Must"
agent_profile: ["mobile_dev"]
required_tools:
  languages: ["Swift"]
  frameworks: ["SwiftUI"]
```

