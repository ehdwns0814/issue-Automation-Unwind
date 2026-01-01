# REQ-FUNC-024: 사용자 회원가입 백엔드 API 구현

## 1. 개요
Spring Boot 기반의 회원가입 API를 구현합니다. JWT를 사용하여 인증 상태를 관리하며, 비밀번호는 BCrypt로 암호화하여 저장합니다.

## 2. 관련 요구사항
- **REQ-FUNC-024**: 시스템은 사용자 회원가입 기능을 제공해야 함

## 3. 기능 범위
- **Entity**: `User` 엔티티 정의 (id, email, passwordHash, createdAt, lastLoginAt).
- **Controller**: `POST /api/auth/signup` 엔드포인트 구현.
- **Service**: `AuthService`의 회원가입 로직 구현 (중복 검사, 비밀번호 해시).
- **DTO**: `SignupRequest`, `SignupResponse` DTO 정의.

## 4. 구현 가이드 (Steps Hint)
1. **프로젝트 설정**:
   - Spring Boot 3.x, Spring Security, Spring Data JPA, MySQL/H2 설정.
   - JWT 라이브러리 추가 (예: `io.jsonwebtoken:jjwt`).
2. **Domain 설계**:
   - `User` 엔티티 생성: `@Entity`, `@Table(name = "users")`.
   - `UserRepository` 인터페이스 생성 (`JpaRepository<User, Long>`).
3. **Security 설정**:
   - `SecurityFilterChain` 빈 등록.
   - `/api/auth/**`는 `permitAll()`, 그 외는 `authenticated()`.
4. **회원가입 로직**:
   - 이메일 중복 검사: `userRepository.findByEmail(email)`.
   - 비밀번호 해시: `BCryptPasswordEncoder.encode(password)`.
   - User 엔티티 저장 및 JWT 토큰 발급.
5. **응답**:
   - 성공 시: `201 Created`, `{ userId, token }`.
   - 실패 시: `409 Conflict` (이메일 중복), `400 Bad Request` (입력 검증 실패).

## 5. 예외 처리
- `EmailAlreadyExistsException` (409 Conflict).
- `InvalidInputException` (400 Bad Request).

---

```yaml
task_id: "REQ-FUNC-024"
title: "JWT 기반 회원가입 API 백엔드 구현"
summary: >
  Spring Security와 JWT를 사용하여 안전한 회원가입 API를 구현한다.
  이메일 중복 검사, 비밀번호 해시, 토큰 발급까지 포함한다.
type: "functional"
epic: "EPIC_5_AUTH"
req_ids: ["REQ-FUNC-024"]
component: ["backend.api", "backend.security"]

context:
  srs_section: "4.1 기능 요구사항 인증 & 부록 A.2 API"
  api_spec:
    - "POST /api/auth/signup"
  acceptance_criteria: >
    Given 신규 사용자가 앱을 처음 실행할 때
    When 회원가입 화면에서 이메일/비밀번호 입력하면
    Then 서버에 계정 생성 및 자동 로그인 처리

inputs:
  description: "회원가입 요청 DTO"
  fields:
    - name: "email"
      type: "email"
      required: true
      validation: ["email_format", "max_length:255"]
    - name: "password"
      type: "string"
      required: true
      validation: ["min_length:8"]

outputs:
  description: "JWT 토큰 및 사용자 정보"
  success_criteria:
    - "회원가입 성공 시 201 Created 응답과 함께 토큰이 발급되어야 한다."
    - "이메일 중복 시 409 Conflict 응답이 반환되어야 한다."
    - "비밀번호가 해시되어 저장되어야 한다."

preconditions:
  - "DB 스키마(User 테이블)가 정의되어 있어야 한다."
  - "Spring Boot 프로젝트가 설정되어 있어야 한다."

postconditions:
  - "User 테이블에 새 레코드가 암호화된 비번으로 저장된다."
  - "JWT 토큰이 발급되어 클라이언트에 반환된다."

exceptions:
  - "EmailAlreadyExistsException (409 Conflict)."
  - "InvalidInputException (400 Bad Request)."

config:
  feature_flags: []

tests:
  unit:
    - "AuthService 회원가입 로직 단위 테스트 (Mock Repository)"
    - "비밀번호 해시 검증 테스트"
  integration:
    - "MockMvc를 이용한 API 엔드포인트 테스트"
    - "이메일 중복 검사 테스트"

dependencies: []
parallelizable: true
estimated_effort: "M"
priority: "Must"
agent_profile: ["backend_dev"]
required_tools:
  languages: ["Java" or "Kotlin"]
  frameworks: ["Spring Boot", "Spring Security", "Spring Data JPA"]
```

