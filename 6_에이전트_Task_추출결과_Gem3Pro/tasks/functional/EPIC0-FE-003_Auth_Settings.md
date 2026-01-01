# EPIC0-FE-003: 설정, 인증 및 페널티 UI 프로토타입

## 1. 개요
회원가입/로그인 화면, 설정(차단 앱 관리), 그리고 권한 해제 시 패널티(사유 입력) 팝업 UI를 구현합니다.

## 2. 주요 기능 범위
- **인증 화면**: 이메일/비밀번호 입력 폼, 로그인/회원가입 전환.
- **설정 화면**: '차단할 앱 선택' 진입점, 앱 리스트(더미)와 토글 스위치.
- **패널티 팝업**: 앱 진입 시 특정 조건(Mock)에서 강제로 뜨는 사유 입력 모달.

## 3. 구현 가이드 (Steps Hint)
1.  **AuthView**: `TextField`, `SecureField`, 로그인 버튼 구현. 로그인 성공 시 메인 화면(`ContentView`)으로 전환되는 상태(`isLoggedIn`) 관리.
2.  **SettingsView**: `List`와 `Toggle`을 사용하여 설치된 앱 목록(하드코딩된 더미: 인스타그램, 유튜브 등)을 보여주고 차단 여부 선택.
3.  **PenaltyModal**: `ZStack` 또는 `.fullScreenCover`를 활용해 화면을 덮는 모달. 텍스트 입력 후 '제출'을 눌러야만 닫히는 로직.
4.  **Interaction**:
    - 앱 시작 -> `isLoggedIn == false`이면 AuthView 표시.
    - 설정 탭 -> 앱 리스트 토글 조작.
    - 강제 상황 시뮬레이션 -> 버튼을 누르면 패널티 모달 호출.

## 4. 제약사항 및 제외 범위
- **제외**: 실제 서버 인증 통신 (성공으로 가정하고 화면 전환).
- **제외**: 실제 설치된 앱 목록 가져오기 (API 미사용).

---

```yaml
task_id: "EPIC0-FE-003"
title: "설정, 인증 및 페널티 UI 프로토타입 구현"
summary: >
  로그인 플로우, 차단 앱 선택 설정, 그리고 강제성을 부여하는 패널티 입력 팝업 UI를 구현한다.
type: "functional"
epic: "EPIC_0_FE_PROTOTYPE"
req_ids: ["REQ-FUNC-015", "REQ-FUNC-017", "REQ-FUNC-024", "REQ-FUNC-025"]
component: ["frontend.ui", "frontend.auth"]

context:
  srs_section: "4.1 기능 요구사항 Story 4 & 5, 인증"
  user_story: "사용자는 계정을 생성하고, 차단할 앱을 설정하며, 규칙 위반 시 사유를 소명해야 한다."

inputs:
  description: "로그인 정보 및 설정 변경 액션"
  mock_data:
    - "App List: [{name: 'Instagram', icon: 'camera'}, {name: 'YouTube', icon: 'play'}]"

outputs:
  description: "Auth View, Settings View, Penalty Modal"
  success_criteria:
    - "로그인 버튼 누르면 메인 화면으로 전환되어야 한다."
    - "차단 앱 스위치를 켜고 끌 수 있어야 한다."
    - "패널티 팝업은 사유를 입력하지 않으면 닫히지 않아야 한다."

preconditions:
  - "없음 (독립적으로 개발 가능)"

postconditions:
  - "인증-메인-설정 간의 네비게이션이 동작한다."

config:
  feature_flags: []

tests:
  manual:
    - "로그인 시뮬레이션 수행."
    - "패널티 팝업에서 빈 값 제출 시도(실패 확인)."

dependencies: []
parallelizable: true
estimated_effort: "S"
priority: "Should"
agent_profile: ["frontend"]
required_tools:
  languages: ["Swift"]
  frameworks: ["SwiftUI"]
```

