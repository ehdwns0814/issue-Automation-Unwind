# REQ-FUNC-029: 스케줄 완료 통계 데이터 서버 전송 구현

## 1. 개요
스케줄이 완료되거나 중단될 때 통계 데이터(달성 여부, 집중 시간)를 서버로 전송하는 기능을 구현합니다.

## 2. 관련 요구사항
- **REQ-FUNC-029**: 시스템은 스케줄 완료 시 통계 데이터를 서버에 전송해야 함

## 3. 기능 범위
- **통계 수집**: 스케줄 완료/중단 시점에 통계 데이터 수집.
- **API 전송**: `POST /api/stats/completion` 엔드포인트 호출.
- **오프라인 처리**: 네트워크 오류 시 Sync Queue에 추가하여 나중에 재시도.

## 4. 구현 가이드 (Steps Hint)
1. **통계 데이터 구조**:
   - `CompletionStats` 구조체 정의: `scheduleId`, `userId`, `completed` (Bool), `focusTime` (Int, 초), `timestamp`.
2. **수집 시점**:
   - REQ-FUNC-009 (타이머 완료) 또는 REQ-FUNC-008 (정지)에서 통계 수집.
   - REQ-FUNC-013 (올인 모드 완료) 또는 REQ-FUNC-014 (올인 모드 포기)에서도 수집.
3. **전송 로직**:
   - `StatsReportingService` 클래스 생성.
   - `reportCompletion(stats: CompletionStats)` 메서드 구현.
   - 네트워크 연결 시 즉시 전송, 실패 시 Sync Queue에 추가.
4. **API 호출**:
   - `POST /api/stats/completion` 호출.
   - 요청 바디: `{ scheduleId, completed, focusTime, timestamp }`.
   - 인증 토큰을 헤더에 포함.

## 5. 예외 처리
- 네트워크 오류 시 Sync Queue에 저장하여 나중에 재시도.
- 서버 오류(5xx)는 재시도, 클라이언트 오류(4xx)는 에러 로그 기록.

---

```yaml
task_id: "REQ-FUNC-029"
title: "스케줄 완료 통계 데이터 서버 전송 구현"
summary: >
  스케줄이 완료되거나 중단될 때 통계 데이터(달성 여부, 집중 시간)를
  서버로 전송하는 기능을 구현한다. 오프라인 상황을 고려하여 Sync Engine을 경유한다.
type: "functional"
epic: "EPIC_7_STATS"
req_ids: ["REQ-FUNC-029"]
component: ["mobile.ios.network", "mobile.ios.analytics"]

context:
  srs_section: "4.1 기능 요구사항 통계 전송"
  acceptance_criteria: >
    Given 스케줄이 완료되거나 중단될 때
    When 네트워크 연결이 가능하면
    Then 사용자 ID, 달성 여부, 집중 시간을 서버에 전송

inputs:
  description: "스케줄 완료/중단 이벤트"
  fields:
    - name: "scheduleId"
      type: "UUID"
    - name: "completed"
      type: "Bool"
    - name: "focusTime"
      type: "Int (seconds)"

outputs:
  description: "서버로 전송되는 통계 로그"
  success_criteria:
    - "스케줄 완료/중단 시 통계 데이터가 서버에 전송되어야 한다."
    - "오프라인 시 큐에 저장되어 나중에 재시도되어야 한다."

preconditions:
  - "REQ-FUNC-009 또는 REQ-FUNC-008이 완료되어 완료/중단 이벤트가 발생해야 한다."
  - "REQ-FUNC-027이 완료되어 Sync Queue가 존재해야 한다."

postconditions:
  - "통계 데이터가 서버에 전송되거나 큐에 저장된다."

exceptions:
  - "네트워크 오류 시 Sync Queue에 저장하여 나중에 재시도."
  - "서버 오류는 재시도, 클라이언트 오류는 에러 로그 기록."

config:
  feature_flags: []

tests:
  unit:
    - "통계 데이터 수집 로직 테스트"
  integration:
    - "서버 API와 연동하여 전송 플로우 테스트"
  scenario:
    - "스케줄 완료 → 통계 전송 확인."

dependencies: ["REQ-FUNC-009", "REQ-FUNC-027"]
parallelizable: false
estimated_effort: "M"
priority: "Must"
agent_profile: ["mobile_dev"]
required_tools:
  languages: ["Swift"]
  frameworks: ["Network"]
```

