import SwiftUI

@main
struct UnwindApp: App {
    @StateObject private var penaltyManager = PenaltyManager.shared
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .fullScreenCover(isPresented: $penaltyManager.isPenaltyActive) {
                    PenaltyView()
                }
                .onAppear {
                    // 0.5초 지연을 주어 초기 UI 렌더링과 시스템 부하를 분산합니다.
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        ScreentimeManager.shared.updateAuthorizationStatus()
                    }
                }
                .onChange(of: scenePhase) { _, newPhase in
                    if newPhase == .active {
                        penaltyManager.checkAuthorizationStatus()
                        ScreentimeManager.shared.updateAuthorizationStatus()
                    }
                }
        }
    }
}
