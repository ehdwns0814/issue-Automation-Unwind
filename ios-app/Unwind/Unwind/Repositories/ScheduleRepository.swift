import Foundation

/// 스케줄 데이터를 로컬 저장소(UserDefaults)에 관리하는 저장소 클래스입니다.
class ScheduleRepository: ObservableObject {
    static let shared = ScheduleRepository()
    
    private let storageKey = "com.unwind.schedules"
    
    @Published var schedules: [Schedule] = []
    
    private init() {
        loadSchedules()
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
    
    /// 새로운 스케줄을 저장합니다.
    func addSchedule(_ schedule: Schedule) {
        schedules.append(schedule)
        saveToDisk()
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
    
    /// 특정 날짜의 스케줄만 필터링하여 가져옵니다.
    func getSchedules(for date: Date) -> [Schedule] {
        let calendar = Calendar.current
        return schedules.filter { calendar.isDate($0.createdAt, inSameDayAs: date) }
    }
    
    /// 최근에 사용한 스케줄 목록을 가져옵니다 (중복 제거).
    func getRecentSchedules(limit: Int = 5) -> [Schedule] {
        var seen = Set<String>()
        var result: [Schedule] = []
        
        let sortedSchedules = schedules.sorted { $0.updatedAt > $1.updatedAt }
        
        for schedule in sortedSchedules {
            let key = "\(schedule.name)_\(schedule.durationSeconds)"
            if !seen.contains(key) {
                seen.insert(key)
                result.append(schedule)
            }
            if result.count >= limit {
                break
            }
        }
        
        return result
    }
    
    /// 기존 스케줄을 업데이트합니다.
    func updateSchedule(_ schedule: Schedule) {
        if let index = schedules.firstIndex(where: { $0.id == schedule.id }) {
            var updatedSchedule = schedule
            updatedSchedule.updatedAt = Date()
            updatedSchedule.syncStatus = .pending
            schedules[index] = updatedSchedule
            saveToDisk()
        }
    }
}
