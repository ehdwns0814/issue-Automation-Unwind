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
}
