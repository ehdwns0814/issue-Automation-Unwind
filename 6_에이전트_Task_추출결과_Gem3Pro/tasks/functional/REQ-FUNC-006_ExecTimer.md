# REQ-FUNC-006: 개별 스케줄 실행 및 타이머 구현

## 1. 개요
사용자가 스케줄을 탭하여 집중 모드를 시작하고, 타이머 기반으로 앱 차단을 활성화하는 기능을 구현합니다. 이 Task는 Screen Time API 권한 요청 및 기본 차단 로직을 포함합니다.

## 2. 관련 요구사항
- **REQ-FUNC-006**: 시스템은 타이머 기반 개별 스케줄 실행 기능을 제공해야 함

## 3. 기능 범위
- **권한 요청**: `FamilyControls.requestAuthorization()`를 통한 Screen Time 권한 획득.
- **타이머 UI**: 스케줄 상세 화면에서 "시작" 버튼 탭 시 타이머 화면 표시.
- **차단 시작**: `DeviceActivityCenter` 및 `ManagedSettingsStore`를 사용하여 앱 차단 활성화.
- **타이머 로직**: `Timer` 객체를 사용하여 카운트다운 구현.

## 4. 구현 가이드 (Steps Hint)
1. **권한 요청**:
   - 앱 최초 실행 시 또는 설정 화면에서 `AuthorizationCenter.shared.requestAuthorization()` 호출.
   - 권한 상태 확인 및 거부 시 안내 화면 표시.
2. **타이머 뷰**:
   - `TimerView` 컴포넌트 생성: 원형 프로그레스 바, 남은 시간 표시 (HH:MM:SS).
   - `@State` 변수로 남은 시간(초) 관리.
   - `Timer.publish` 또는 `DispatchSourceTimer`를 사용하여 1초마다 업데이트.
3. **차단 활성화**:
   - `DeviceActivityCenter`를 사용하여 모니터링 시작.
   - `ManagedSettingsStore`의 `shield.applications`에 선택된 앱 토큰 설정.
   - 차단할 앱 목록은 REQ-FUNC-015에서 설정된 데이터 사용.
4. **상태 관리**:
   - 실행 중인 스케줄 ID와 시작 시간을 UserDefaults에 저장 (크래시 복구용).

## 5. 예외 처리
- Screen Time 권한이 거부된 경우 안내 화면 표시 및 설정 앱으로 이동 링크 제공.
- 타이머 실행 중 앱이 백그라운드로 전환될 경우 상태 유지 (REQ-FUNC-023에서 상세 처리).

---

```yaml
task_id: "REQ-FUNC-006"
title: "개별 스케줄 실행 및 Screen Time API 기반 앱 차단 시작"
summary: >
  사용자가 스케줄을 시작할 때 타이머를 표시하고, Screen Time API를 사용하여
  설정된 앱들을 차단하는 기능을 구현한다. 이는 집중 모드의 핵심 기능이다.
type: "functional"
epic: "EPIC_2_FOCUS_MODE"
req_ids: ["REQ-FUNC-006"]
component: ["mobile.ios.screentime", "mobile.ios.ui"]

context:
  srs_section: "4.1 기능 요구사항 Story 2 & 3.1 외부 시스템"
  api_refs: ["FamilyControls", "ManagedSettings", "DeviceActivity"]
  acceptance_criteria: >
    Given 사용자가 스케줄 아이템을 탭할 때
    When 차단 화면에서 스케줄 이름과 시간이 표시되면
    Then "시작" 버튼이 카운트다운과 앱 차단을 시작함

inputs:
  description: "사용자의 스케줄 시작 액션"
  fields:
    - name: "scheduleId"
      type: "UUID"
      required: true
  preloaded_state:
    - "Screen Time 권한이 사용자로부터 승인되어야 한다."
    - "차단할 앱 목록이 설정되어 있어야 한다 (REQ-FUNC-015)."

outputs:
  description: "타이머 실행 및 앱 차단 활성화"
  success_criteria:
    - "시작 버튼 탭 시 타이머 화면으로 전환되어야 한다."
    - "타이머 시간이 1초씩 감소해야 한다."
    - "설정된 앱들이 차단되어야 한다."

preconditions:
  - "REQ-FUNC-001이 완료되어 Schedule 엔티티가 존재해야 한다."
  - "Apple Developer Account에 Family Controls capability가 추가되어 있어야 한다."

postconditions:
  - "타이머가 실행 중인 상태로 표시된다."
  - "ManagedSettingsStore에 차단 앱 목록이 설정된다."
  - "실행 중인 스케줄 정보가 UserDefaults에 저장된다."

exceptions:
  - "Screen Time 권한 거부 시 안내 화면 표시."
  - "타이머 실행 중 백그라운드 전환 시 상태 유지."

config:
  feature_flags: []

tests:
  unit:
    - "타이머 카운트다운 로직 테스트"
  manual:
    - "실기기에서 소셜 미디어 앱을 차단 목록에 넣고 테스트."
    - "타이머 시작 후 차단된 앱 실행 시도하여 차단 확인."

dependencies: ["REQ-FUNC-001"]
parallelizable: false
estimated_effort: "L"
priority: "Must"
agent_profile: ["mobile_dev"]
required_tools:
  languages: ["Swift"]
  frameworks: ["FamilyControls", "ManagedSettings", "DeviceActivity"]
```

