# REQ-FUNC-007: Shield 화면 커스터마이징 구현

## 1. 개요
차단된 앱 실행 시도 시 표시되는 Shield 화면을 커스터마이징하여, 현재 집중 중인 스케줄 이름과 남은 시간을 표시하는 기능을 구현합니다.

## 2. 관련 요구사항
- **REQ-FUNC-007**: 시스템은 개별 스케줄 실행 중 차단 앱 접근 시 Shield 화면을 표시해야 함

## 3. 기능 범위
- **Shield Extension**: `ShieldConfiguration` Extension 타겟 생성 및 구현.
- **커스텀 메시지**: "현재 집중 중: [스케줄명], 남은 시간: HH:MM:SS" 형태의 문구 표시.
- **동적 정보**: 실행 중인 스케줄 정보를 Extension에 전달하여 표시.

## 4. 구현 가이드 (Steps Hint)
1. **Extension 타겟 생성**:
   - Xcode에서 `ShieldConfigurationExtension` 타겟 추가.
   - `ShieldConfigurationDataSource` 프로토콜 구현.
2. **데이터 전달**:
   - 앱과 Extension 간 데이터 공유를 위해 App Group 또는 UserDefaults 사용.
   - 실행 중인 스케줄 ID와 남은 시간을 공유 영역에 저장.
3. **Shield 구성**:
   - `ShieldConfiguration` 객체 생성.
   - `title`, `subtitle` 또는 `icon` 설정을 통해 메시지 표시.
   - 가능한 경우 동적 시간 표시 (Extension은 제한적이므로 고정 문구 + 시간 업데이트는 앱에서 주기적 갱신).

## 5. 제약사항
- Shield Extension은 시스템 제약으로 인해 실시간 업데이트가 어려울 수 있음.
- 시뮬레이터에서는 Shield 화면이 제대로 표시되지 않을 수 있으므로 실기기 테스트 필수.

---

```yaml
task_id: "REQ-FUNC-007"
title: "Shield 화면 커스터마이징 구현"
summary: >
  차단된 앱 실행 시도 시 표시되는 Shield 화면에 현재 집중 중인 스케줄 이름과
  남은 시간을 표시하도록 커스터마이징한다.
type: "functional"
epic: "EPIC_2_FOCUS_MODE"
req_ids: ["REQ-FUNC-007"]
component: ["mobile.ios.screentime"]

context:
  srs_section: "4.1 기능 요구사항 Story 2"
  api_refs: ["ShieldConfiguration"]
  acceptance_criteria: >
    Given 개별 스케줄로 앱 차단이 활성화되었을 때
    When 사용자가 차단된 앱을 실행하려 하면
    Then Shield 화면에 "현재 집중 중: [스케줄명], 남은 시간: HH:MM:SS" 표시

inputs:
  description: "실행 중인 스케줄 정보"
  fields:
    - name: "scheduleName"
      type: "String"
    - name: "remainingTime"
      type: "Int (seconds)"

outputs:
  description: "커스터마이징된 Shield 화면"
  success_criteria:
    - "차단된 앱 실행 시도 시 Shield 화면이 표시되어야 한다."
    - "Shield 화면에 스케줄 이름과 남은 시간이 표시되어야 한다."

preconditions:
  - "REQ-FUNC-006이 완료되어 타이머 실행 로직이 존재해야 한다."

postconditions:
  - "ShieldConfigurationExtension 타겟이 생성되어 있다."
  - "Shield 화면에 커스텀 메시지가 표시된다."

exceptions:
  - "Extension에서 실시간 시간 업데이트가 불가능한 경우 고정 문구 사용."

config:
  feature_flags: []

tests:
  manual:
    - "실기기에서 차단된 앱 실행 시도하여 Shield 화면 확인."
    - "스케줄 이름과 시간이 정상 표시되는지 확인."

dependencies: ["REQ-FUNC-006"]
parallelizable: false
estimated_effort: "M"
priority: "Must"
agent_profile: ["mobile_dev"]
required_tools:
  languages: ["Swift"]
  frameworks: ["FamilyControls"]
```

