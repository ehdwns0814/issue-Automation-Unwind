import Foundation
import Combine

/// 메인 화면의 상태 관리 및 날짜별 스케줄 필터링을 담당하는 뷰모델입니다.
class HomeViewModel: ObservableObject {
    @Published var selectedDate: Date = Date()
    @Published var filteredSchedules: [Schedule] = []
    @Published var dateChips: [Date] = []
    
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
    }
    
    /// 날짜를 선택하고 목록을 갱신합니다.
    func selectDate(_ date: Date) {
        self.selectedDate = date
    }
}
