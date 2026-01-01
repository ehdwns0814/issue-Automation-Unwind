# REQ-FUNC-022: Screen Time 권한 거부 안내 구현

## 1. 개요
Screen Time 권한이 거부되었을 때 사용자에게 권한의 필요성을 설명하고 설정 앱으로 이동할 수 있는 안내 화면을 구현합니다.

## 2. 관련 요구사항
- **REQ-FUNC-022**: 시스템은 Screen Time 권한 거부 시 안내 및 설정 이동 기능을 제공해야 함

## 3. 기능 범위
- **권한 상태 확인**: 앱 실행 시 `AuthorizationCenter.shared.authorizationStatus` 확인.
- **안내 화면**: 권한이 거부된 경우 메인 기능을 가리는 Placeholder View 표시.
- **설정 이동**: "설정으로 이동" 버튼 클릭 시 설정 앱의 Screen Time 섹션으로 딥링크.

## 4. 구현 가이드 (Steps Hint)
1. **권한 상태 확인**:
   - `AppDelegate` 또는 `App`의 `onAppear`에서 권한 상태 확인.
   - `.denied` 또는 `.notDetermined`일 경우 안내 화면 표시.
2. **안내 화면 UI**:
   - `PermissionGuideView` 컴포넌트 생성.
   - 권한 필요성 설명 텍스트 및 아이콘 표시.
   - "설정으로 이동" 버튼 제공.
3. **설정 이동**:
   - `UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)` 호출.
   - 또는 Screen Time 설정으로 직접 이동하는 딥링크 사용 (가능한 경우).

## 5. 예외 처리
- 설정 앱 이동 실패 시 일반적인 안내 메시지 표시.

---

```yaml
task_id: "REQ-FUNC-022"
title: "Screen Time 권한 거부 안내 및 설정 이동 구현"
summary: >
  Screen Time 권한이 거부되었을 때 사용자에게 권한의 필요성을 설명하고
  설정 앱으로 이동할 수 있는 안내 화면을 구현한다.
type: "functional"
epic: "EPIC_8_STABILITY"
req_ids: ["REQ-FUNC-022"]
component: ["mobile.ios.ui", "mobile.ios.permission"]

context:
  srs_section: "4.1 기능 요구사항 예외 처리"
  acceptance_criteria: >
    Given Screen Time 권한이 거부되었을 때
    When 앱 실행 시
    Then 권한 필요성 설명 + "설정으로 이동" 버튼 제공

inputs:
  description: "앱 실행 시점의 권한 상태"
  state:
    - "AuthorizationCenter.shared.authorizationStatus"

outputs:
  description: "안내 화면 표시"
  success_criteria:
    - "권한이 거부된 경우 안내 화면이 표시되어야 한다."
    - "설정으로 이동 버튼이 정상 작동해야 한다."

preconditions:
  - "Screen Time 권한 요청 로직이 존재해야 한다."

postconditions:
  - "권한 거부 시 안내 화면이 표시된다."

exceptions:
  - "설정 앱 이동 실패 시 일반적인 안내 메시지 표시."

config:
  feature_flags: []

tests:
  unit:
    - "권한 상태 확인 로직 테스트"
  manual:
    - "권한을 거부한 상태에서 앱 실행하여 안내 화면 확인."

dependencies: []
parallelizable: true
estimated_effort: "S"
priority: "Should"
agent_profile: ["mobile_dev"]
required_tools:
  languages: ["Swift"]
  frameworks: ["SwiftUI", "FamilyControls"]
```

