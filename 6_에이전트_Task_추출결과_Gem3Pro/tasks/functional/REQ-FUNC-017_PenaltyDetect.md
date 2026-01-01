# REQ-FUNC-017: 권한 해제 감지 및 사유 입력 강제 구현

## 1. 개요
집중 세션 중 사용자가 시스템 설정에서 Screen Time 권한을 강제로 해제했을 때를 감지하고, 앱 재진입 시 사유 입력을 강제하는 기능을 구현합니다.

## 2. 관련 요구사항
- **REQ-FUNC-017**: 시스템은 권한 해제 시 사유 입력을 강제해야 함

## 3. 기능 범위
- **권한 상태 감지**: 앱 활성화 시 `AuthorizationCenter.shared.authorizationStatus` 확인.
- **세션 상태 추적**: 집중 세션 시작 시 `isSessionActive = true` 저장.
- **우회 감지**: 세션이 활성화된 상태에서 권한이 해제된 경우 감지.
- **강제 팝업**: 우회 감지 시 앱 진입을 막는 강제 사유 입력 모달 표시.

## 4. 구현 가이드 (Steps Hint)
1. **상태 추적**:
   - 집중 세션 시작 시(REQ-FUNC-006 또는 REQ-FUNC-010) `isSessionActive = true`를 UserDefaults에 저장.
   - 세션 종료 시(완료 또는 정지) `isSessionActive = false`로 설정.
2. **권한 상태 확인**:
   - `AppDelegate` 또는 `App`의 `onChange(of: scenePhase)`에서 앱 활성화 시 권한 상태 확인.
   - `AuthorizationCenter.shared.authorizationStatus`가 `.denied` 또는 `.notDetermined`이고 `isSessionActive == true`이면 우회 감지.
3. **강제 팝업**:
   - `isPenaltyPending = true` 플래그 설정.
   - 최상위 뷰에 `fullScreenCover` 또는 `ZStack`을 사용하여 닫을 수 없는 모달 표시.
   - "스스로에게 정직해지세요" 메시지와 사유 입력 필드 제공.

## 5. 예외 처리
- 권한 상태 확인 중 오류 발생 시 안전하게 처리.

---

```yaml
task_id: "REQ-FUNC-017"
title: "권한 무단 해제 감지 및 사유 입력 강제 로직 구현"
summary: >
  집중 세션 중 스크린 타임 권한을 해제하는 우회 시도를 감지하고,
  사유를 입력해야만 앱을 다시 사용할 수 있도록 하는 강제 로직을 구현한다.
type: "functional"
epic: "EPIC_4_ANTI_CHEAT"
req_ids: ["REQ-FUNC-017"]
component: ["mobile.ios.logic", "mobile.ios.ui"]

context:
  srs_section: "4.1 기능 요구사항 Story 5"
  acceptance_criteria: >
    Given 집중 세션 중 Screen Time 권한이 해제되었을 때
    When 사용자가 앱에 재진입하면
    Then "스스로에게 정직해지세요" 메시지와 함께 사유 입력 팝업 강제 표시

inputs:
  description: "앱 활성화 시점의 권한 상태"
  state:
    - "이전 세션 활성화 여부 (isSessionActive)"
    - "현재 권한 상태 (authorizationStatus)"

outputs:
  description: "패널티 UI 표시"
  success_criteria:
    - "권한 해제 후 재진입 시 반드시 사유 입력창이 떠야 한다."
    - "사유를 입력하지 않으면 앱을 사용할 수 없어야 한다."

preconditions:
  - "REQ-FUNC-006 또는 REQ-FUNC-010이 완료되어 집중 세션 시작 로직이 존재해야 한다."

postconditions:
  - "우회 감지 시 isPenaltyPending 플래그가 설정된다."
  - "강제 사유 입력 모달이 표시된다."

exceptions:
  - "권한 상태 확인 중 오류 발생 시 안전하게 처리."

config:
  feature_flags: []

tests:
  unit:
    - "권한 상태 감지 로직 테스트"
    - "우회 감지 로직 테스트"
  manual:
    - "집중 모드 실행 → 설정 앱 이동 → 권한 해제 → 앱 복귀 → 패널티 창 확인."

dependencies: ["REQ-FUNC-006", "REQ-FUNC-010"]
parallelizable: false
estimated_effort: "M"
priority: "Should"
agent_profile: ["mobile_dev"]
required_tools:
  languages: ["Swift"]
  frameworks: ["FamilyControls"]
```

