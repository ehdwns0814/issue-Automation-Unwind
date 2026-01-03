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
    
    /// 특정 날짜의 스케줄만 필터링하여 가져옵니다.
    func getSchedules(for date: Date) -> [Schedule] {
        let calendar = Calendar.current
        return schedules.filter { calendar.isDate($0.createdAt, inSameDayAs: date) }
    }
}
