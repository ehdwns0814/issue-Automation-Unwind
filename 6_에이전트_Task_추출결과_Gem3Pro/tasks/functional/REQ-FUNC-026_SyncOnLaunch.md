# REQ-FUNC-026: 앱 실행 시 스케줄 데이터 동기화 구현

## 1. 개요
앱 실행 시 서버의 최신 스케줄 데이터를 가져와 로컬(UserDefaults)과 병합하는 동기화 기능을 구현합니다.

## 2. 관련 요구사항
- **REQ-FUNC-026**: 시스템은 앱 실행 시 스케줄 데이터를 서버와 동기화해야 함

## 3. 기능 범위
- **동기화 트리거**: 앱 실행 시(`didFinishLaunching` 또는 `onAppear`) 자동 실행.
- **서버 조회**: `GET /api/schedules?since={lastSyncTime}` API 호출.
- **충돌 해결**: Last-Write-Wins 정책으로 로컬과 서버 데이터 병합.
- **로컬 업데이트**: 병합된 데이터를 UserDefaults에 저장.

## 4. 구현 가이드 (Steps Hint)
1. **SyncManager 생성**:
   - `SyncManager` 싱글톤 클래스 생성.
   - `syncOnLaunch()` 메서드 구현.
2. **서버 조회**:
   - `lastSyncTime`을 UserDefaults에서 조회 (없으면 전체 조회).
   - `GET /api/schedules?since={lastSyncTime}` 호출.
3. **충돌 해결**:
   - 서버 데이터와 로컬 데이터를 `clientId` 또는 `id`로 매칭.
   - `lastModified` 타임스탬프 비교하여 최신 데이터 선택.
   - 서버에만 있는 데이터는 로컬에 추가, 로컬에만 있는 데이터는 서버에 전송 (REQ-FUNC-027에서 처리).
4. **로컬 저장**:
   - 병합된 데이터를 UserDefaults에 저장.
   - `lastSyncTime`을 현재 시간으로 업데이트.

## 5. 예외 처리
- 네트워크 오류 시 로컬 데이터만 사용 (오프라인 모드).
- 동기화 실패 시 재시도 큐에 추가.

---

```yaml
task_id: "REQ-FUNC-026"
title: "앱 실행 시 스케줄 데이터 서버 동기화 구현"
summary: >
  앱 실행 시 서버의 최신 스케줄 데이터를 가져와 로컬(UserDefaults)과 병합하는
  동기화 기능을 구현한다. Last-Write-Wins 정책을 사용하여 충돌을 해결한다.
type: "functional"
epic: "EPIC_6_SYNC"
req_ids: ["REQ-FUNC-026"]
component: ["mobile.ios.sync", "mobile.ios.network"]

context:
  srs_section: "4.1 기능 요구사항 동기화 & 부록 C.2, E"
  acceptance_criteria: >
    Given 사용자가 로그인된 상태로 앱을 실행할 때
    When 네트워크 연결이 가능하면
    Then 서버의 최신 스케줄을 가져와 로컬(UserDefaults)과 병합

inputs:
  description: "앱 실행 이벤트"
  preloaded_state:
    - "사용자가 로그인된 상태여야 한다."
    - "네트워크 연결이 가능해야 한다."

outputs:
  description: "동기화된 로컬 데이터베이스"
  success_criteria:
    - "앱 실행 시 자동으로 서버와 동기화가 수행되어야 한다."
    - "서버의 최신 데이터가 로컬에 반영되어야 한다."
    - "충돌이 발생한 경우 Last-Write-Wins 정책으로 해결되어야 한다."

preconditions:
  - "REQ-FUNC-001이 완료되어 Schedule 엔티티와 Repository가 존재해야 한다."
  - "REQ-FUNC-025가 완료되어 인증 토큰이 있어야 한다."

postconditions:
  - "로컬과 서버의 데이터가 병합되어 저장된다."
  - "lastSyncTime이 업데이트된다."

exceptions:
  - "네트워크 오류 시 로컬 데이터만 사용 (오프라인 모드)."
  - "동기화 실패 시 재시도 큐에 추가."

config:
  feature_flags: []

tests:
  unit:
    - "충돌 해결 알고리즘(타임스탬프 비교) 단위 테스트"
  integration:
    - "서버 API와 연동하여 동기화 플로우 테스트"
  scenario:
    - "서버에 새 스케줄 추가 → 앱 재실행 → 로컬에 반영 확인."

dependencies: ["REQ-FUNC-001", "REQ-FUNC-025"]
parallelizable: false
estimated_effort: "L"
priority: "Must"
agent_profile: ["mobile_dev"]
required_tools:
  languages: ["Swift"]
  frameworks: ["Network"]
```

