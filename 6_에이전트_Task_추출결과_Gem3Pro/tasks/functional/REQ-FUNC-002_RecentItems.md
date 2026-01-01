# REQ-FUNC-002: 최근 항목 빠른 추가 기능 구현

## 1. 개요
사용자가 최근 7일 내에 사용한 스케줄을 빠르게 재사용할 수 있는 "최근 항목" 기능을 구현합니다.

## 2. 관련 요구사항
- **REQ-FUNC-002**: 시스템은 최근 사용한 스케줄을 빠르게 추가할 수 있는 기능을 제공해야 함

## 3. 기능 범위
- **최근 항목 조회**: UserDefaults에서 최근 7일 내 생성/사용된 스케줄 목록을 조회하는 로직.
- **UI 컴포넌트**: 스케줄 생성 모달 내 "최근 항목" 탭 및 리스트 표시.
- **빠른 선택**: 최근 항목을 탭하면 해당 스케줄의 이름과 시간이 자동으로 채워지는 기능.

## 4. 구현 가이드 (Steps Hint)
1. **Repository 확장**:
   - `ScheduleRepository`에 `getRecentSchedules(days: Int = 7)` 메서드 추가.
   - 날짜 범위를 계산하여 해당 기간의 모든 스케줄을 조회.
   - 중복 제거 (동일한 이름+시간 조합은 하나만 표시).
2. **UI 구현**:
   - 스케줄 생성 모달에 "최근 항목" 탭 추가 (SegmentedControl 또는 TabView 사용).
   - 최근 항목 리스트를 `List` 또는 `LazyVStack`으로 표시.
3. **선택 처리**:
   - 최근 항목 탭 시 해당 스케줄의 `name`과 `duration`을 폼에 자동 입력.
   - 날짜는 오늘 날짜로 기본 설정.

## 5. 예외 처리
- 최근 항목이 없을 경우 "최근 항목이 없습니다" 메시지 표시.

---

```yaml
task_id: "REQ-FUNC-002"
title: "최근 항목 빠른 추가 기능 구현"
summary: >
  최근 7일 내 사용한 스케줄을 조회하여 빠르게 재사용할 수 있는
  "최근 항목" 탭 및 선택 기능을 구현한다.
type: "functional"
epic: "EPIC_1_SCHEDULE"
req_ids: ["REQ-FUNC-002"]
component: ["mobile.ios.ui", "mobile.ios.repository"]

context:
  srs_section: "4.1 기능 요구사항 Story 1"
  acceptance_criteria: >
    Given 사용자가 스케줄 생성 모달을 열 때
    When "최근 항목" 탭을 선택하면
    Then 최근 7일 내 사용한 스케줄 목록이 표시되어 선택 가능함

inputs:
  description: "사용자의 최근 항목 조회 요청"
  preloaded_state:
    - "UserDefaults에 최근 7일 내 스케줄 데이터가 저장되어 있어야 한다."

outputs:
  description: "최근 항목 리스트 및 선택된 스케줄 정보"
  success_criteria:
    - "최근 7일 내 스케줄이 이름과 시간과 함께 리스트로 표시되어야 한다."
    - "항목을 탭하면 생성 폼에 자동으로 채워져야 한다."

preconditions:
  - "REQ-FUNC-001이 완료되어 Schedule 엔티티와 Repository가 존재해야 한다."

postconditions:
  - "ScheduleRepository에 getRecentSchedules() 메서드가 추가되어 있다."
  - "스케줄 생성 모달에 최근 항목 탭이 표시된다."

exceptions:
  - "최근 항목이 없을 경우 Empty State 표시."

config:
  feature_flags: []

tests:
  unit:
    - "getRecentSchedules() 메서드의 날짜 범위 필터링 테스트"
    - "중복 제거 로직 테스트"
  manual:
    - "최근 항목 탭에서 리스트가 정상 표시되는지 확인."

dependencies: ["REQ-FUNC-001"]
parallelizable: true
estimated_effort: "S"
priority: "Should"
agent_profile: ["mobile_dev"]
required_tools:
  languages: ["Swift"]
  frameworks: ["SwiftUI"]
```

