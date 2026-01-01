# REQ-NF-004: 차단 신뢰성 및 지속성 보장

## 1. 개요
앱 차단 기능이 다양한 예외 상황(기기 재부팅, 앱 강제 종료, OS 업데이트 등)에서도 안정적으로 유지되도록 보장합니다.

## 2. 관련 요구사항
- **REQ-NF-004**: 재부팅 후 차단 유지율 95% 이상
- **REQ-NF-005**: 앱 강제 종료 후 차단 유지율 100%

## 3. 구현/검증 가이드
- **DeviceActivitySchedule**: 백그라운드 스케줄링 API를 적극 활용하여, 앱 프로세스가 죽어도 시스템이 이벤트를 트리거하도록 설계.
- **Persistence Check**: 앱 실행 시(didFinishLaunching), 저장된 스케줄과 현재 `ManagedSettings` 상태를 대조하여 불일치 시 복구하는 로직(`Reconciler`) 구현.
- **Stress Test**: 메모리 부족으로 인한 앱 종료, 배터리 절전 모드 등 극한 상황에서의 동작 테스트.

---

```yaml
task_id: "REQ-NF-004-RELIABILITY"
title: "앱 차단 지속성 및 재해 복구 로직 강화"
summary: >
  시스템에 의해 앱이 종료되거나 기기가 재부팅되어도 차단 상태가 풀리지 않도록
  DeviceActivitySchedule을 정교하게 설정하고, 앱 실행 시 상태 불일치를 자동 복구한다.
type: "non_functional"
epic: "EPIC_NON_FUNC_RELIABILITY"
req_ids: ["REQ-NF-004", "REQ-NF-005"]
component: ["mobile.ios.screentime"]

category: "reliability"
labels: ["reliability:persistence", "reliability:recovery"]

context:
  srs_section: "4.2 비기능 요구사항 신뢰성"

requirements:
  description: "사용자가 의도적으로 앱을 종료해도 차단은 유지되어야 함"
  kpis:
    - "강제 종료 시 차단 해제 0건"

implementation_scope:
  includes:
    - "DeviceActivitySchedule Config"
    - "App Lifecycle Recovery Logic"

steps_hint:
  - "DeviceActivityEvent.intervalDidStart/End 콜백 내 로직 점검."
  - "앱 시작 시 로컬 DB의 '진행 중' 스케줄을 조회하여 ManagedSettings 재적용."

preconditions:
  - "REQ-FUNC-006(Screen Time) 구현 완료."

tests:
  - "재부팅 테스트 (Reboot Persistence Test)."
  - "앱 스위처 강제 종료 테스트."

dependencies: ["REQ-FUNC-006-ST-API"]
parallelizable: true
estimated_effort: "M"
priority: "Must"
agent_profile: ["qa", "mobile_dev"]
required_tools:
  frameworks: ["DeviceActivity"]
```

