# REQ-FUNC-020: 주간/월간 통계 그래프 구현

## 1. 개요
사용자의 달성 기록을 시각화하는 주간/월간 통계 그래프를 구현합니다.

## 2. 관련 요구사항
- **REQ-FUNC-020**: 시스템은 주간/월간 통계를 그래프로 제공해야 함

## 3. 기능 범위
- **통계 탭**: 하단 탭 바의 "통계" 섹션 생성.
- **주간 그래프**: 최근 7일간의 달성률을 막대 그래프로 표시.
- **월간 그래프**: 이번 달의 주별 달성률을 막대 그래프로 표시.
- **요약 카드**: 총 집중 시간, 성공 횟수 등 요약 정보 표시.

## 4. 구현 가이드 (Steps Hint)
1. **통계 탭 UI**:
   - `StatsView` 컴포넌트 생성.
   - 하단 탭 바에 "통계" 탭 추가.
2. **데이터 조회**:
   - `StatsService`에 `getWeeklyStats()` 및 `getMonthlyStats()` 메서드 추가.
   - `DailyRecord` 데이터를 날짜별로 그룹화하여 달성률 계산.
3. **차트 구현**:
   - Swift Charts 프레임워크 사용 (`import Charts`).
   - `Chart { BarMark(...) }` 구문을 사용하여 막대 그래프 생성.
   - 달성률에 따른 색상 코딩 (예: 80% 이상 초록, 50% 미만 빨강).
4. **요약 카드**:
   - 총 집중 시간, 성공 횟수, 평균 달성률 등을 카드 형태로 표시.

## 5. 예외 처리
- 데이터가 없을 경우 Empty State 표시.

---

```yaml
task_id: "REQ-FUNC-020"
title: "주간/월간 통계 그래프 및 대시보드 구현"
summary: >
  DailyRecord 데이터를 분석하여 주간/월간 달성률을 계산하고,
  Swift Charts를 사용하여 시각적인 그래프로 표시하는 기능을 구현한다.
type: "functional"
epic: "EPIC_7_STATS"
req_ids: ["REQ-FUNC-020"]
component: ["mobile.ios.ui", "mobile.ios.charts"]

context:
  srs_section: "4.1 기능 요구사항 Story 6"
  acceptance_criteria: >
    Given 사용자가 통계 탭으로 이동할 때
    When 탭이 로드되면
    Then 주간/월간 달성률 그래프와 최근 7일 활동 표시

inputs:
  description: "DailyRecord 데이터 목록"
  preloaded_state:
    - "DailyRecord 데이터가 UserDefaults에 저장되어 있어야 한다."

outputs:
  description: "통계 그래프 및 요약 정보"
  success_criteria:
    - "통계 탭에서 막대 그래프가 정상 렌더링되어야 한다."
    - "주간/월간 데이터가 정확하게 표시되어야 한다."
    - "달성률에 따른 색상 코딩이 적용되어야 한다."

preconditions:
  - "REQ-FUNC-001이 완료되어 Schedule 엔티티가 존재해야 한다."
  - "DailyRecord 데이터가 생성되고 있어야 한다."

postconditions:
  - "StatsService에 주간/월간 통계 조회 메서드가 구현되어 있다."
  - "통계 탭에 차트가 표시된다."

exceptions:
  - "데이터가 없을 경우 Empty State 표시."

config:
  feature_flags: []

tests:
  unit:
    - "주간/월간 통계 계산 로직 테스트"
  manual:
    - "통계 탭 진입 확인."
    - "Mock 데이터를 변경했을 때 그래프 높이가 변하는지 확인."

dependencies: ["REQ-FUNC-001"]
parallelizable: true
estimated_effort: "M"
priority: "Should"
agent_profile: ["mobile_dev"]
required_tools:
  languages: ["Swift"]
  frameworks: ["SwiftUI", "Swift Charts"]
```

