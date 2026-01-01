# AI 에이전틱 프로그래밍용 풀버전 Task 정의서 작성 계획

## 목적

- SRS(특히 REQ-FUNC/REQ-NF)를 앵커로 하여, **AI 에이전틱 프로그래밍에서 그대로 명령으로 쓸 수 있는 풀버전 Task 정의서**를 작성한다.
- 각 Task(또는 Task 묶음)가 **입력/출력/전제조건/완료조건/제약/참조 문서/의존관계/도구 정보/메타데이터**까지 포함한 구조화된 스펙을 갖도록 한다.
- 최종 산출물은 **사람이 검토하기 쉬운 Human-readable Markdown 문서**를 기본으로 하고, 각 Task 정의에 **머신이 읽기 쉬운 YAML 블록을 포함**하는 형태로 저장한다.

## 단계 1. 기준 합의 – Task 정의 스키마(템플릿)와 사용 시나리오 확정

### 1-1. 공통 원칙

- **Human-readable Markdown + Task별 YAML 블록**을 표준 포맷으로 사용한다.
- 모든 Task 정의는 다음 두 부분으로 구성한다:
  - 사람용 설명 섹션(제목/요약/맥락/설계 노트/리뷰 포인트 등)
  - 머신용 YAML 블록(에이전트가 직접 파싱해서 실행 계획을 세울 수 있는 구조화 데이터)

### 1-2. 기능 요구사항(REQ-FUNC)용 Task 템플릿

- REQ-FUNC 기반 Task 정의는 아래와 같은 Markdown 섹션 구조를 따른다:

#### (예시) REQ-FUNC Task 정의 문서 구조

- 제목: `REQ-FUNC-XXX: <한 줄 요약>`
- 섹션:
  - 목적/요약
  - 관련 REQ/시퀀스/API/엔티티
  - 기능 범위와 비범위(Out of Scope)
  - 입력/출력(개발 관점)
  - 주요 처리 단계(steps_hint)
  - 전제조건/환경(preconditions)
  - 완료조건/DoD(postconditions)
  - 예외/에러 처리
  - 설정/구성(Config/Feature Flags)
  - 테스트 관점(단위/통합/시나리오)
  - 메타데이터 및 주의사항

- 각 REQ-FUNC Task는 다음 YAML 스키마를 따른다(머신용):

```yaml
task_id: "REQ-FUNC-001-BE-01"  # SRS 기반 고유 ID 또는 확장 ID
title: "사용자 회원가입 요청을 처리하는 백엔드 API 구현"  # 사람이 이해할 수 있는 문장
summary: >
  REQ-FUNC-001에 정의된 회원가입 시나리오를 만족하는 백엔드 API 엔드포인트를 구현한다.
  입력 검증, 비밀번호 해시, 중복 검사, 트랜잭션 처리, 감사 로깅까지 포함한다.
type: "functional"  # functional | non_functional

epic: "EPIC_?"            # (선택) 나중에 Epic 설계 시 채움, 초기에는 비워둘 수 있음
feature: "FEAT_?"         # (선택)
req_ids: ["REQ-FUNC-001"] # 필수, SRS REQ-FUNC ID 목록
component: ["backend.api", "user-service"]  # 영향을 받는 컴포넌트 식별자

context:
  srs_section: "3.1.1 회원가입"
  sequence_diagrams: ["SEQ-REGISTER-001"]
  apis: ["/api/v1/users/register"]
  entities: ["User", "Profile"]

inputs:
  description: >
    HTTP POST /api/v1/users/register 요청 바디와 관련 인프라 상태.
  fields:
    - name: "email"
      type: "string"
      required: true
      validation: ["email_format", "max_length:255"]
    - name: "password"
      type: "string"
      required: true
      validation: ["min_length:8", "password_policy_v1"]
  preloaded_state:
    - "데이터베이스 연결이 가능해야 한다."
    - "이메일 중복 검사에 사용할 인덱스가 생성되어 있어야 한다."

outputs:
  description: >
    성공 시 생성된 사용자 ID 및 프로필 기본값, 실패 시 적절한 에러 응답.
  success:
    http_status: 201
    body_example_ref: "SRS-APPENDIX-RESP-001"
  failure_cases:
    - code: "EMAIL_ALREADY_EXISTS"
      http_status: 409
    - code: "INVALID_INPUT"
      http_status: 400

steps_hint:
  - "요청 바디를 파싱하고 스키마 검증을 수행한다."
  - "이메일 중복 여부를 트랜잭션 내에서 검사한다."
  - "비밀번호를 해시 알고리즘(v1)에 따라 해시한다."
  - "User, Profile 엔티티를 생성하고 커밋한다."
  - "성공 응답을 반환하고 감사 로그를 기록한다."

preconditions:
  - "데이터베이스 마이그레이션이 최신 상태이다."
  - "이메일 전송 인프라(Welcome 메일)가 구성되어 있거나 Mock 처리 방침이 합의되어 있다."

postconditions:
  - "새 User 레코드가 영속화되어 있고, 중복 이메일 없이 유일하다."
  - "비밀번호는 평문이 아닌 해시로 저장된다."
  - "감사 로그에 회원가입 시도가 기록된다."

exceptions:
  - "데이터베이스 장애 시 재시도 전략 또는 에러 코드 정의."
  - "외부 이메일 서비스 장애 시 처리 정책(지연 전송/실패 처리) 명시."

config:
  feature_flags:
    - "signup_password_policy_v1"
  env_vars:
    - "EMAIL_SENDER_ADDRESS"

tests:
  unit:
    - "비밀번호 검증 로직에 대한 단위 테스트"
  integration:
    - "DB와 연동되는 회원가입 성공/실패 시나리오 테스트"
  e2e:
    - "프론트엔드 폼 → 백엔드 API → DB까지 연결된 회원가입 플로우 테스트"

dependencies:
  - "TASK-DB-MIGRATION-USER-TABLE"
  - "TASK-EMAIL-SERVICE-CONNECTION"

parallelizable: "conditional"  # true | false | conditional
estimated_effort: "M"          # S | M | L 또는 시간 단위
priority: "Must"               # Must | Should | Could
agent_profile: ["backend"]     # 이 Task에 적합한 에이전트 태그

required_tools:
  languages: ["Java", "Kotlin"]
  frameworks: ["Spring Boot"]
  infra: ["MySQL", "Redis"]

references:
  srs: ["SRS-3.1.1", "SRS-APPENDIX-RESP-001"]
  prd: ["PRD-USR-REG-01"]
  diagrams: ["SEQ-REGISTER-001"]

risk_notes:
  - "중요한 개인정보를 다루므로 보안 및 규제 준수가 필요하다."

example_commands:
  - "이 Task 정의에 따라 REQ-FUNC-001 회원가입 API를 구현해줘."
```

- **작성 방법 가이드(요지)**:
  - `task_id`는 SRS REQ-FUNC ID를 포함하는 규칙적인 포맷을 사용한다.
  - `req_ids`에는 반드시 하나 이상의 REQ-FUNC ID를 명시한다.
  - `inputs`/`outputs`는 SRS/시퀀스/API/엔티티 정의를 그대로 가져오지 말고, **코드/시스템 입장에서 필요한 상태와 데이터**로 재서술한다.
  - `steps_hint`는 구현 절차가 아니라, 에이전트가 세부 구현을 설계할 때 참고할 “핵심 단계”를 나열한다.
  - `preconditions`/`postconditions`는 GWT AC를 참고하되, Task 실행 전/후 시스템 상태를 기준으로 서술한다.
  - `dependencies`에는 이 Task가 착수되기 전에 완료되어야 할 선행 Task ID를 명시한다.

### 1-3. 비기능 요구사항(REQ-NF)용 Task 템플릿

- REQ-NF 기반 Task 정의는 다음과 같은 Markdown + YAML 구조를 따른다.

```yaml
task_id: "REQ-NF-010-LOG-01"
title: "주요 비즈니스 이벤트에 대한 구조화 로깅 구현"
summary: >
  REQ-NF-010(관측성/로깅)에 따라, 주문 생성/결제/취소 등 핵심 도메인 이벤트에 대한
  구조화 로그를 남기고, 로그 수집 파이프라인과 연계한다.
type: "non_functional"  # functional | non_functional

epic: "EPIC_OBSERVABILITY"
feature: "FEAT_LOGGING_CORE"
req_ids: ["REQ-NF-010"]
component: ["backend.api", "order-service", "payment-service"]

category: "logging"  # 성능(performance) | 보안(security) | 운영(operations) | 관측성(observability) | logging | monitoring | alerting | audit 등
labels:
  - "logging:business_events"
  - "observability:core"

context:
  srs_section: "4.2.3 관측성 요구사항"
  related_req_func: ["REQ-FUNC-100", "REQ-FUNC-101"]  # 영향을 받는 기능 요구사항

requirements:
  description: >
    모든 주문 상태 변경 이벤트에 대해, 추적 가능한 ID와 함께 구조화 로그를 남겨야 한다.
  kpis:
    - "주요 비즈니스 이벤트 로그 누락률 0.1% 이하"
    - "로그 인덱싱 지연 1분 이내"

design_constraints:
  - "로그에는 민감한 개인정보(PII)를 직접 포함하지 않는다."
  - "로그 포맷은 JSON으로 통일한다."

implementation_scope:
  includes:
    - "주문 생성/결제/취소 API"
    - "배치 작업에서 발생하는 상태 변경 이벤트"
  excludes:
    - "3rd-party 시스템 로그 통합(별도 Task)"

steps_hint:
  - "로그 스키마(JSON 필드)를 설계하고 문서화한다."
  - "주요 비즈니스 로직 지점에 로깅 훅을 추가한다."
  - "로그 수집/전송/저장 파이프라인과 통합한다."

preconditions:
  - "기본 애플리케이션 로깅 인프라가 구성되어 있다."

postconditions:
  - "정의된 모든 비즈니스 이벤트에서 구조화 로그가 생성된다."
  - "로그 수집 시스템에서 해당 이벤트를 조회할 수 있다."

tests:
  - "샘플 트랜잭션 수행 후, 로그에 예상 필드가 포함되어 있는지 확인한다."
  - "로그 누락/중복 여부를 검증하는 배치 테스트를 수행한다."

dependencies:
  - "TASK-LOG-INFRA-BASE"

parallelizable: true
estimated_effort: "M"
priority: "Should"
agent_profile: ["backend", "infra"]

required_tools:
  languages: ["Java"]
  frameworks: ["Spring Boot"]
  infra: ["ElasticSearch", "Kibana"]

references:
  srs: ["SRS-4.2.3"]
  prd: ["PRD-OBS-01"]

risk_notes:
  - "로그 폭증으로 인한 저장소 비용 증가 가능성"
```

- **작성 방법 가이드(요지)**:
  - `category`/`labels`는 나중에 에이전트 라우팅과 검색에 쓰일 것이므로, 미리 정한 규칙에 따라 일관되게 사용한다.
  - `related_req_func`에는 이 REQ-NF가 직접 영향을 주는 기능 요구사항을 나열한다.
  - `requirements.kpis`에는 측정 가능한 지표를 넣어, 테스트/검증 Task와 자연스럽게 연결되도록 한다.

### 1-4. Task 사용 시나리오(착수~종료 플로우)

- **1단계: FE Prototyping Task 묶음 실행 (Epic 0)**  
  - SRS/PRD 기반으로 대표적인 사용자 플로우를 선정하고, 해당 플로우에 대한 **프론트엔드 프로토타입 Task 묶음**을 정의한다.
  - 이 Task 묶음은 주로 REQ-FUNC의 UI/UX 측면을 다루며, `epic: "EPIC_0_FE_PROTOTYPE"`으로 태깅한다.

- **2단계: 기능 개발 Task 묶음 (REQ-FUNC 단위, 기능 단위 테스트 가능 수준)**  
  - FE 프로토타입 이후, REQ-FUNC별로 기능 단위 테스트가 가능한 규모의 Task 묶음을 정의한다.
  - 각 Task 묶음은 **한 번의 에이전트 실행으로 완료 가능**하도록 설계하며, 각 Task는 위에서 정의한 REQ-FUNC 템플릿을 따른다.

- **3단계: 에이전트 오케스트레이션에서의 사용 규칙**
  - 모든 Task에는 `parallelizable`, `estimated_effort`, `priority`, `agent_profile` 메타데이터를 채운다.
  - 이 메타데이터를 사용해:
    - "지금 실행 가능한 Task들의 집합"을 필터링하는 규칙을 정의한다.
    - "에이전트에게 배정할 Task 큐"를 자동 생성하는 룰을 정의한다.
  - 예:
    - `parallelizable == true`이고, `dependencies`가 모두 완료된 Task만 현재 실행 후보로 선정.
    - `agent_profile`에 따라 FE/BE/Infra/ML 등 전문 에이전트 큐를 분리.

## 단계 2. 표현 포맷/파일 구조 설계 (Markdown + YAML 블록 고정)

- **표준 표현 포맷을 다음과 같이 고정한다**:
  - 사람용 본문: Markdown 섹션 구조(상세 작성 가이드 포함).
  - 머신용 데이터: 각 Task 블록 안에 포함된 YAML 코드 블록.
- 파일 구조:
  - `tasks/functional/REQ-FUNC-XXX.md`  # 기능 요구사항 기반 Task 정의
  - `tasks/non-functional/REQ-NF-XXX.md`  # 비기능 요구사항 기반 Task 정의
- 각 `.md` 파일은 반드시 상단에 사람용 설명 섹션을, 하단에 머신용 Task YAML 블록을 포함하는 두 단계의 구조로 작성한다.

## 단계 3. 프론트엔드 PoC 프로토타이핑을 위한 Task 정의 우선 작성 (Epic 0)

- **대상 범위 선정 (제품 전체 PoC 관점)**
  - PRD 및 SRS 전체 기능(특히 UI를 갖는 REQ-FUNC)을 대상으로, **MVP 범위 내 화면/플로우 전반에 대한 프론트엔드 PoC 프로토타입**을 수행한다.
  - 특정 사용자 플로우 1개가 아니라, 제품 전반을 대표하는 주요 화면/기능 세트를 **넓고 얇게(Breadth-first)** 커버하는 것이 목표다.

- **1단계: PoC FE Prototyping용 Task 헤더(task_id, title) 일괄 추출**
  - SRS/PRD에서 **모든 UI 관련 REQ-FUNC**를 스캔하여, 다음 정보를 가지는 Task 헤더 목록을 작성한다:
    - `task_id`: `EPIC0-FE-XXX` 형태 등, Epic 0을 나타내는 규칙적인 ID
    - `title`: 사람이 읽기 좋은 한 줄 요약(예: "문제정의서 리스트 화면 PoC UI", "JTBD 인터뷰 결과 입력 폼 PoC UI")
  - 이 단계의 목표는, 제품 전반의 화면/상태/플로우를 **PoC 수준으로 한 번에 조망할 수 있는 FE Task 카탈로그(헤더)**를 만드는 것이다.

- **2단계: PoC 수준의 각 Task 상세 정의 작성 (Markdown + YAML)**
  - 단계 1에서 정의한 REQ-FUNC용 템플릿을 사용하되, PoC 특성에 맞게 다음 원칙으로 작성한다:
    - UI 레이아웃/컴포넌트 구조, 주요 상호작용, 기본 검증, Mock/Stub API 연결 정도까지만 요구한다.
    - 스타일·픽셀 퍼펙트 구현, 복잡한 예외 처리 등은 **명시적으로 Out of Scope**로 둔다.
    - PoC 범위임을 `summary` 또는 별도 필드(`poc_level: true` 등)로 명시할 수 있다.
  - 각 Task 정의에는 반드시 머신용 YAML 블록을 포함하고, 최소한 다음 값을 설정한다:
    - `type: "functional"`
    - `agent_profile: ["frontend"]`
    - `epic: "EPIC_0_FE_PROTOTYPE"`

- **3단계: Epic 0 태깅 및 적용 원칙**
  - 프론트엔드 PoC 프로토타입에 속한 모든 Task 묶음에 `epic: "EPIC_0_FE_PROTOTYPE"`을 부여한다.
  - 나중에 제품 전체 Epic 설계 시, Epic 0의 Task를 적절한 Epic으로 재배치하되, **PoC에서 쓰였던 Epic 0 태그는 히스토리로 유지**하여 초기 프로토타입 범위를 추적할 수 있게 한다.

- **검증 포인트**
  - 이 PoC FE Task 정의들만 보고도 에이전트가 **제품 전반의 주요 화면/플로우를 한 번에 훑는 수준의 프로토타입**을 구현할 수 있는지 실제로 실행해 본다.
  - 병렬 실행 가능한 FE Task(화면별/도메인별 등)가 `parallelizable: true`로 명확히 드러나는지 확인한다.
  - 각 Task가 어떤 REQ-FUNC를 부분적으로 충족하는지(`req_ids` 연결)가 명확한지, 그리고 PoC 범위와 Full 구현 범위가 문서 상에서 구분되는지 확인한다.

---

## 단계 4. REQ-FUNC 기반 전체 Task 정의서 확장

- **목표**
  - FE 프로토타입 이후, SRS 상의 전체 REQ-FUNC를 대상으로 기능 개발에 필요한 Task 범위를 본격적으로 추출한다.
  - 여러 개의 AI 에이전트를 병렬로 활용하여 실제 개발을 수행할 수 있도록, Task를 적절한 크기와 메타데이터로 정의한다.

- **절차**
  - SRS 상에서 MVP 범위에 포함된 모든 `REQ-FUNC` ID 목록을 정리한다.
  - 각 `REQ-FUNC`별로 단계 0에서 정의한 REQ-FUNC Task 템플릿을 사용하여, 다음 관점에서 세부 구현 Task를 도출한다:
    - Input/상태 준비
    - 핵심 처리 로직(Process)
    - Output/저장/외부 시스템 연동
    - 예외/에러 처리
    - 설정/환경/Feature Flag
    - 테스트(단위/통합/시나리오)
  - 도출된 각 Task에 대해 템플릿을 채우고, 해당 `REQ-FUNC` ID를 `req_ids` 필드에 연결한다.
  - Task 크기 기준:
    - 하나의 Task 묶음(여러 Task)을 한 번의 에이전트 실행으로 완료할 수 있도록 구성한다.
    - 기능 단위 테스트가 가능한 정도의 범위를 1 묶음으로 본다.

- **에이전트 병렬 실행 고려**
  - 각 Task에 대해 `parallelizable`, `dependencies`, `agent_profile`을 반드시 설정한다.
  - 병렬 실행이 가능한 Task들은 서로 의존성이 없거나, 읽기 전용 리소스를 공유하는 Task로 제한한다.
  - `agent_profile`을 활용해 FE/BE/Infra/ML 등 전문 에이전트 큐를 분리할 수 있도록 설계한다.

---

## 단계 5. REQ-NF 및 횡단 관심사 기반 Task 정의서 확장 (카테고리/레이블 지정)

- **REQ-NF 목록화 및 연결**
  - SRS 상의 `REQ-NF`(성능, 보안, 운영, 관측성 등)를 모두 목록화한다.
  - 각 REQ-NF가 어떤 REQ-FUNC, 컴포넌트, 사용자 플로우에 영향을 주는지 식별한다.

- **카테고리 및 레이블 스킴 정의**
  - `category` 필드 예시:
    - `"performance"`: 응답시간, 처리량, 지연, 자원 사용량 등
    - `"security"`: 인증/인가, 데이터 보호, 감사, 규제 준수 등
    - `"operations"`: 배포, 롤백, 장애 대응, 런북 등
    - `"observability"`: 로깅, 모니터링, 트레이싱, 메트릭 등
    - `"logging"`: 애플리케이션/비즈니스 로그 구조화
    - `"monitoring"`: 대시보드, 알람 룰, SLO/SLI
    - `"alerting"`: 알림 채널, 온콜 룰
  - `labels` 필드 예시:
    - `"logging:business_events"`, `"logging:access"`, `"logging:error"`
    - `"monitoring:infrastructure"`, `"monitoring:application"`
    - `"alerting:oncall_critical"`, `"alerting:warning"`
    - `"security:auth"`, `"security:encryption"`, `"security:audit"`
    - `"performance:latency"`, `"performance:throughput"`

- **Task 정의**
  - 단계 0에서 정의한 REQ-NF용 템플릿을 사용하여, 각 REQ-NF에 대한 구현/검증 Task를 정의한다.
  - 기능 요구사항과 직접 연결되는 경우:
    - `related_req_func` 필드에 영향을 받는 REQ-FUNC ID를 명시한다.
  - 로깅/모니터링/알림 등 횡단 관심사의 경우:
    - `category`/`labels`를 활용해 공통 Task를 묶어 관리한다.
  - 모든 REQ-NF Task에도 REQ-FUNC와 동일하게 Markdown + YAML 구조를 적용한다.

---

## 단계 6. 품질 점검 및 샘플 에이전트 실행 테스트

- **스키마 충족 여부 점검**
  - 모든 Task 정의가 단계 0에서 정한 템플릿 구조를 충족하는지 확인한다.
  - 필수 필드(`task_id`, `title`, `type`, `req_ids`, `postconditions`, `dependencies`, `agent_profile` 등)가 비어 있지 않은지 확인한다.
  - Human-readable 섹션과 YAML 블록 간 내용 불일치가 없는지 점검한다.

- **SRS/PRD 연계 점검**
  - 모든 Task가 최소 하나 이상의 `req_ids`(REQ-FUNC 또는 REQ-NF)를 가진다.
  - PRD-SRS-Task 간 ID 매핑이 누락되거나 중복되지 않았는지 확인한다.

- **에이전트 실행 관점 점검**
  - `parallelizable`, `estimated_effort`, `priority`, `agent_profile` 값이 정의 규칙에 맞게 일관되게 채워져 있는지 점검한다.
  - 주요 사용자 플로우에 대해,  
    FE 프로토타입(Task Epic 0) → 기능 구현(Task REQ-FUNC) → NFR(Task REQ-NF)이 자연스럽게 연결되는지 확인한다.

---

## 단계 7. PRD-SRS-Task 3단계 변경사항 싱크 및 버전관리 전략

- **3단계 구조**
  - 1단계: PRD (제품 요구/유저 스토리)
  - 2단계: SRS (REQ-FUNC/REQ-NF)
  - 3단계: Task 정의서 (Markdown + YAML)

- **변경 발생 지점별 싱크 전략**
  - PRD 변경 시:
    - 영향 받는 SRS REQ를 식별하고 갱신한다.
    - 해당 REQ에 연결된 Task들의 `req_ids`, `summary`, `postconditions`를 검토/갱신한다.
  - SRS 변경 시:
    - 변경된 REQ-FUNC/REQ-NF ID 및 내용에 매핑된 Task 목록을 조회한다.
    - Task의 `inputs`/`outputs`/`steps_hint`/`tests`를 재검토하고 필요 시 수정한다.
  - Task 변경 시:
    - Task 변경 사유가 PRD/SRS 변경인지, 구현 수준 최적화인지 구분한다.
    - PRD/SRS에 반영이 필요한 경우, 상위 문서 변경 프로세스를 트리거한다.

- **버전 관리 전략**
  - PRD, SRS, Task 카탈로그 각각에 버전 ID를 부여하고, 상호 매핑을 유지한다.
    - 예: `PRD-v1.2`, `SRS-v1.1`, `TASK-CATALOG-v1.0`
  - 릴리즈 단위로 “사용 중인 버전 조합”을 명시한다.
  - 변경 로그에는 **어느 레벨(PRD/SRS/Task)에서 어떤 변경이 있었는지**와,  
    하위 레벨에 미친 영향 범위를 함께 기록한다.
  - AI 에이전틱 프로그래밍 시스템에서 Task 정의서의 버전·캐시 정책을 어떻게 운영할지(정기 리로드/수동 리프레시/알림 기반 리로드 등)를 명시한다.

---

## 단계 8. AI 에이전트용 Task 정의서 활용 가이드 작성

- **산출물**
  - `docs/AI_AGENT_TASKS_USAGE_GUIDE.md` 파일을 작성한다.

- **가이드에 포함할 내용**
  - Task 정의서의 기본 구조(Human-readable 섹션 + YAML 블록)와 각 필드의 의미.
  - 통합 Task Tree(WBS)와 의존성 그래프(DAG)의 해석 및 활용 방법:
    - WBS 레벨 구조(Epic → Feature → REQ-FUNC/REQ-NF → 컴포넌트별 구현/테스트 Task)를 어떻게 읽고, 특정 Epic/Feature/REQ 단위로 작업 범위를 필터링·집계하는지.
    - WBS를 기준으로 “어떤 REQ-FUNC/REQ-NF에 대해 어떤 컴포넌트 Task가 이미 정의/완료되었는지”, “누락된 Task는 무엇인지”를 점검하는 방법.
    - DAG에서 `A --> B`가 “A가 선행, B가 후행”을 의미함을 명시하고, `DB → Backend → Engine/외부 시스템 → API → Frontend → E2E Test` / `템플릿·룰셋 설계 → 구현 → 모니터링·알림 설정 → 성능·품질 검증`과 같은 계층 예시를 들어 해석 방법을 설명.
    - DAG를 사용해 현재 착수 가능한 Task 집합(모든 `dependencies`가 완료된 노드), 병렬 실행 가능 영역, 크리티컬 패스를 계산하여 스프린트 계획·릴리즈 계획에 반영하는 방법.
    - Mermaid Graph 등으로 시각화된 WBS/DAG를 에이전트 오케스트레이터가 참고하여 Task 선택·우선순위 조정·진행 상태 업데이트를 수행하는 방법.
  - 에이전트에게 Task를 줄 때:
    - 어떤 YAML 필드를 그대로 넘기는지,
    - 어떤 Human-readable 설명을 프롬프트에 포함하는지,
    - 병렬 실행/우선순위/에이전트 타입을 어떻게 결정하는지.
  - 일반적인 사용 패턴 예시:
    - “단일 Task를 에이전트에게 던져 구현시키는” 시나리오
    - “여러 Task를 병렬 실행하는” 시나리오
    - “선후행 의존관계를 고려해 플로우를 실행하는” 시나리오을
  - 에이전트 실행 결과를 다시 Task 정의서 개선에 피드백하는 루프(템플릿/가이드 지속 개선 프로세스).

---

### To-dos

- [ ] 기능/비기능 요구사항을 모두 커버하는 REQ-FUNC/REQ-NF Task 템플릿(Markdown + YAML)을 단계 1 스펙에 맞게 확정한다.  <!-- 단계 1 -->
- [ ] Task 메타데이터(`parallelizable`, `estimated_effort`, `priority`, `agent_profile` 등)의 값 체계와 사용 규칙을 정의한다.  <!-- 단계 1 -->
- [ ] 단계 2에서 정의한 표준 파일 구조(`tasks/functional`, `tasks/non-functional` 등)에 따라, 실제 리포지토리 내 디렉토리/파일 레이아웃을 생성하고 정리한다.  <!-- 단계 2 -->
- [ ] PRD/SRS 전체 기능 중 MVP 범위에서 PoC 프론트엔드 프로토타입 대상 화면/플로우 집합을 정의하고, Epic 0 Task 헤더(`task_id`, `title`) 목록을 작성한다.  <!-- 단계 3 -->
- [ ] Epic 0 Task 헤더를 기반으로, 각 Task의 상세 정의(Template 채우기)를 완료한다.  <!-- 단계 3 -->
- [ ] SRS 상의 MVP 범위 REQ-FUNC 목록을 정리하고, 각 REQ-FUNC별로 Task 정의를 단계 4 템플릿에 따라 작성한다.  <!-- 단계 4 -->
- [ ] SRS 상의 REQ-NF 및 횡단 관심사를 목록화하고, 카테고리/레이블 스킴에 따라 Task를 정의한다.  <!-- 단계 5 -->
- [ ] 정의된 모든 Task에 대해 품질 점검(단계 6 기준)을 수행하고, 최소 1개 이상의 Task 묶음을 실제 에이전트에게 실행해본다.  <!-- 단계 6 -->
- [ ] PRD-SRS-Task 3단계 싱크 및 버전관리 전략(단계 7)을 문서화하고, 실제 변경 플로우에 적용한다.  <!-- 단계 7 -->
- [ ] `docs/AI_AGENT_TASKS_USAGE_GUIDE.md`를 작성하여, 에이전트 오케스트레이션 담당자와 개발자가 Task 정의서를 일관되게 활용할 수 있도록 한다.  <!-- 단계 8 -->