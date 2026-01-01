# REQ-NF-008: 보안 및 데이터 프라이버시

## 1. 개요
사용자의 개인정보(스케줄 내용)와 민감한 권한 데이터(Screen Time)를 안전하게 처리하기 위한 보안 조치를 적용합니다.

## 2. 관련 요구사항
- **REQ-NF-008**: 로컬 데이터 저장 (비식별화 필요 여부 검토)
- **REQ-NF-009**: Screen Time 권한 데이터 외부 전송 금지
- **REQ-NF-010**: 전송 구간 암호화 (HTTPS)

## 3. 구현/검증 가이드
- **App Transport Security (ATS)**: `Info.plist`에서 예외 없는 HTTPS 강제 설정 확인.
- **Local Storage**: `UserDefaults`에는 민감 정보(비밀번호 등) 저장 금지. 필요 시 Keychain 사용.
- **Data Minimization**: 서버 전송 시 꼭 필요한 필드만 DTO에 포함.
- **Code Review**: `DeviceActivity` 관련 코드가 외부 서버로 불필요한 데이터를 보내지 않는지 점검.

---

```yaml
task_id: "REQ-NF-008-SEC"
title: "데이터 보안 및 프라이버시 규정 준수 검증"
summary: >
  HTTPS 통신 강제, 민감 데이터의 Keychain 저장, 최소 데이터 수집 원칙을 적용하여
  보안 취약점을 제거하고 사용자 프라이버시를 보호한다.
type: "non_functional"
epic: "EPIC_NON_FUNC_SEC"
req_ids: ["REQ-NF-008", "REQ-NF-009", "REQ-NF-010"]
component: ["mobile.ios.security", "backend.infra"]

category: "security"
labels: ["security:privacy", "security:encryption"]

context:
  srs_section: "4.2 비기능 요구사항 보안"

requirements:
  description: "개인정보 유출 방지 및 플랫폼 정책 준수"
  kpis:
    - "취약점 스캔(Static Analysis) Critical Issue 0건"

implementation_scope:
  includes:
    - "Network Config (ATS)"
    - "Storage Logic"
    - "API DTO Design"

steps_hint:
  - "MobiSF 등의 툴을 이용해 IPA 정적 분석 수행."
  - "네트워크 패킷 캡처를 통해 평문 전송 여부 확인."

preconditions:
  - "기능 구현 완료 상태."

tests:
  - "Wireshark/Charles Proxy로 HTTPS 암호화 검증."

dependencies: []
parallelizable: true
estimated_effort: "S"
priority: "Must"
agent_profile: ["security_audit"]
required_tools:
  frameworks: ["Security"]
```

