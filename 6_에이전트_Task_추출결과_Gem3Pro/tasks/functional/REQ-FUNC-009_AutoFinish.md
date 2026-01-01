# REQ-FUNC-009: 타이머 완료 시 자동 완료 처리 구현

## 1. 개요
개별 스케줄 타이머가 0:00에 도달했을 때 자동으로 스케줄을 완료 처리하고, 차단을 해제하며 축하 메시지를 표시하는 기능을 구현합니다.

## 2. 관련 요구사항
- **REQ-FUNC-009**: 시스템은 타이머 완료 시 자동으로 스케줄을 완료 처리해야 함

## 3. 기능 범위
- **완료 감지**: 타이머가 0에 도달했을 때 이벤트 처리.
- **차단 해제**: `ManagedSettingsStore.clearAllSettings()` 호출.
- **완료 상태 저장**: 스케줄의 `isCompleted = true`, `completedAt` 설정.
- **축하 메시지**: "완료!" 알림 표시 후 메인 화면으로 복귀.
- **통계 전송**: 완료 통계를 서버에 전송 (REQ-FUNC-029에서 처리).

## 4. 구현 가이드 (Steps Hint)
1. **완료 감지**:
   - 타이머 카운트다운 로직에서 남은 시간이 0이 되었을 때 콜백 호출.
   - `onTimerComplete` 또는 `Timer`의 completion handler 구현.
2. **차단 해제**:
   - `ManagedSettingsStore.shared.clearAllSettings()` 호출.
   - 실행 중인 스케줄 정보를 UserDefaults에서 제거.
3. **완료 상태 저장**:
   - `ScheduleRepository`의 `markAsCompleted(scheduleId: UUID)` 메서드 호출.
   - `isCompleted = true`, `completedAt = Date().iso8601String` 설정.
   - `syncStatus = "pending"` 설정하여 서버 동기화 대기열에 추가.
4. **UI 피드백**:
   - 축하 메시지 Alert 또는 Toast 표시.
   - 메인 화면(스케줄 목록)으로 자동 전환.

## 5. 예외 처리
- 완료 처리 중 앱이 백그라운드로 전환될 경우 상태 저장 완료 보장.
- 완료 처리 중 네트워크 오류 발생 시 로컬 저장은 완료하고 동기화는 재시도 큐에 추가.

---

```yaml
task_id: "REQ-FUNC-009"
title: "타이머 완료 시 자동 완료 처리 구현"
summary: >
  개별 스케줄 타이머가 0:00에 도달했을 때 자동으로 스케줄을 완료 처리하고,
  차단을 해제하며 축하 메시지를 표시하는 기능을 구현한다.
type: "functional"
epic: "EPIC_2_FOCUS_MODE"
req_ids: ["REQ-FUNC-009"]
component: ["mobile.ios.ui", "mobile.ios.repository"]

context:
  srs_section: "4.1 기능 요구사항 Story 2"
  acceptance_criteria: >
    Given 개별 스케줄 타이머가 0:00에 도달할 때
    When 타이머가 종료되면
    Then 차단 비활성화, "완료!" 메시지, 완료 상태 저장, 목록 복귀

inputs:
  description: "타이머 완료 이벤트"
  state:
    - "실행 중인 스케줄 정보"
    - "타이머 남은 시간 = 0"

outputs:
  description: "완료 처리 및 상태 업데이트"
  success_criteria:
    - "타이머가 0에 도달하면 자동으로 완료 처리되어야 한다."
    - "앱 차단이 즉시 해제되어야 한다."
    - "스케줄이 완료 상태로 저장되어야 한다."
    - "축하 메시지가 표시되어야 한다."

preconditions:
  - "REQ-FUNC-006이 완료되어 타이머 실행 로직이 존재해야 한다."

postconditions:
  - "스케줄의 isCompleted가 true로 설정된다."
  - "completedAt이 현재 시간으로 설정된다."
  - "차단이 해제되고 메인 화면으로 복귀한다."

exceptions:
  - "완료 처리 중 백그라운드 전환 시 상태 저장 완료 보장."
  - "네트워크 오류 시 로컬 저장 완료 후 동기화 재시도."

config:
  feature_flags: []

tests:
  unit:
    - "타이머 완료 감지 로직 테스트"
    - "완료 상태 저장 로직 테스트"
  manual:
    - "짧은 시간(예: 10초)으로 타이머를 설정하여 자동 완료 확인."

dependencies: ["REQ-FUNC-006"]
parallelizable: false
estimated_effort: "M"
priority: "Must"
agent_profile: ["mobile_dev"]
required_tools:
  languages: ["Swift"]
  frameworks: ["SwiftUI"]
```

