import Foundation

/// 스케줄 동기화 상태를 정의합니다.
enum SyncStatus: String, Codable {
    /// 서버와 동기화 대기 중 (신규 생성 또는 수정됨)
    case pending
    /// 서버와 동기화 완료
    case synced
}

/// 스케줄 데이터를 나타내는 모델입니다.
struct Schedule: Identifiable, Codable {
    /// 스케줄의 고유 식별자 (UUID)
    let id: UUID
    /// 스케줄 이름
    var name: String
    /// 집중 시간 (초 단위)
    var durationSeconds: Int
    /// 생성 일시
    let createdAt: Date
    /// 수정 일시
    var updatedAt: Date
    /// 동기화 상태
    var syncStatus: SyncStatus
    /// 완료 여부
    var isCompleted: Bool
    /// 삭제 일시 (Soft Delete용)
    var deletedAt: Date?

    init(id: UUID = UUID(), name: String, durationSeconds: Int, syncStatus: SyncStatus = .pending) {
        self.id = id
        self.name = name
        self.durationSeconds = durationSeconds
        self.createdAt = Date()
        self.updatedAt = Date()
        self.syncStatus = syncStatus
        self.isCompleted = false
        self.deletedAt = nil
    }
}
