import Foundation
import FamilyControls

class PenaltyManager: ObservableObject {
    static let shared = PenaltyManager()
    
    @Published var isPenaltyActive: Bool = false
    private let focusManager = FocusManager.shared
    
    private init() {
    }
    
    func checkAuthorizationStatus() {
        
        #if DEBUG
        // Mock Mode: 디버깅 중에는 권한 취소로 인한 페널티를 발생시키지 않습니다.
        return
        #else
        Task {
            let status = AuthorizationCenter.shared.authorizationStatus
            await MainActor.run {
                if focusManager.isFocusing && status != .approved {
                    activatePenalty()
                }
            }
        }
        #endif
    }
    
    func activatePenalty() {
        isPenaltyActive = true
    }
    
    func clearPenalty(reason: String) {
        isPenaltyActive = false
    }
}
