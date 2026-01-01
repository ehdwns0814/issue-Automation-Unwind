# EPIC0-FE-002: 집중 모드 실행 및 Shield 화면 시뮬레이션

## 1. 개요
개별 스케줄 실행 및 '올인 모드' 실행 시의 타이머 화면과, 차단된 앱 접근 시 표시되는 Shield(차단) 화면의 UI를 구현합니다.

## 2. 주요 기능 범위
- **개별 실행 타이머**: 스케줄 '시작' 버튼 탭 시 진입하는 타이머 전체 화면. 남은 시간 표시, 정지 버튼.
- **올인 모드 대시보드**: 메인 화면 상단 '올인 모드' 토글 및 실행 시 상태 바(진행률) 표시.
- **Shield 화면**: 차단된 앱 실행 시도를 시뮬레이션하는 더미 뷰.

## 3. 구현 가이드 (Steps Hint)
1.  **TimerView**: 원형 프로그레스 바와 남은 시간을 표시하는 타이머 UI. `Timer.publish`를 사용해 1초씩 감소하는 로직 Mocking.
2.  **AllInStatusView**: 메인 화면 상단에 삽입될 섹션. '올인 모드 시작' 버튼과, 실행 중일 때의 'n/m 완료' 진행 상태 표시.
3.  **ShieldSimulationView**: 검은 배경에 "집중 중입니다" 텍스트와 "확인" 버튼이 있는 단순 뷰.
    - 실제 Screen Time 차단 대신, 버튼을 누르면 이 뷰가 Modal로 뜨도록 하여 UX 확인.
4.  **Interaction**:
    - 스케줄 시작 -> TimerView 모달 프레젠테이션.
    - 타이머 종료 -> "완료" 알림 후 복귀.
    - 정지 버튼 -> "정말 그만두시겠습니까?" Alert 후 복귀.

## 4. 제약사항 및 제외 범위
- **제외**: 실제 `DeviceActivity` 및 `FamilyControls` 프레임워크 연동 (API 호출 부분은 주석 처리).
- **제외**: 백그라운드 타이머 동작 (앱이 켜져 있을 때만 동작 가정).

---

```yaml
task_id: "EPIC0-FE-002"
title: "집중 모드 실행 및 Shield 화면 시뮬레이션 구현"
summary: >
  스케줄 실행 시 나타나는 타이머 화면과 올인 모드 대시보드,
  그리고 차단 시 보여질 Shield 화면의 레이아웃을 구현한다.
type: "functional"
epic: "EPIC_0_FE_PROTOTYPE"
req_ids: ["REQ-FUNC-006", "REQ-FUNC-007", "REQ-FUNC-008", "REQ-FUNC-010", "REQ-FUNC-012"]
component: ["frontend.ui", "frontend.viewmodel"]

context:
  srs_section: "4.1 기능 요구사항 Story 2 & 3"
  user_story: "사용자는 집중 시간 동안 타이머를 확인하고, 다른 앱 실행 시 차단 화면을 마주해야 한다."

inputs:
  description: "스케줄 시작 액션"
  mock_data:
    - "Selected Schedule: {name: '코딩하기', duration: 1800}"

outputs:
  description: "Timer View 및 Shield View"
  success_criteria:
    - "시작 버튼 탭 시 타이머 화면으로 전환되어야 한다."
    - "타이머 시간이 줄어드는 애니메이션이 동작해야 한다."
    - "가상의 차단 상황에서 Shield 뷰가 표시되어야 한다."

preconditions:
  - "EPIC0-FE-001(메인 화면)이 통합되어 있거나, 독립적으로 실행 가능한 상태여야 한다."

postconditions:
  - "집중 모드 진입/이탈 플로우가 자연스럽게 동작한다."

config:
  feature_flags: []

tests:
  manual:
    - "타이머를 시작하고 중지 버튼을 눌러본다."
    - "올인 모드를 켜고 UI 변화를 확인한다."

dependencies: ["EPIC0-FE-001"]
parallelizable: true
estimated_effort: "M"
priority: "Must"
agent_profile: ["frontend"]
required_tools:
  languages: ["Swift"]
  frameworks: ["SwiftUI"]
```

