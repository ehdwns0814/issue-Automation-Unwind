import Foundation
import Combine

/// 메인 화면의 상태 관리 및 날짜별 스케줄 필터링을 담당하는 뷰모델입니다.
class HomeViewModel: ObservableObject {
    @Published var selectedDate: Date = Date()
    @Published var filteredSchedules: [Schedule] = []
    @Published var dateChips: [Date] = []
    @Published var todayProgressText: String = "" {
        didSet {
            UserDefaults(suiteName: "group.com.unwind.data")?.set(todayProgressText, forKey: "allInModeProgress")
        }
    }
    @Published var todayStatus: DailyStatus = .noPlan
    @Published var currentStreak: Int = 0
    
    // 오늘 남은 스케줄이 있는지 확인
    var hasIncompleteSchedulesToday: Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return repository.schedules.contains { 
            calendar.isDate($0.createdAt, inSameDayAs: today) && !$0.isCompleted && $0.deletedAt == nil
        }
    }
    
    private let repository: ScheduleRepository
    private var cancellables = Set<AnyCancellable>()
    
    init(repository: ScheduleRepository = .shared) {
        self.repository = repository
        
        generateDateChips()
        setupBindings()
    }
    
    /// 오늘을 중심으로 전후 날짜 칩을 생성합니다 (7일 범위).
    private func generateDateChips() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // -3일부터 +3일까지 생성
        self.dateChips = (-3...3).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: today)
        }
    }
    
    /// 저장소의 스케줄 변경사항을 감시하여 필터링된 목록을 업데이트합니다.
    private func setupBindings() {
        repository.$schedules
            .combineLatest($selectedDate)
            .map { (schedules, selectedDate) in
                let calendar = Calendar.current
                return schedules.filter { 
                    calendar.isDate($0.createdAt, inSameDayAs: selectedDate) && $0.deletedAt == nil
                }
            }
            .assign(to: \.filteredSchedules, on: self)
            .store(in: &cancellables)
            
        // 진행률 텍스트 바인딩
        repository.$schedules
            .map { schedules in
                let calendar = Calendar.current
                let today = calendar.startOfDay(for: Date())
                let todaysSchedules = schedules.filter { 
                    calendar.isDate($0.createdAt, inSameDayAs: today) && $0.deletedAt == nil
                }
                let total = todaysSchedules.count
                let completed = todaysSchedules.filter { $0.isCompleted }.count
                return total > 0 ? "\(completed)/\(total) 완료" : ""
            }
            .assign(to: \.todayProgressText, on: self)
            .store(in: &cancellables)
            
        // 오늘 날짜 상태 바인딩
        repository.$dailyRecords
            .map { [weak self] records in
                guard let self = self else { return .noPlan }
                let dateString = self.formatDate(Date())
                return records[dateString]?.status ?? .noPlan
            }
            .assign(to: \.todayStatus, on: self)
            .store(in: &cancellables)
            
        // 스트릭 계산 바인딩
        repository.$dailyRecords
            .map { records in
                return StreakCalculator.calculateCurrentStreak(from: records)
            }
            .assign(to: \.currentStreak, on: self)
            .store(in: &cancellables)
    }
    
    /// 날짜를 YYYY-MM-DD 형식의 문자열로 변환합니다.
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    /// 날짜를 선택하고 목록을 갱신합니다.
    func selectDate(_ date: Date) {
        self.selectedDate = date
    }
    
    /// 스케줄의 완료 상태를 토글합니다.
    func toggleCompletion(for schedule: Schedule) {
        var updatedSchedule = schedule
        if updatedSchedule.isCompleted {
            updatedSchedule.status = .pending
            updatedSchedule.isCompleted = false
        } else {
            updatedSchedule.status = .completed
            updatedSchedule.isCompleted = true
            updatedSchedule.completedAt = Date()
        }
        updatedSchedule.updatedAt = Date()
        repository.updateSchedule(updatedSchedule)
        
        // 전체 완료 여부 체크 (올인 모드 해제 로직)
        checkAllInCompletion()
    }
    
    private func checkAllInCompletion() {
        guard FocusManager.shared.isAllInModeActive else { return }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let todaysSchedules = repository.schedules.filter { 
            calendar.isDate($0.createdAt, inSameDayAs: today) && $0.deletedAt == nil
        }
        
        if !todaysSchedules.isEmpty && todaysSchedules.allSatisfy({ $0.isCompleted }) {
            // 모든 스케줄 완료 시 성공 기록
            repository.updateDailyStatus(for: today, status: .success)
            FocusManager.shared.stopAllInMode()
            FocusManager.shared.showAllInCompletePopup = true
        }
    }
}
