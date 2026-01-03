import Foundation
import FamilyControls
import Combine

class PenaltyManager: ObservableObject {
    static let shared = PenaltyManager()
    
    @Published var isPenaltyActive: Bool = false
    
    private let penaltyKey = "com.unwind.isPenaltyActive"
    private let focusManager = FocusManager.shared
    
    private init() {
        // 앱 실행 시 저장된 패널티 상태를 불러옵니다.
        self.isPenaltyActive = UserDefaults.standard.bool(forKey: penaltyKey)
    }
    
    /// 스크린타임 권한 상태를 확인하고, 집중 모드 중 해제된 경우 패널티를 활성화합니다.
    func checkAuthorizationStatus() {
        let status = AuthorizationCenter.shared.authorizationStatus
        
        // 집중 모드(Focusing) 중인데 권한이 허용됨(.approved) 상태가 아니라면 우회로 간주합니다.
        // iOS 16+ 에서는 .approved 가 정상 허용 상태입니다.
        if focusManager.isFocusing && status != .approved {
            activatePenalty()
        }
    }
    
    /// 패널티 상태를 활성화하고 영구 저장합니다.
    func activatePenalty() {
        isPenaltyActive = true
        UserDefaults.standard.set(true, forKey: penaltyKey)
        
        // 권한이 없으므로 현재 진행 중인 집중 모드를 강제 중단 처리합니다.
        focusManager.stopFocus()
    }
    
    /// 사용자가 사유를 입력하면 패널티 상태를 해제합니다.
    func clearPenalty(reason: String) {
        // 실제 운영 환경에서는 이 사유를 서버에 기록하여 사용자 행동 분석에 활용할 수 있습니다.
        print("Penalty cleared with reason: \(reason)")
        
        isPenaltyActive = false
        UserDefaults.standard.set(false, forKey: penaltyKey)
    }
}

