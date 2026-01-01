# REQ-FUNC-018: 권한 해제 사유 기록 및 실패 처리 구현

## 1. 개요
사용자가 입력한 권한 해제 사유를 저장하고, 해당 일자를 실패로 기록하며 스트릭을 업데이트하는 기능을 구현합니다.

## 2. 관련 요구사항
- **REQ-FUNC-018**: 시스템은 권한 해제 사유 제출 시 해당 일자를 경고/실패로 표시해야 함

## 3. 기능 범위
- **사유 저장**: 입력된 사유를 `RevocationLog` 엔티티에 저장.
- **실패 기록**: `DailyRecord`를 실패 상태로 업데이트.
- **스트릭 업데이트**: 스트릭 계산 로직에 실패 반영.
- **서버 전송**: 사유 및 실패 정보를 서버에 전송 (REQ-FUNC-029에서 처리).

## 4. 구현 가이드 (Steps Hint)
1. **사유 저장**:
   - `RevocationLog` 구조체 정의: `id`, `date`, `reason`, `timestamp`.
   - UserDefaults에 저장 (키: `unwind_revocation_logs`).
2. **실패 기록**:
   - `DailyRecord`의 `status = "failure"` 설정.
   - `completedSchedules`는 현재 완료된 개수 유지.
3. **스트릭 업데이트**:
   - `StatsService`의 `calculateStreak()` 메서드 호출하여 스트릭 재계산.
   - 실패일은 스트릭이 끊어짐.
4. **상태 해제**:
   - `isPenaltyPending = false`로 설정하여 패널티 모달 닫기.
   - `isSessionActive = false`로 설정.

## 5. 예외 처리
- 사유 입력 없이 제출 시도 시 유효성 검사.

---

```yaml
task_id: "REQ-FUNC-018"
title: "권한 해제 사유 기록 및 실패 처리 구현"
summary: >
  사용자가 입력한 권한 해제 사유를 저장하고, 해당 일자를 실패로 기록하며
  스트릭을 업데이트하는 기능을 구현한다.
type: "functional"
epic: "EPIC_4_ANTI_CHEAT"
req_ids: ["REQ-FUNC-018"]
component: ["mobile.ios.repository", "mobile.ios.logic"]

context:
  srs_section: "4.1 기능 요구사항 Story 5"
  acceptance_criteria: >
    Given 사용자가 권한 해제 사유를 입력할 때
    When 사유를 제출하면
    Then 해당 날짜 실패 표시, 스트릭 상태 업데이트, 서버 전송

inputs:
  description: "사용자가 입력한 사유"
  fields:
    - name: "reason"
      type: "String"
      required: true
      validation: ["min_length:1"]

outputs:
  description: "사유 저장 및 실패 기록"
  success_criteria:
    - "입력된 사유가 저장되어야 한다."
    - "해당 날짜가 실패 상태로 기록되어야 한다."
    - "스트릭이 업데이트되어야 한다."

preconditions:
  - "REQ-FUNC-017이 완료되어 패널티 감지 로직이 존재해야 한다."

postconditions:
  - "RevocationLog에 사유가 저장된다."
  - "DailyRecord가 실패 상태로 업데이트된다."
  - "스트릭이 재계산된다."
  - "패널티 모달이 닫힌다."

exceptions:
  - "사유 입력 없이 제출 시도 시 유효성 검사."

config:
  feature_flags: []

tests:
  unit:
    - "사유 저장 로직 테스트"
    - "실패 기록 로직 테스트"
    - "스트릭 업데이트 로직 테스트"
  integration:
    - "사유 제출 플로우 전체 검증"

dependencies: ["REQ-FUNC-017"]
parallelizable: false
estimated_effort: "M"
priority: "Should"
agent_profile: ["mobile_dev"]
required_tools:
  languages: ["Swift"]
  frameworks: ["SwiftUI"]
```

