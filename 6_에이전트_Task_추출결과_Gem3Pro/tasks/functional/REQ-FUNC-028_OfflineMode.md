# REQ-FUNC-028: 오프라인 모드 지원 구현

## 1. 개요
네트워크 연결이 없을 때도 핵심 기능(스케줄 실행, 올인 모드)이 정상 동작하도록 하는 오프라인 모드 지원을 구현합니다.

## 2. 관련 요구사항
- **REQ-FUNC-028**: 시스템은 네트워크 없이도 핵심 기능이 동작해야 함

## 3. 기능 범위
- **네트워크 감지**: `NWPathMonitor`를 사용하여 네트워크 연결 상태 모니터링.
- **오프라인 우선**: 모든 CRUD 작업은 로컬에서 먼저 수행.
- **동기화 지연**: 네트워크 연결 시 자동으로 동기화 재시도.

## 4. 구현 가이드 (Steps Hint)
1. **네트워크 모니터링**:
   - `NetworkMonitor` 싱글톤 클래스 생성.
   - `NWPathMonitor`를 사용하여 연결 상태 감지.
   - `@Published var isConnected: Bool`로 상태 공유.
2. **오프라인 우선 로직**:
   - 모든 CRUD 작업은 네트워크 상태와 관계없이 로컬에서 먼저 수행.
   - 네트워크 연결 시에만 서버 동기화 시도.
3. **동기화 재시도**:
   - 네트워크 연결 복구 감지 시 `SyncManager.syncPending()` 자동 호출.
   - 큐에 쌓인 모든 변경사항을 순차적으로 전송.

## 5. 예외 처리
- 오프라인 상태에서도 사용자에게 명확한 피드백 제공 (선택 사항).

---

```yaml
task_id: "REQ-FUNC-028"
title: "오프라인 퍼스트 동작 및 네트워크 복구 시 자동 동기화 구현"
summary: >
  네트워크 연결이 없을 때도 핵심 기능이 정상 동작하도록 하고,
  연결 복구 시 자동으로 동기화를 재시도하는 기능을 구현한다.
type: "functional"
epic: "EPIC_6_SYNC"
req_ids: ["REQ-FUNC-028"]
component: ["mobile.ios.sync", "mobile.ios.network"]

context:
  srs_section: "4.1 기능 요구사항 오프라인"
  acceptance_criteria: >
    Given 네트워크 연결이 없을 때
    When 사용자가 스케줄 실행/올인 모드를 사용하면
    Then 로컬 데이터(UserDefaults)로 정상 동작, 동기화는 연결 복구 시 자동 재시도

inputs:
  description: "네트워크 상태 변화 및 데이터 변경 이벤트"

outputs:
  description: "오프라인 동작 및 자동 동기화"
  success_criteria:
    - "오프라인에서 생성한 스케줄이 온라인 전환 시 서버에 생성되어야 한다."
    - "네트워크 복구 시 자동으로 동기화가 수행되어야 한다."

preconditions:
  - "REQ-FUNC-001이 완료되어 로컬 저장소가 존재해야 한다."
  - "REQ-FUNC-027이 완료되어 동기화 큐가 존재해야 한다."

postconditions:
  - "오프라인 상태에서도 핵심 기능이 정상 동작한다."
  - "네트워크 복구 시 자동으로 동기화가 재시도된다."

exceptions:
  - "오프라인 상태에서도 사용자에게 명확한 피드백 제공 (선택 사항)."

config:
  feature_flags: []

tests:
  unit:
    - "네트워크 상태 감지 로직 테스트"
  scenario:
    - "비행기 모드 ON → 스케줄 생성 → 정상 동작 확인 → OFF → 자동 동기화 확인."

dependencies: ["REQ-FUNC-001", "REQ-FUNC-027"]
parallelizable: false
estimated_effort: "M"
priority: "Must"
agent_profile: ["mobile_dev"]
required_tools:
  languages: ["Swift"]
  frameworks: ["Network"]
```

