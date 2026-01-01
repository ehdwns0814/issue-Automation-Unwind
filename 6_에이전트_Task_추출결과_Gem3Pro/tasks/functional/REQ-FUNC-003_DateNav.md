# REQ-FUNC-003: 7일 날짜 탭 내비게이션 구현

## 1. 개요
사용자가 스케줄 홈 화면에서 7일간의 날짜를 좌우로 스와이프하거나 탭하여 선택할 수 있는 날짜 내비게이션 기능을 구현합니다.

## 2. 관련 요구사항
- **REQ-FUNC-003**: 시스템은 7일간의 날짜 탭 내비게이션을 제공해야 함

## 3. 기능 범위
- **날짜 스크롤 뷰**: 가로 스크롤 가능한 날짜 탭 UI (오늘 기준 ±3일, 총 7일).
- **선택 상태 표시**: 현재 선택된 날짜를 시각적으로 강조.
- **스케줄 필터링**: 선택된 날짜에 해당하는 스케줄만 목록에 표시.

## 4. 구현 가이드 (Steps Hint)
1. **DateScroller 컴포넌트**:
   - `ScrollView` + `HStack`을 사용하여 가로 스크롤 가능한 날짜 뷰 구현.
   - 각 날짜를 `Button`으로 만들어 탭 가능하게 함.
   - 선택된 날짜는 배경색/테두리로 강조.
2. **날짜 계산 로직**:
   - 오늘 날짜를 기준으로 -3일부터 +3일까지 총 7일 배열 생성.
   - 날짜 포맷팅 (예: "월 12/29").
3. **필터링 로직**:
   - `ScheduleRepository`에 `getSchedules(for date: String)` 메서드 추가.
   - 선택된 날짜가 변경될 때마다 해당 날짜의 스케줄만 조회하여 목록 업데이트.
4. **애니메이션**:
   - 날짜 변경 시 스케줄 목록이 부드럽게 전환되도록 애니메이션 적용.

## 5. 예외 처리
- 선택된 날짜에 스케줄이 없을 경우 "이 날짜에는 스케줄이 없습니다" 메시지 표시.

---

```yaml
task_id: "REQ-FUNC-003"
title: "7일 날짜 탭 내비게이션 및 필터링 구현"
summary: >
  스케줄 홈 화면에서 날짜를 좌우로 스와이프하거나 탭하여 선택하고,
  선택된 날짜의 스케줄만 필터링하여 표시하는 기능을 구현한다.
type: "functional"
epic: "EPIC_1_SCHEDULE"
req_ids: ["REQ-FUNC-003"]
component: ["mobile.ios.ui", "mobile.ios.repository"]

context:
  srs_section: "4.1 기능 요구사항 Story 1"
  acceptance_criteria: >
    Given 사용자가 스케줄 홈 화면에 있을 때
    When 날짜 탭을 좌우로 스와이프하면
    Then 선택된 날짜의 스케줄 목록으로 업데이트됨

inputs:
  description: "사용자의 날짜 선택 액션 (탭 또는 스와이프)"
  state:
    - "현재 선택된 날짜 (기본값: 오늘)"

outputs:
  description: "선택된 날짜의 스케줄 목록"
  success_criteria:
    - "날짜 탭을 좌우로 스와이프할 수 있어야 한다."
    - "날짜를 탭하면 선택 상태가 변경되어야 한다."
    - "선택된 날짜의 스케줄만 목록에 표시되어야 한다."

preconditions:
  - "REQ-FUNC-001이 완료되어 Schedule 엔티티와 Repository가 존재해야 한다."

postconditions:
  - "ScheduleRepository에 날짜별 조회 메서드가 추가되어 있다."
  - "DateScroller 컴포넌트가 메인 화면에 통합되어 있다."

exceptions:
  - "선택된 날짜에 스케줄이 없을 경우 Empty State 표시."

config:
  feature_flags: []

tests:
  unit:
    - "날짜 범위 계산 로직 테스트"
    - "날짜별 필터링 로직 테스트"
  manual:
    - "날짜 탭을 변경하며 스케줄 목록이 정상 업데이트되는지 확인."

dependencies: ["REQ-FUNC-001"]
parallelizable: true
estimated_effort: "S"
priority: "Must"
agent_profile: ["mobile_dev"]
required_tools:
  languages: ["Swift"]
  frameworks: ["SwiftUI"]
```

