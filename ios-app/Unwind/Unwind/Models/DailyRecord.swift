import Foundation

/// 일별 기록 상태를 정의합니다.
enum DailyStatus: String, Codable {
    /// 성공 (모든 스케줄 완료)
    case success
    /// 실패 (올인 모드 중도 포기 등)
    case failure
    /// 경고 (일부 미완료)
    case warning
    /// 계획 없음
    case noPlan = "noplan"
}

/// 날짜별 집중 기록을 나타내는 모델입니다.
struct DailyRecord: Codable {
    /// 기록 날짜 (YYYY-MM-DD 형식의 문자열을 Key로 사용하기 위해)
    let date: String
    /// 오늘의 상태
    var status: DailyStatus
    /// 전체 스케줄 수
    var totalSchedules: Int
    /// 완료된 스케줄 수
    var completedSchedules: Int
    /// 올인 모드 사용 여부
    var allInModeUsed: Bool
    /// 서버 동기화 상태
    var syncStatus: SyncStatus
    
    init(date: String, 
         status: DailyStatus = .noPlan, 
         totalSchedules: Int = 0, 
         completedSchedules: Int = 0, 
         allInModeUsed: Bool = false, 
         syncStatus: SyncStatus = .pending) {
        self.date = date
        self.status = status
        self.totalSchedules = totalSchedules
        self.completedSchedules = completedSchedules
        self.allInModeUsed = allInModeUsed
        self.syncStatus = syncStatus
    }
}

