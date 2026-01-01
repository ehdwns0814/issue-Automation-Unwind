# REQ-FUNC-004: 스케줄 수정 기능 구현

## 1. 개요
사용자가 기존 스케줄을 길게 누르거나 컨텍스트 메뉴를 통해 수정할 수 있는 기능을 구현합니다.

## 2. 관련 요구사항
- **REQ-FUNC-004**: 시스템은 길게 누르기를 통한 스케줄 수정 기능을 제공해야 함

## 3. 기능 범위
- **컨텍스트 메뉴**: 스케줄 아이템 길게 누르기 시 수정/삭제 옵션 표시.
- **수정 모달**: 수정 옵션 선택 시 기존 스케줄 정보가 채워진 편집 폼 표시.
- **Repository 업데이트**: 수정된 내용을 UserDefaults에 반영하고 `syncStatus = "pending"` 설정.

## 4. 구현 가이드 (Steps Hint)
1. **컨텍스트 메뉴**:
   - SwiftUI의 `.contextMenu` 모디파이어를 사용하여 "수정", "삭제" 옵션 제공.
   - 또는 `onLongPressGesture`로 커스텀 메뉴 표시.
2. **수정 모달**:
   - 스케줄 생성 모달과 유사한 구조이지만, 기존 값으로 폼이 채워진 상태로 시작.
   - `@State` 변수에 기존 스케줄 정보 바인딩.
3. **Repository 확장**:
   - `ScheduleRepository`에 `update(schedule: Schedule)` 메서드 추가.
   - ID로 기존 스케줄을 찾아 내용 업데이트, `lastModified` 갱신, `syncStatus = "pending"` 설정.
4. **UI 업데이트**:
   - 수정 완료 시 목록 자동 새로고침.

## 5. 예외 처리
- 존재하지 않는 ID로 수정 시도 시 에러 처리.
- 수정 중 다른 프로세스에서 삭제된 경우 충돌 처리.

---

```yaml
task_id: "REQ-FUNC-004"
title: "스케줄 수정 기능 구현"
summary: >
  사용자가 스케줄 아이템을 길게 눌러 수정 옵션을 선택하고,
  기존 스케줄 정보를 편집하여 저장하는 기능을 구현한다.
type: "functional"
epic: "EPIC_1_SCHEDULE"
req_ids: ["REQ-FUNC-004"]
component: ["mobile.ios.ui", "mobile.ios.repository"]

context:
  srs_section: "4.1 기능 요구사항 Story 1"
  acceptance_criteria: >
    Given 사용자가 스케줄 아이템을 길게 누를 때
    When 수정 옵션을 선택하면
    Then 수정 모달이 나타나고 이름/시간 변경 후 저장 시 즉시 반영됨

inputs:
  description: "사용자의 수정 액션 및 수정된 스케줄 데이터"
  fields:
    - name: "scheduleId"
      type: "UUID"
      required: true
    - name: "name"
      type: "String"
    - name: "duration"
      type: "Int"

outputs:
  description: "수정된 Schedule 객체 및 영구 저장 완료"
  success_criteria:
    - "길게 누르면 컨텍스트 메뉴가 표시되어야 한다."
    - "수정 모달에 기존 정보가 채워져 있어야 한다."
    - "저장 시 변경사항이 즉시 목록에 반영되어야 한다."

preconditions:
  - "REQ-FUNC-001이 완료되어 Schedule 엔티티와 Repository가 존재해야 한다."

postconditions:
  - "ScheduleRepository에 update() 메서드가 추가되어 있다."
  - "수정된 스케줄의 syncStatus가 pending으로 설정된다."
  - "수정된 스케줄의 lastModified가 갱신된다."

exceptions:
  - "존재하지 않는 ID로 수정 시도 시 에러 처리."
  - "수정 중 삭제된 경우 충돌 처리."

config:
  feature_flags: []

tests:
  unit:
    - "ScheduleRepository.update() 메서드 단위 테스트"
    - "수정 시 lastModified 갱신 테스트"
  integration:
    - "수정 플로우 전체 검증"

dependencies: ["REQ-FUNC-001"]
parallelizable: true
estimated_effort: "M"
priority: "Must"
agent_profile: ["mobile_dev"]
required_tools:
  languages: ["Swift"]
  frameworks: ["SwiftUI"]
```

