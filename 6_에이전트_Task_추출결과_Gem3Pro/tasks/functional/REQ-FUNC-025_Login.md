# REQ-FUNC-025: 사용자 로그인 백엔드 API 구현

## 1. 개요
Spring Boot 기반의 로그인 API를 구현합니다. 이메일과 비밀번호를 검증하고 JWT 토큰을 발급합니다.

## 2. 관련 요구사항
- **REQ-FUNC-025**: 시스템은 사용자 로그인 기능을 제공해야 함

## 3. 기능 범위
- **Controller**: `POST /api/auth/login` 엔드포인트 구현.
- **Service**: `AuthService`의 로그인 로직 구현 (이메일 조회, 비밀번호 검증, 토큰 발급).
- **DTO**: `LoginRequest`, `LoginResponse` DTO 정의.
- **토큰 갱신**: `lastLoginAt` 업데이트.

## 4. 구현 가이드 (Steps Hint)
1. **로그인 엔드포인트**:
   - `POST /api/auth/login` 구현.
   - 요청 바디: `{ email, password }`.
2. **인증 로직**:
   - `userRepository.findByEmail(email)`로 사용자 조회.
   - 사용자가 없으면 `InvalidCredentialsException` (401).
   - `BCryptPasswordEncoder.matches(password, user.passwordHash)`로 비밀번호 검증.
   - 검증 실패 시 `InvalidCredentialsException` (401).
3. **토큰 발급**:
   - Access Token (1시간) 및 Refresh Token (2주) 생성.
   - JWT Utils를 사용하여 토큰 생성.
4. **응답**:
   - 성공 시: `200 OK`, `{ userId, accessToken, refreshToken }`.
   - 실패 시: `401 Unauthorized`.

## 5. 예외 처리
- `InvalidCredentialsException` (401 Unauthorized).

---

```yaml
task_id: "REQ-FUNC-025"
title: "JWT 기반 로그인 API 백엔드 구현"
summary: >
  이메일과 비밀번호를 검증하고 JWT 토큰을 발급하는 로그인 API를 구현한다.
type: "functional"
epic: "EPIC_5_AUTH"
req_ids: ["REQ-FUNC-025"]
component: ["backend.api", "backend.security"]

context:
  srs_section: "4.1 기능 요구사항 인증 & 부록 A.2 API"
  api_spec:
    - "POST /api/auth/login"
  acceptance_criteria: >
    Given 기존 사용자가 앱을 실행할 때
    When 로그인 화면에서 이메일/비밀번호 입력하면
    Then 서버 인증 후 액세스 토큰 발급 및 저장

inputs:
  description: "로그인 요청 DTO"
  fields:
    - name: "email"
      type: "email"
      required: true
    - name: "password"
      type: "string"
      required: true

outputs:
  description: "JWT 토큰 및 사용자 정보"
  success_criteria:
    - "로그인 성공 시 200 OK 응답과 함께 토큰이 발급되어야 한다."
    - "유효하지 않은 자격증명 시 401 Unauthorized 응답이 반환되어야 한다."
    - "lastLoginAt이 업데이트되어야 한다."

preconditions:
  - "REQ-FUNC-024이 완료되어 User 엔티티와 Repository가 존재해야 한다."

postconditions:
  - "JWT 토큰이 발급되어 클라이언트에 반환된다."
  - "User의 lastLoginAt이 업데이트된다."

exceptions:
  - "InvalidCredentialsException (401 Unauthorized)."

config:
  feature_flags: []

tests:
  unit:
    - "AuthService 로그인 로직 단위 테스트"
    - "비밀번호 검증 로직 테스트"
  integration:
    - "MockMvc를 이용한 로그인 API 테스트"
    - "잘못된 자격증명 테스트"

dependencies: ["REQ-FUNC-024"]
parallelizable: false
estimated_effort: "M"
priority: "Must"
agent_profile: ["backend_dev"]
required_tools:
  languages: ["Java" or "Kotlin"]
  frameworks: ["Spring Boot", "Spring Security"]
```

