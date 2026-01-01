# REQ-FUNC-016: 앱 버전 정보 표시 구현

## 1. 개요
설정 화면 하단에 앱 버전 정보를 표시하는 간단한 기능을 구현합니다.

## 2. 관련 요구사항
- **REQ-FUNC-016**: 시스템은 앱 버전 정보를 표시해야 함

## 3. 기능 범위
- **버전 정보 조회**: `Bundle.main.infoDictionary`에서 버전 정보 가져오기.
- **UI 표시**: 설정 화면 하단에 "v1.0.0" 형태로 표시.

## 4. 구현 가이드 (Steps Hint)
1. **버전 정보 조회**:
   - `Bundle.main.infoDictionary["CFBundleShortVersionString"]` 또는 `Bundle.main.infoDictionary["CFBundleVersion"]` 사용.
   - 버전 문자열 포맷팅 (예: "v\(version)").
2. **UI 구현**:
   - `SettingsView` 하단에 `Text("v\(version)")` 추가.
   - 작은 폰트 크기 및 회색 색상 적용.

## 5. 예외 처리
- 버전 정보가 없을 경우 기본값 표시 또는 숨김.

---

```yaml
task_id: "REQ-FUNC-016"
title: "앱 버전 정보 표시 구현"
summary: >
  설정 화면 하단에 앱 버전 정보를 표시하는 간단한 기능을 구현한다.
type: "functional"
epic: "EPIC_3_SETTINGS"
req_ids: ["REQ-FUNC-016"]
component: ["mobile.ios.ui"]

context:
  srs_section: "4.1 기능 요구사항 Story 4"
  acceptance_criteria: >
    Given 사용자가 설정 화면에 있을 때
    When 화면이 로드되면
    Then 하단에 앱 버전 (예: "v1.0.0") 표시

inputs:
  description: "설정 화면 로드"

outputs:
  description: "버전 정보 표시"
  success_criteria:
    - "설정 화면 하단에 버전 정보가 표시되어야 한다."
    - "버전 형식이 'v1.0.0' 형태여야 한다."

preconditions:
  - "설정 화면이 존재해야 한다."

postconditions:
  - "설정 화면 하단에 버전 정보가 표시된다."

exceptions:
  - "버전 정보가 없을 경우 기본값 표시 또는 숨김."

config:
  feature_flags: []

tests:
  unit:
    - "버전 정보 조회 로직 테스트"
  manual:
    - "설정 화면에서 버전 정보가 정상 표시되는지 확인."

dependencies: []
parallelizable: true
estimated_effort: "S"
priority: "Must"
agent_profile: ["mobile_dev"]
required_tools:
  languages: ["Swift"]
  frameworks: ["SwiftUI"]
```

