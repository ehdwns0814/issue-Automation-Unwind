import Foundation

/// 스케줄 데이터를 로컬 저장소(UserDefaults)에 관리하는 저장소 클래스입니다.
class ScheduleRepository: ObservableObject {
    static let shared = ScheduleRepository()
    
    private let storageKey = "com.unwind.schedules"
    private let dailyRecordsKey = "unwind_daily_records"
    
    @Published var schedules: [Schedule] = []
    @Published var dailyRecords: [String: DailyRecord] = [:]
    
    private init() {
        loadSchedules()
        loadDailyRecords()
    }
    
    /// 로컬 저장소에서 스케줄 목록을 불러옵니다.
    func loadSchedules() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            self.schedules = []
            return
        }
        
        do {
            let decoded = try JSONDecoder().decode([Schedule].self, from: data)
            self.schedules = decoded
        } catch {
            print("Failed to decode schedules: \(error)")
            self.schedules = []
        }
    }
    
    /// 로컬 저장소에서 일별 기록을 불러옵니다.
    func loadDailyRecords() {
        guard let data = UserDefaults.standard.data(forKey: dailyRecordsKey) else {
            self.dailyRecords = [:]
            return
        }
        
        do {
            let decoded = try JSONDecoder().decode([String: DailyRecord].self, from: data)
            self.dailyRecords = decoded
        } catch {
            print("Failed to decode daily records: \(error)")
            self.dailyRecords = [:]
        }
    }
    
    /// 새로운 스케줄을 저장합니다.
    func addSchedule(_ schedule: Schedule) {
        schedules.append(schedule)
        saveToDisk()
    }
    
    /// 기존 스케줄을 수정합니다.
    func updateSchedule(_ schedule: Schedule) {
        if let index = schedules.firstIndex(where: { $0.id == schedule.id }) {
            schedules[index] = schedule
            saveToDisk()
        }
    }
    
    /// 스케줄을 삭제합니다.
    func deleteSchedule(id: UUID) {
        if let index = schedules.firstIndex(where: { $0.id == id }) {
            let schedule = schedules[index]
            if schedule.syncStatus == .pending {
                // 서버에 없는 데이터는 완전 삭제 (Hard Delete)
                schedules.remove(at: index)
            } else {
                // 서버와 동기화된 데이터는 삭제 마킹 (Soft Delete)
                schedules[index].deletedAt = Date()
                schedules[index].syncStatus = .pending // 삭제 상태 동기화 필요
            }
            saveToDisk()
        }
    }
    
    /// 변경된 스케줄 목록을 디스크에 영구 저장합니다.
    private func saveToDisk() {
        do {
            let encoded = try JSONEncoder().encode(schedules)
            UserDefaults.standard.set(encoded, forKey: storageKey)
        } catch {
            print("Failed to encode schedules: \(error)")
        }
    }
    
    /// 일별 기록을 디스크에 저장합니다.
    private func saveDailyRecords() {
        do {
            let encoded = try JSONEncoder().encode(dailyRecords)
            UserDefaults.standard.set(encoded, forKey: dailyRecordsKey)
        } catch {
            print("Failed to encode daily records: \(error)")
        }
    }
    
    /// 특정 날짜의 상태를 업데이트합니다.
    func updateDailyStatus(for date: Date, status: DailyStatus) {
        let dateString = formatDate(date)
        var record = dailyRecords[dateString] ?? DailyRecord(date: dateString)
        record.status = status
        record.allInModeUsed = true // 상태가 명시적으로 업데이트되는 경우(포기 등)는 대개 올인 모드 사용 중임
        dailyRecords[dateString] = record
        saveDailyRecords()
    }
    
    /// 날짜를 YYYY-MM-DD 형식의 문자열로 변환합니다.
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    /// 특정 날짜의 스케줄만 필터링하여 가져옵니다.
    func getSchedules(for date: Date) -> [Schedule] {
        let calendar = Calendar.current
        return schedules.filter { calendar.isDate($0.createdAt, inSameDayAs: date) }
    }
}
