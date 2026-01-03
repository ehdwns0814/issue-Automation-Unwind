//
//  UnwindApp.swift
//  Unwind
//
//  Created by 동준 on 1/3/26.
//

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
                .onChange(of: scenePhase) { _, newPhase in
                    if newPhase == .active {
                        // 앱이 포그라운드로 올라올 때마다 권한 상태를 체크합니다.
                        penaltyManager.checkAuthorizationStatus()
                        ScreentimeManager.shared.updateAuthorizationStatus()
                    }
                }
        }
    }
}
