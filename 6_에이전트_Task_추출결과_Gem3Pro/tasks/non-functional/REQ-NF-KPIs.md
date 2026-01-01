# REQ-NF-013~016: KPI 측정 및 분석 환경 구축

## 1. 개요
프로젝트의 성공 여부를 판단하는 핵심 성과 지표(KPI)를 측정할 수 있는 데이터 파이프라인과 대시보드를 구축합니다.

## 2. 관련 요구사항
- **REQ-NF-013**: 일일 스케줄 완전 달성률 (목표 75%)
- **REQ-NF-014**: 7일 스트릭 유지율 (목표 60%)
- **REQ-NF-015**: 앱 차단 우회율 (목표 15% 이하)
- **REQ-NF-016**: 30일 리텐션율 (목표 50%)

## 3. 구현/검증 가이드
- **Event Tracking**:
    - `ScheduleCompleted`, `StreakUpdated`, `BlockBypassed`(권한 해제), `AppOpened` 이벤트를 정의.
    - 백엔드 DB 또는 별도 분석 도구(Mixpanel, Firebase Analytics)로 전송.
- **Dashboard**:
    - Grafana 또는 Metabase를 사용하여 KPI 시각화.
    - SQL 쿼리 작성 (예: `SELECT count(*) FROM daily_stats WHERE completion_rate = 1.0 ...`).
- **A/B Testing Support**: Feature Flag에 따라 KPI 변화를 추적할 수 있도록 사용자 그룹 태깅.

---

```yaml
task_id: "REQ-NF-KPI-ANALYTICS"
title: "핵심 KPI 측정 및 분석 대시보드 구축"
summary: >
  달성률, 유지율, 우회율, 리텐션 등 핵심 비즈니스 지표를 정량적으로 측정하기 위해
  로그 이벤트를 설계하고 시각화 대시보드를 구축한다.
type: "non_functional"
epic: "EPIC_NON_FUNC_ANALYTICS"
req_ids: ["REQ-NF-013", "REQ-NF-014", "REQ-NF-015", "REQ-NF-016"]
component: ["backend.analytics", "infra.monitoring"]

category: "monitoring"
labels: ["monitoring:business", "analytics:kpi"]

context:
  srs_section: "4.2 비기능 요구사항 KPI"

requirements:
  description: "PO가 실시간으로 제품 성과를 확인할 수 있어야 함"

implementation_scope:
  includes:
    - "Analytics Event Schema"
    - "SQL Queries for KPI"
    - "Dashboard Setup"

steps_hint:
  - "User Table과 DailyStatistics Table을 조인하여 리텐션 쿼리 작성."
  - "우회율 계산 로직(권한 해제 수 / 전체 세션 수) 정의."

preconditions:
  - "통계 데이터 수집(REQ-FUNC-029)이 선행되어야 함."

tests:
  - "데이터 정합성 테스트 (DB 데이터 vs 대시보드 수치 비교)."

dependencies: ["REQ-FUNC-029-STATS-REPORT"]
parallelizable: true
estimated_effort: "M"
priority: "Should"
agent_profile: ["data_engineer", "backend_dev"]
required_tools:
  frameworks: ["SQL", "Grafana/Metabase"]
```

