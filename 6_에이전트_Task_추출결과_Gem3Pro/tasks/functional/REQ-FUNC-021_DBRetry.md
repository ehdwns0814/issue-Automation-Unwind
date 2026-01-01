# REQ-FUNC-021: 데이터베이스 쓰기 실패 재시도 UI 구현

## 1. 개요
로컬 또는 서버 저장 중 오류가 발생했을 때 사용자에게 재시도 옵션을 제공하는 에러 처리 UI를 구현합니다.

## 2. 관련 요구사항
- **REQ-FUNC-021**: 시스템은 데이터베이스 쓰기 실패 시 재시도 옵션을 제공해야 함

## 3. 기능 범위
- **에러 감지**: UserDefaults 저장 실패 또는 네트워크 요청 실패 감지.
- **재시도 팝업**: "저장 실패. 다시 시도하시겠습니까?" Alert 표시.
- **재시도 로직**: 사용자가 "재시도" 선택 시 저장 작업 재실행.

## 4. 구현 가이드 (Steps Hint)
1. **에러 핸들링**:
   - `ScheduleRepository`의 저장 메서드에서 `try-catch` 블록으로 에러 캐치.
   - 에러 발생 시 `ErrorManager` 또는 `@Published var errorMessage`에 에러 저장.
2. **재시도 팝업**:
   - SwiftUI의 `.alert` 모디파이어 사용.
   - "취소"와 "재시도" 버튼 제공.
3. **재시도 로직**:
   - "재시도" 버튼 탭 시 실패한 작업을 다시 실행.
   - 최대 재시도 횟수 제한 (예: 3회).

## 5. 예외 처리
- 재시도 횟수 초과 시 "저장에 실패했습니다. 나중에 다시 시도해주세요." 메시지 표시.

---

```yaml
task_id: "REQ-FUNC-021"
title: "데이터베이스 쓰기 실패 재시도 UI 구현"
summary: >
  로컬 또는 서버 저장 중 오류가 발생했을 때 사용자에게 재시도 옵션을 제공하는
  에러 처리 UI를 구현한다.
type: "functional"
epic: "EPIC_8_STABILITY"
req_ids: ["REQ-FUNC-021"]
component: ["mobile.ios.ui", "mobile.ios.error"]

context:
  srs_section: "4.1 기능 요구사항 예외 처리"
  acceptance_criteria: >
    Given 로컬/서버 저장 중 오류 발생 시
    When 오류가 감지되면
    Then "저장 실패. 다시 시도하시겠습니까?" 팝업 표시

inputs:
  description: "저장 작업 실패 이벤트"
  error_types:
    - "UserDefaults 저장 실패"
    - "네트워크 요청 실패"

outputs:
  description: "재시도 팝업 및 재시도 실행"
  success_criteria:
    - "저장 실패 시 재시도 팝업이 표시되어야 한다."
    - "재시도 버튼 탭 시 저장 작업이 다시 실행되어야 한다."

preconditions:
  - "기본 저장 기능이 구현되어 있어야 한다."

postconditions:
  - "에러 핸들링 로직이 추가되어 있다."
  - "재시도 UI가 통합되어 있다."

exceptions:
  - "재시도 횟수 초과 시 최종 실패 메시지 표시."

config:
  feature_flags: []

tests:
  unit:
    - "에러 감지 로직 테스트"
    - "재시도 로직 테스트"
  manual:
    - "의도적으로 저장 실패를 유도하여 재시도 팝업 확인."

dependencies: ["REQ-FUNC-001"]
parallelizable: true
estimated_effort: "S"
priority: "Should"
agent_profile: ["mobile_dev"]
required_tools:
  languages: ["Swift"]
  frameworks: ["SwiftUI"]
```

