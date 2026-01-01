# REQ-FUNC-012: 올인 모드용 Shield 화면 커스터마이징 구현

## 1. 개요
올인 모드가 활성화된 상태에서 차단된 앱 실행 시도 시 표시되는 Shield 화면에 진행 상황("완료: n/m")을 표시하도록 커스터마이징합니다.

## 2. 관련 요구사항
- **REQ-FUNC-012**: 시스템은 올인 모드 중 차단 앱 접근 시 진행 상황을 표시해야 함

## 3. 기능 범위
- **Shield 메시지 변경**: 올인 모드일 때와 개별 실행일 때 다른 메시지 표시.
- **진행 상황 표시**: "올인 모드 진행 중. 완료: n/m" 형태의 문구 표시.
- **동적 정보 전달**: 완료 개수와 전체 개수를 Extension에 전달.

## 4. 구현 가이드 (Steps Hint)
1. **상태 구분**:
   - 앱과 Extension 간 공유 영역에 올인 모드 활성화 여부 저장.
   - 완료 개수와 전체 개수도 함께 저장.
2. **Shield 구성**:
   - `ShieldConfigurationDataSource`에서 올인 모드 상태 확인.
   - 올인 모드일 경우 "올인 모드 진행 중. 완료: n/m" 메시지 표시.
   - 개별 실행일 경우 기존 메시지(REQ-FUNC-007) 표시.
3. **정보 업데이트**:
   - 스케줄 완료 시(REQ-FUNC-011) 공유 영역의 완료 개수 업데이트.
   - Extension이 최신 정보를 읽어 Shield 화면에 반영.

## 5. 제약사항
- Extension의 제약으로 인해 실시간 업데이트가 어려울 수 있으므로, 앱에서 주기적으로 정보를 갱신.

---

```yaml
task_id: "REQ-FUNC-012"
title: "올인 모드용 Shield 화면 커스터마이징 구현"
summary: >
  올인 모드가 활성화된 상태에서 차단된 앱 실행 시도 시 표시되는 Shield 화면에
  진행 상황("완료: n/m")을 표시하도록 커스터마이징한다.
type: "functional"
epic: "EPIC_2_FOCUS_MODE"
req_ids: ["REQ-FUNC-012"]
component: ["mobile.ios.screentime"]

context:
  srs_section: "4.1 기능 요구사항 Story 3"
  acceptance_criteria: >
    Given 올인 모드가 활성화되었을 때
    When 사용자가 차단된 앱을 실행하려 하면
    Then Shield 화면에 "올인 모드 진행 중. 완료: n/m" 표시

inputs:
  description: "올인 모드 진행 상황 정보"
  fields:
    - name: "completedCount"
      type: "Int"
    - name: "totalCount"
      type: "Int"

outputs:
  description: "커스터마이징된 Shield 화면"
  success_criteria:
    - "올인 모드일 때 Shield 화면에 진행 상황이 표시되어야 한다."
    - "완료 개수와 전체 개수가 정확히 표시되어야 한다."

preconditions:
  - "REQ-FUNC-007이 완료되어 Shield Extension이 존재해야 한다."
  - "REQ-FUNC-010이 완료되어 올인 모드가 시작되어 있어야 한다."

postconditions:
  - "Shield 화면에 올인 모드 진행 상황이 표시된다."

exceptions:
  - "Extension 제약으로 인한 실시간 업데이트 제한."

config:
  feature_flags: []

tests:
  manual:
    - "올인 모드에서 차단된 앱 실행 시도하여 Shield 화면 확인."
    - "완료 개수 변경 시 Shield 메시지 업데이트 확인."

dependencies: ["REQ-FUNC-007", "REQ-FUNC-010"]
parallelizable: false
estimated_effort: "S"
priority: "Must"
agent_profile: ["mobile_dev"]
required_tools:
  languages: ["Swift"]
  frameworks: ["FamilyControls"]
```

