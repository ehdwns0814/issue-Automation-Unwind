# REQ-FUNC-019: 스트릭 표시 기능 구현

## 1. 개요
메인 화면 상단에 현재 연속 달성 일수(스트릭)를 표시하는 기능을 구현합니다.

## 2. 관련 요구사항
- **REQ-FUNC-019**: 시스템은 메인 화면에 현재 스트릭을 표시해야 함

## 3. 기능 범위
- **스트릭 계산**: `DailyRecord`를 순회하여 최근 연속 성공 일수 계산.
- **스트릭 UI**: 불꽃 아이콘과 숫자를 포함한 배지 형태의 뷰.
- **메인 화면 통합**: 스케줄 목록 화면 상단에 스트릭 배지 표시.

## 4. 구현 가이드 (Steps Hint)
1. **스트릭 계산 로직**:
   - `StatsService` 클래스 생성.
   - `calculateStreak()` 메서드 구현: `DailyRecord`를 날짜 역순으로 순회하며 연속 성공일 계산.
   - 실패(`status == "failure"`) 또는 계획 없음(`status == "noplan"`)이 나오면 스트릭 중단.
2. **스트릭 UI 컴포넌트**:
   - `StreakView` 컴포넌트 생성: 불꽃 이모지(🔥)와 숫자 표시.
   - 예: "🔥 7일 연속 달성".
3. **메인 화면 통합**:
   - 스케줄 목록 화면 상단에 `StreakView` 배치.
   - 앱 실행 시 또는 날짜 변경 시 스트릭 재계산.

## 5. 예외 처리
- 스트릭이 0일 경우 "오늘부터 시작하세요" 메시지 표시.

---

```yaml
task_id: "REQ-FUNC-019"
title: "스트릭 계산 및 표시 기능 구현"
summary: >
  DailyRecord 데이터를 분석하여 현재 연속 달성 일수(스트릭)를 계산하고,
  메인 화면 상단에 배지 형태로 표시하는 기능을 구현한다.
type: "functional"
epic: "EPIC_7_STATS"
req_ids: ["REQ-FUNC-019"]
component: ["mobile.ios.ui", "mobile.ios.logic"]

context:
  srs_section: "4.1 기능 요구사항 Story 6"
  acceptance_criteria: >
    Given 사용자가 앱을 열 때
    When 메인 화면이 로드되면
    Then 상단에 현재 스트릭 (예: "🔥 7일 연속 달성") 표시

inputs:
  description: "DailyRecord 데이터 목록"
  preloaded_state:
    - "DailyRecord 데이터가 UserDefaults에 저장되어 있어야 한다."

outputs:
  description: "계산된 스트릭 값 및 UI 표시"
  success_criteria:
    - "메인 화면 상단에 스트릭이 표시되어야 한다."
    - "스트릭 숫자가 정확하게 계산되어야 한다."
    - "연속 달성이 끊어지면 스트릭이 0으로 리셋되어야 한다."

preconditions:
  - "REQ-FUNC-001이 완료되어 Schedule 엔티티가 존재해야 한다."
  - "DailyRecord 데이터가 생성되고 있어야 한다 (올인 모드 또는 개별 실행 완료 시)."

postconditions:
  - "StatsService에 calculateStreak() 메서드가 구현되어 있다."
  - "메인 화면에 StreakView가 표시된다."

exceptions:
  - "스트릭이 0일 경우 '오늘부터 시작하세요' 메시지 표시."

config:
  feature_flags: []

tests:
  unit:
    - "스트릭 계산 로직 테스트 (연속 성공일 계산)"
    - "실패일 포함 시 스트릭 중단 테스트"
  manual:
    - "메인 화면에서 스트릭이 정상 표시되는지 확인."

dependencies: ["REQ-FUNC-001"]
parallelizable: true
estimated_effort: "S"
priority: "Should"
agent_profile: ["mobile_dev"]
required_tools:
  languages: ["Swift"]
  frameworks: ["SwiftUI"]
```

