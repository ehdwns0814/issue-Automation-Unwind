# REQ-NF-001: 성능 최적화 및 응답 시간 보장

## 1. 개요
앱의 반응성(Responsiveness)을 보장하기 위해 핵심 인터랙션의 지연 시간을 모니터링하고 최적화합니다.
특히 Shield 화면 표시 속도와 스케줄 CRUD 응답 속도를 중점 관리합니다.

## 2. 관련 요구사항
- **REQ-NF-001**: Shield 화면 표시 지연 ≤ 0.5초
- **REQ-NF-002**: 스케줄 CRUD UI 업데이트 ≤ 0.3초
- **REQ-NF-017**: 백엔드 API 응답 시간 ≤ 500ms

## 3. 구현/검증 가이드
- **Instruments Profiling**: Xcode Instruments(Time Profiler)를 사용하여 메인 스레드 차단 요소 식별.
- **Optimistic UI**: 네트워크 요청 시 UI를 먼저 업데이트하고(낙관적 업데이트), 실패 시 롤백하는 패턴 적용.
- **Shield Extension Optimization**: Extension 로딩 시간을 줄이기 위해 무거운 초기화 로직 제거, 메모리 사용 최소화.
- **Backend Caching**: 자주 조회되는 통계 데이터 등에 Redis 캐싱 적용.

---

```yaml
task_id: "REQ-NF-001-PERF"
title: "앱 응답성 최적화 및 성능 프로파일링"
summary: >
  Shield 화면과 주요 CRUD 동작의 반응 속도를 목표치 이내로 달성하기 위해
  Optimistic UI 패턴을 적용하고 병목 구간을 프로파일링하여 개선한다.
type: "non_functional"
epic: "EPIC_NON_FUNC_PERF"
req_ids: ["REQ-NF-001", "REQ-NF-002", "REQ-NF-017"]
component: ["mobile.ios.ui", "backend.api"]

category: "performance"
labels: ["performance:latency", "ux:responsiveness"]

context:
  srs_section: "4.2 비기능 요구사항 성능"

requirements:
  description: "사용자가 '느리다'고 느끼지 않도록 p95 기준 목표 달성"
  kpis:
    - "Shield 표시 < 0.5s"
    - "CRUD UI 반영 < 0.3s"

implementation_scope:
  includes:
    - "ShieldConfigurationExtension"
    - "ScheduleViewModel"
    - "API Response Time"

steps_hint:
  - "ViewModel에서 API 호출 전 로컬 State를 먼저 변경하도록 수정 (Optimistic Update)."
  - "Shield Extension의 초기화 코드에서 불필요한 File I/O 제거."
  - "k6 등을 이용한 백엔드 부하 테스트 수행."

preconditions:
  - "기본 기능 구현이 완료되어 있어야 함."

tests:
  - "MetricKit을 통해 실제 사용자의 히스토그램 데이터 수집."
  - "XCTest의 measure block을 사용한 성능 벤치마크 테스트."

dependencies: ["REQ-FUNC-001-CRUD-IMPL", "REQ-FUNC-006-ST-API"]
parallelizable: true
estimated_effort: "M"
priority: "Must"
agent_profile: ["qa", "mobile_dev"]
required_tools:
  frameworks: ["XCTest", "Instruments"]
```

