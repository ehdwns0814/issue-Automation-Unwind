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
    /// 스케줄의 상태를 정의합니다.
    enum Status: String, Codable {
        /// 대기 중
        case pending
        /// 완료됨
        case completed
        /// 중단/실패함
        case failed
    }

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
    /// 완료 또는 중단 시각
    var completedAt: Date?
    /// 동기화 상태
    var syncStatus: SyncStatus
    /// 완료 여부 (기존 호환성 및 DB 필드용)
    var isCompleted: Bool
    /// 현재 상태
    var status: Status
    /// 삭제 일시 (Soft Delete용)
    var deletedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, name, durationSeconds, createdAt, updatedAt, completedAt, syncStatus, isCompleted, status, deletedAt
    }

    init(id: UUID = UUID(), 
         name: String, 
         durationSeconds: Int, 
         syncStatus: SyncStatus = .pending, 
         status: Status = .pending) {
        self.id = id
        self.name = name
        self.durationSeconds = durationSeconds
        self.createdAt = Date()
        self.updatedAt = Date()
        self.completedAt = nil
        self.syncStatus = syncStatus
        self.status = status
        self.isCompleted = (status == .completed)
        self.deletedAt = nil
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        durationSeconds = try container.decode(Int.self, forKey: .durationSeconds)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        completedAt = try container.decodeIfPresent(Date.self, forKey: .completedAt)
        syncStatus = try container.decode(SyncStatus.self, forKey: .syncStatus)
        isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
        
        // status 필드가 없을 경우 isCompleted 값에 따라 기본값 설정 (Migration)
        if let decodedStatus = try container.decodeIfPresent(Status.self, forKey: .status) {
            status = decodedStatus
        } else {
            status = isCompleted ? .completed : .pending
        }
        
        deletedAt = try container.decodeIfPresent(Date.self, forKey: .deletedAt)
    }
}
