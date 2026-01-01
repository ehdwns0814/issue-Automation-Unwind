# REQ-FUNC-015: 차단할 앱 선택 기능 구현

## 1. 개요
사용자가 집중 시간 동안 차단하고 싶은 앱을 선택할 수 있는 설정 화면을 구현합니다. Apple의 `FamilyActivityPicker`를 사용하여 앱 선택 UI를 제공합니다.

## 2. 관련 요구사항
- **REQ-FUNC-015**: 시스템은 차단할 앱을 사용자가 설정할 수 있어야 함

## 3. 기능 범위
- **설정 화면**: 설정 탭에 "차단할 앱 관리" 메뉴 항목 추가.
- **FamilyActivityPicker**: Apple의 공식 Picker를 사용하여 앱 선택 UI 제공.
- **선택 저장**: 선택된 `FamilyActivitySelection` 객체를 UserDefaults에 저장.
- **선택 표시**: 현재 선택된 앱 목록을 설정 화면에 표시.

## 4. 구현 가이드 (Steps Hint)
1. **설정 화면 구성**:
   - `SettingsView`에 "차단할 앱 관리" 섹션 추가.
   - "앱 선택하기" 버튼 또는 링크 제공.
2. **FamilyActivityPicker 통합**:
   - `@State var selection = FamilyActivitySelection()` 선언.
   - `.familyActivityPicker(isPresented: $isPresented, selection: $selection)` 모디파이어 사용.
3. **선택 저장**:
   - `PropertyListEncoder`를 사용하여 `selection` 객체를 `Data`로 변환.
   - UserDefaults에 저장 (키: `unwind_blocked_apps_selection`).
4. **선택 표시**:
   - 저장된 선택을 로드하여 선택된 앱 이름 목록 표시 (선택 사항, Picker가 자체적으로 표시).

## 5. 예외 처리
- Family Controls 권한이 없을 경우 권한 요청 안내.

---

```yaml
task_id: "REQ-FUNC-015"
title: "FamilyActivityPicker를 이용한 차단 앱 선택 기능 구현"
summary: >
  사용자가 집중 시간 동안 차단하고 싶은 앱을 FamilyActivityPicker를 통해
  선택하고, 선택 내용을 로컬에 영구 저장하는 기능을 구현한다.
type: "functional"
epic: "EPIC_3_SETTINGS"
req_ids: ["REQ-FUNC-015"]
component: ["mobile.ios.ui", "mobile.ios.settings"]

context:
  srs_section: "4.1 기능 요구사항 Story 4"
  api_refs: ["FamilyActivityPicker"]
  acceptance_criteria: >
    Given 사용자가 설정 → "차단할 앱 관리"로 이동할 때
    When 기기 앱 목록이 체크박스와 함께 표시되면
    Then 체크/해제 후 "저장" 시 로컬에 설정 저장

inputs:
  description: "사용자의 앱 선택 액션"
  preloaded_state:
    - "Family Controls 권한이 승인되어 있어야 한다."

outputs:
  description: "저장된 FamilyActivitySelection 데이터"
  success_criteria:
    - "FamilyActivityPicker가 정상적으로 표시되어야 한다."
    - "선택한 앱이 UserDefaults에 저장되어야 한다."
    - "앱 재시작 후에도 선택 상태가 유지되어야 한다."

preconditions:
  - "Family Controls 권한 획득이 선행되어야 한다."

postconditions:
  - "선택된 앱 목록이 UserDefaults에 저장된다."
  - "선택된 앱이 차단 기능(REQ-FUNC-006)에서 사용 가능하다."

exceptions:
  - "Family Controls 권한이 없을 경우 권한 요청 안내."

config:
  feature_flags: []

tests:
  unit:
    - "FamilyActivitySelection 저장/로드 테스트"
  manual:
    - "Picker를 열고 앱을 선택한 뒤 저장 → 앱 껐다 켜서 선택 상태 유지 확인."

dependencies: []
parallelizable: true
estimated_effort: "S"
priority: "Must"
agent_profile: ["mobile_dev"]
required_tools:
  languages: ["Swift"]
  frameworks: ["FamilyControls"]
```

