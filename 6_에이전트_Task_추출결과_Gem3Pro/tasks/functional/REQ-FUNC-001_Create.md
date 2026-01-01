# REQ-FUNC-001: 스케줄 생성 기능 구현

## 1. 개요
사용자가 새로운 스케줄을 생성할 수 있는 기능을 구현합니다. 이 Task는 스케줄 관리의 기반이 되는 Entity, Repository, 그리고 Create 로직을 포함합니다.

## 2. 관련 요구사항
- **REQ-FUNC-001**: 시스템은 사용자가 새로운 스케줄을 생성할 수 있어야 함

## 3. 기능 범위
- **Entity 정의**: `Schedule` 구조체 정의 (Codable, Identifiable). SRS 부록 B.1 스펙 준수.
- **Repository 기반 구조**: `ScheduleRepository` 클래스의 기본 구조 및 Create 메서드 구현.
- **ViewModel**: 스케줄 생성 UI와 데이터 레이어를 연결하는 ViewModel 로직.
- **로컬 저장소**: UserDefaults를 사용한 영구 저장 (날짜별 키: `unwind_schedules_{YYYY-MM-DD}`).

## 4. 구현 가이드 (Steps Hint)
1. **Entity 정의**: 
   - `Schedule` 구조체: `id` (UUID), `name` (String), `duration` (Int, 초 단위), `dateForDay` (String, YYYY-MM-DD), `isCompleted` (Bool), `completedAt` (String?), `syncStatus` (String, default: "pending"), `lastModified` (String, ISO 8601).
   - `Codable` 프로토콜 준수하여 JSON 인코딩/디코딩 가능하도록 구현.
2. **Repository 기본 구조**:
   - `ScheduleRepository` 클래스 생성.
   - `create(schedule: Schedule)` 메서드 구현: UUID 발급, `syncStatus = "pending"` 설정, UserDefaults에 JSON 배열로 저장.
3. **UserDefaults 저장 로직**:
   - 날짜별로 분리된 키 사용 (`unwind_schedules_{date}`).
   - 기존 배열을 로드하여 새 항목 추가 후 다시 저장.
4. **ViewModel 연동**:
   - `ScheduleViewModel`에서 Repository 호출.
   - 생성 성공 시 UI 업데이트 트리거.

## 5. 예외 처리
- UserDefaults 저장 실패 시 에러 로그 기록.
- JSON 인코딩 실패 시 사용자에게 알림 표시.

---

```yaml
task_id: "REQ-FUNC-001"
title: "스케줄 생성 기능 및 데이터 모델 구현"
summary: >
  Schedule 엔티티를 정의하고, UserDefaults 기반의 로컬 저장소에
  새로운 스케줄을 생성하는 기능을 구현한다. 이는 스케줄 관리의 기반이 되는 Task이다.
type: "functional"
epic: "EPIC_1_SCHEDULE"
req_ids: ["REQ-FUNC-001"]
component: ["mobile.ios.model", "mobile.ios.repository", "mobile.ios.viewmodel"]

context:
  srs_section: "4.1 기능 요구사항 Story 1 & 부록 B.1"
  entities: ["Schedule"]
  acceptance_criteria: >
    Given 사용자가 "+" 버튼을 탭할 때
    When 스케줄 생성 모달이 나타나면
    Then 이름과 시간을 입력하고 저장 시 UserDefaults와 서버에 저장됨

inputs:
  description: "사용자의 스케줄 생성 입력"
  fields:
    - name: "name"
      type: "String"
      required: true
      validation: ["max_length:100"]
    - name: "duration"
      type: "Int"
      required: true
      validation: ["> 0"]
    - name: "dateForDay"
      type: "String (YYYY-MM-DD)"
      required: true

outputs:
  description: "생성된 Schedule 객체 및 영구 저장 완료"
  success_criteria:
    - "새로운 Schedule이 UserDefaults에 저장되어야 한다."
    - "앱을 재시작해도 생성한 스케줄이 유지되어야 한다."
    - "생성된 스케줄의 syncStatus가 'pending'으로 설정되어야 한다."

preconditions:
  - "EPIC0-FE-001의 UI 코드가 준비되어 있어야 한다."

postconditions:
  - "Schedule 엔티티가 정의되어 있다."
  - "ScheduleRepository의 기본 구조가 생성되어 있다."
  - "UserDefaults에 JSON 형태로 데이터가 저장된다."
  - "생성된 스케줄의 syncStatus가 pending으로 설정된다."

exceptions:
  - "UserDefaults 저장 실패 시 에러 로그 기록 및 사용자 알림."
  - "JSON 인코딩 실패 시 빈 배열 반환 및 마이그레이션 고려."

config:
  feature_flags: []

tests:
  unit:
    - "Schedule 엔티티의 Codable 동작 테스트"
    - "ScheduleRepository.create() 메서드 단위 테스트"
    - "UserDefaults 저장/로드 정합성 테스트"
  integration:
    - "ViewModel을 통한 생성 플로우 검증"

dependencies: ["EPIC0-FE-001"]
parallelizable: true
estimated_effort: "M"
priority: "Must"
agent_profile: ["mobile_dev"]
required_tools:
  languages: ["Swift"]
  frameworks: ["SwiftUI", "Foundation"]
```

