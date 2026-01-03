import Foundation
import Combine

/// 스케줄 생성 및 수정을 담당하는 뷰모델입니다.
class AddScheduleViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var durationMinutes: Int = 25 // 기본값 25분
    @Published var errorMessage: String?
    
    // 수정 모드일 경우 원본 스케줄 저장
    private var originalSchedule: Schedule?
    
    var isEditing: Bool {
        originalSchedule != nil
    }
    
    // 유효성 검사 로직
    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && durationMinutes > 0
    }
    
    private let repository: ScheduleRepository
    
    init(repository: ScheduleRepository = .shared, scheduleToEdit: Schedule? = nil) {
        self.repository = repository
        self.originalSchedule = scheduleToEdit
        
        if let schedule = scheduleToEdit {
            self.name = schedule.name
            self.durationMinutes = schedule.durationSeconds / 60
        }
    }
    
    /// 스케줄을 저장(생성 또는 수정)합니다. 성공 시 true를 반환합니다.
    func saveSchedule() -> Bool {
        guard isValid else {
            errorMessage = "이름과 시간을 정확히 입력해주세요."
            return false
        }
        
        if var schedule = originalSchedule {
            // 수정 로직: 기존 데이터 보존하며 업데이트
            schedule.name = name
            schedule.durationSeconds = durationMinutes * 60
            schedule.updatedAt = Date()
            schedule.syncStatus = .pending
            
            repository.updateSchedule(schedule)
        } else {
            // 생성 로직
            let newSchedule = Schedule(
                name: name,
                durationSeconds: durationMinutes * 60
            )
            repository.addSchedule(newSchedule)
        }
        
        return true
    }
}
