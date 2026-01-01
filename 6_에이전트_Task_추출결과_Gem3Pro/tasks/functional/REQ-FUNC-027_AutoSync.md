# REQ-FUNC-027: 스케줄 변경 시 자동 동기화 구현

## 1. 개요
사용자가 스케줄을 생성/수정/삭제할 때 즉시 서버에 변경사항을 전송하고, 실패 시 로컬 큐에 저장하여 나중에 재시도하는 기능을 구현합니다.

## 2. 관련 요구사항
- **REQ-FUNC-027**: 시스템은 스케줄 변경 시 서버에 자동 동기화해야 함

## 3. 기능 범위
- **변경 감지**: 스케줄 CRUD 작업 후 `syncStatus = "pending"` 설정.
- **즉시 전송**: 네트워크 연결 시 변경사항을 즉시 서버에 전송.
- **동기화 큐**: 실패한 요청을 로컬 큐에 저장.
- **백그라운드 재시도**: 주기적으로 큐의 항목을 재시도.

## 4. 구현 가이드 (Steps Hint)
1. **SyncQueue 시스템**:
   - `SyncOperation` 구조체 정의: `type` (create/update/delete), `payload`, `timestamp`.
   - UserDefaults에 큐 배열로 저장 (키: `unwind_sync_queue`).
2. **변경 감지**:
   - `ScheduleRepository`의 CRUD 메서드에서 작업 완료 후 `syncStatus = "pending"` 설정.
   - `SyncManager.enqueue(operation)` 호출하여 큐에 추가.
3. **즉시 전송**:
   - `SyncManager.syncPending()` 메서드 구현.
   - 네트워크 연결 확인 후 큐의 항목을 순차적으로 전송.
   - 성공 시 큐에서 제거, 실패 시 유지 (4xx 제외, 서버 오류는 재시도).
4. **백그라운드 재시도**:
   - 앱 활성화 시 또는 주기적으로(예: 15분마다) 재시도 실행.
   - 최대 재시도 횟수 제한 (예: 3회).

## 5. 예외 처리
- 네트워크 오류 시 큐에 저장하고 연결 복구 시 자동 재시도.
- 4xx 오류(클라이언트 오류)는 재시도하지 않고 에러 로그 기록.

---

```yaml
task_id: "REQ-FUNC-027"
title: "스케줄 변경 시 자동 동기화 및 재시도 큐 구현"
summary: >
  스케줄 생성/수정/삭제 시 즉시 서버에 변경사항을 전송하고,
  실패 시 로컬 큐에 저장하여 나중에 재시도하는 기능을 구현한다.
type: "functional"
epic: "EPIC_6_SYNC"
req_ids: ["REQ-FUNC-027"]
component: ["mobile.ios.sync", "mobile.ios.network"]

context:
  srs_section: "4.1 기능 요구사항 동기화"
  acceptance_criteria: >
    Given 사용자가 스케줄을 생성/수정/삭제할 때
    When 네트워크 연결이 가능하면
    Then 즉시 서버에 변경사항 전송, 실패 시 로컬 큐에 저장

inputs:
  description: "스케줄 변경 이벤트"
  operations:
    - "create"
    - "update"
    - "delete"

outputs:
  description: "서버 전송 완료 또는 큐 저장"
  success_criteria:
    - "스케줄 변경 시 즉시 서버에 전송되어야 한다."
    - "전송 실패 시 큐에 저장되어야 한다."
    - "네트워크 복구 시 자동으로 재시도되어야 한다."

preconditions:
  - "REQ-FUNC-001이 완료되어 Schedule Repository가 존재해야 한다."
  - "REQ-FUNC-025가 완료되어 인증 토큰이 있어야 한다."

postconditions:
  - "변경사항이 서버에 전송되거나 큐에 저장된다."
  - "syncStatus가 'synced' 또는 'pending'으로 설정된다."

exceptions:
  - "네트워크 오류 시 큐에 저장하고 연결 복구 시 자동 재시도."
  - "4xx 오류는 재시도하지 않고 에러 로그 기록."

config:
  feature_flags: []

tests:
  unit:
    - "SyncQueue의 FIFO 동작 테스트"
    - "재시도 로직 테스트"
  scenario:
    - "비행기 모드 ON → 스케줄 생성 → 큐 저장 확인 → OFF → 자동 재시도 확인."

dependencies: ["REQ-FUNC-001", "REQ-FUNC-025"]
parallelizable: false
estimated_effort: "L"
priority: "Must"
agent_profile: ["mobile_dev"]
required_tools:
  languages: ["Swift"]
  frameworks: ["Network"]
```

