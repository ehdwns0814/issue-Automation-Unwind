import Foundation
import Combine

/// 스케줄 생성 화면의 비즈니스 로직을 담당하는 뷰모델입니다.
class AddScheduleViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var durationMinutes: Int = 25 // 기본값 25분
    @Published var errorMessage: String?
    
    // 유효성 검사 로직
    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && durationMinutes > 0
    }
    
    private let repository: ScheduleRepository
    
    init(repository: ScheduleRepository = .shared) {
        self.repository = repository
    }
    
    /// 새로운 스케줄을 생성하고 저장합니다. 성공 시 true를 반환합니다.
    func saveSchedule() -> Bool {
        guard isValid else {
            errorMessage = "이름과 시간을 정확히 입력해주세요."
            return false
        }
        
        let newSchedule = Schedule(
            name: name,
            durationSeconds: durationMinutes * 60
        )
        
        repository.addSchedule(newSchedule)
        return true
    }
}
