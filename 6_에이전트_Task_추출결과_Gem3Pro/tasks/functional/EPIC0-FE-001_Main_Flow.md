# EPIC0-FE-001: 스케줄 홈 및 CRUD UI 프로토타입

## 1. 개요
**Unwind** 앱의 메인 화면인 스케줄 목록과, 스케줄을 생성/수정/삭제하는 CRUD 플로우의 UI를 구현합니다.

## 2. 주요 기능 범위
- **날짜 탐색**: 상단 주간 캘린더 (좌우 스와이프 또는 탭으로 날짜 변경).
- **스케줄 목록**: 선택된 날짜의 스케줄 카드 리스트 표시.
- **스케줄 생성**: FAB(+) 버튼 탭 시 모달 표시, 이름/시간/날짜 입력.
- **스케줄 수정/삭제**: 리스트 아이템 길게 누르기(Context Menu)로 수정/삭제 진입.

## 3. 구현 가이드 (Steps Hint)
1.  **DateScroller View**: 가로 스크롤 가능한 7일치 날짜 뷰 구현. 선택 상태 시각화.
2.  **ScheduleCard View**: 스케줄 이름, 지속 시간, 완료 여부(체크박스), 시작 버튼을 포함한 카드 UI.
3.  **ScheduleListView**: `ScrollView`와 `LazyVStack`을 사용하여 카드 목록 배치. Mock 데이터 바인딩.
4.  **Creation Sheet**: `Form`을 사용하여 스케줄 이름(TextField), 시간(DatePicker/Picker), 저장 버튼 구현.
5.  **Interaction**:
    - 날짜 변경 시 목록 갱신 애니메이션.
    - '+' 버튼 탭 시 Sheet 호출.
    - 저장 버튼 탭 시 Mock 배열에 데이터 추가 및 목록 갱신.

## 4. 제약사항 및 제외 범위
- **제외**: 실제 `UserDefaults` 영구 저장 (메모리 상 배열로 관리).
- **제외**: 서버 동기화 로직.
- **제외**: 복잡한 입력 검증 (빈 값 체크 정도만 수행).

---

```yaml
task_id: "EPIC0-FE-001"
title: "스케줄 홈 및 CRUD UI 프로토타입 구현"
summary: >
  Unwind 앱의 메인 진입점인 날짜별 스케줄 목록 화면과
  새로운 스케줄을 추가/수정/삭제하는 기본 UI 인터랙션을 구현한다.
type: "functional"
epic: "EPIC_0_FE_PROTOTYPE"
req_ids: ["REQ-FUNC-001", "REQ-FUNC-003", "REQ-FUNC-004", "REQ-FUNC-005"]
component: ["frontend.ui", "frontend.viewmodel"]

context:
  srs_section: "4.1 기능 요구사항 Story 1"
  user_story: "사용자는 날짜별로 계획된 스케줄을 확인하고 관리할 수 있어야 한다."

inputs:
  description: "사용자의 UI 인터랙션 (탭, 스크롤, 입력)"
  mock_data:
    - "User Schedules Array: [{id: 1, name: '영어 공부', duration: 3600, isCompleted: false}, ...]"

outputs:
  description: "SwiftUI View 계층 구조 및 상태 변화"
  success_criteria:
    - "날짜 탭 선택 시 해당 날짜가 강조되고 목록이 변경되어야 한다."
    - "+ 버튼을 눌러 새 스케줄을 리스트에 추가할 수 있어야 한다."
    - "길게 눌러서 삭제 시 리스트에서 즉시 사라져야 한다."

preconditions:
  - "Xcode 프로젝트가 생성되어 있어야 한다."
  - "기본 Mock Data Provider가 준비되어 있어야 한다."

postconditions:
  - "앱 실행 시 메인 화면이 정상 렌더링된다."
  - "메모리 상에서 CRUD 동작이 에러 없이 수행된다."

config:
  feature_flags: []

tests:
  manual:
    - "앱 실행 후 날짜를 변경해본다."
    - "새 스케줄을 등록하고 목록에 표시되는지 확인한다."

dependencies: []
parallelizable: true
estimated_effort: "S"
priority: "Must"
agent_profile: ["frontend"]
required_tools:
  languages: ["Swift"]
  frameworks: ["SwiftUI"]
```

