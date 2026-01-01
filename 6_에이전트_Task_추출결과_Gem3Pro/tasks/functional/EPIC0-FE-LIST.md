# Epic 0: 프론트엔드 PoC Task 목록

이 문서는 **Unwind** 앱의 핵심 사용자 흐름을 빠르게 검증하기 위한 **프론트엔드 PoC(Proof of Concept)** Task 목록을 정의합니다.
이 단계의 목표는 백엔드 연동 없이(Mock/Stub 활용), 주요 화면의 UI 레이아웃과 기본 인터랙션을 구현하여 UX를 검증하는 것입니다.

## Task List

| Task ID | Title | 관련 Story | Agent Profile |
|---------|-------|------------|---------------|
| **EPIC0-FE-001** | 스케줄 홈 및 CRUD UI 프로토타입 | Story 1 | `frontend` |
| **EPIC0-FE-002** | 집중 모드 실행 및 Shield 화면 시뮬레이션 | Story 2, 3 | `frontend` |
| **EPIC0-FE-003** | 설정, 인증 및 페널티 UI 프로토타입 | Story 4, 5, Auth | `frontend` |
| **EPIC0-FE-004** | 통계 대시보드 및 스트릭 UI | Story 6 | `frontend` |

## 공통 제약사항 (PoC)

- **디자인**: iOS Human Interface Guidelines를 준수하는 기본 SwiftUI 컴포넌트 사용 (별도 디자인 시스템 구축 불필요).
- **데이터**: 로컬 상태(`@State`, `ObservableObject`)에 하드코딩된 Mock 데이터를 사용하여 동작.
- **범위**:
  - Screen Time API 실제 연동 제외 (로그/Print로 대체).
  - 서버 API 연동 제외.
  - 정교한 에러 처리 제외.

