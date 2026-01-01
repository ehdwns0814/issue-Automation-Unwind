# AI 에이전트용 Task 정의서 활용 가이드

## 1. 개요

본 문서는 **Unwind** 프로젝트의 AI 에이전틱 프로그래밍을 위해 정의된 "Task 정의서"의 구조와 활용 방법을 설명합니다.
모든 Task는 **Human-readable Markdown** 설명과 **Machine-readable YAML** 데이터 블록으로 구성되어 있어, 사람과 AI 에이전트가 모두 이해하고 실행할 수 있도록 설계되었습니다.

## 2. Task 정의서 구조

각 Task 파일(`*.md`)은 다음과 같은 표준 구조를 따릅니다.

### 2.1 사람용 설명 섹션 (Markdown)
문서 상단에는 사람이 읽고 검토할 수 있는 상세 설명이 포함됩니다.
- **Title**: Task의 목적을 한 문장으로 요약
- **Summary**: 작업 범위와 목표 상세 서술
- **Context**: 관련 SRS 요구사항, 시퀀스 다이어그램, API 참조
- **Steps Hint**: 구현을 위한 핵심 단계 제안 (AI에게 주는 힌트)
- **Requirements/Constraints**: 기능적/비기능적 제약사항

### 2.2 머신용 데이터 블록 (YAML)
문서 하단에는 AI 에이전트가 파싱하여 실행 계획을 수립하는 데 사용하는 YAML 블록이 포함됩니다.

```yaml
task_id: "REQ-FUNC-001-CRUD"  # 고유 식별자
type: "functional"            # functional | non_functional
epic: "EPIC_1_SCHEDULE"       # 상위 Epic
req_ids: ["REQ-FUNC-001"]     # SRS 요구사항 매핑
agent_profile: ["backend"]    # 실행에 적합한 에이전트 타입
parallelizable: true          # 병렬 실행 가능 여부
dependencies: []              # 선행 Task ID 목록
# ... (상세 필드)
```

## 3. Task 활용 프로세스

### 3.1 워크플로우 (WBS/DAG)
전체 프로젝트는 다음과 같은 계층 구조로 관리됩니다.

1. **Epic 0 (Prototyping)**: 프론트엔드 PoC (Breadth-first)
2. **Feature Development**: REQ-FUNC 단위 기능 구현 (Depth-first)
3. **Non-Functional**: 성능, 보안, 운영 등 횡단 관심사 적용

### 3.2 에이전트 오케스트레이션 가이드

오케스트레이터(User 또는 Master Agent)는 다음 규칙에 따라 Task를 배정합니다.

1. **Filtering**: `dependencies`가 모두 완료된 Task만 "Ready" 상태로 간주합니다.
2. **Routing**: `agent_profile` 태그를 확인하여 적절한 에이전트(Frontend, Backend, Infra 등)에게 작업을 할당합니다.
3. **Execution**:
    - `parallelizable: true`인 Task는 동시에 여러 에이전트에게 할당할 수 있습니다.
    - 프롬프트 작성 시, Markdown 본문의 **Context**와 **Steps Hint**를 포함하여 에이전트가 문맥을 파악하게 합니다.
    - YAML의 `inputs`/`outputs` 정의를 통해 명확한 입출력 규격을 준수시킵니다.

### 3.3 검증 및 피드백
- **Postconditions Check**: Task 완료 후, 정의된 `postconditions`를 만족하는지 검증합니다.
- **Status Update**: 완료된 `task_id`를 추적하여 후행 Task의 의존성을 해소합니다.

## 4. 버전 관리 및 싱크

- **PRD/SRS 변경 시**: 영향을 받는 `req_ids`를 가진 Task를 식별하여 내용을 갱신해야 합니다.
- **Task 파일 위치**:
  - 기능 요구사항: `tasks/functional/`
  - 비기능 요구사항: `tasks/non-functional/`

