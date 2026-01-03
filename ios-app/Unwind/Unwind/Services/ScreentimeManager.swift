import Foundation
import FamilyControls
import ManagedSettings

class ScreentimeManager: ObservableObject {
    static let shared = ScreentimeManager()
    
    private let storageKey = "com.unwind.blockedAppsSelection"
    
    @Published var selection: FamilyActivitySelection = FamilyActivitySelection() {
        didSet {
            saveSelection()
        }
    }
    
    @Published var authorizationStatus: AuthorizationStatus = .notDetermined
    
    private init() {
        loadSelection()
    }
    
    func requestAuthorization() async throws {
        
        #if DEBUG
        // Mock Mode: 권한 요청을 건너뛰고 바로 승인된 것으로 처리합니다.
        await MainActor.run {
            self.authorizationStatus = .approved
        }
        #else
        try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
        updateAuthorizationStatus()
        #endif
    }
    
    func updateAuthorizationStatus() {
        
        #if DEBUG
        // Mock Mode: 실제 API를 호출하지 않고 승인 상태를 유지하여 크래시를 방지합니다.
        DispatchQueue.main.async {
            self.authorizationStatus = .approved
        }
        #else
        Task {
            let status = AuthorizationCenter.shared.authorizationStatus
            await MainActor.run {
                self.authorizationStatus = status
            }
        }
        #endif
    }
    
    private func saveSelection() {
        do {
            let data = try JSONEncoder().encode(selection)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("Failed to save selection: \(error)")
        }
    }
    
    private func loadSelection() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        do {
            let decoded = try JSONDecoder().decode(FamilyActivitySelection.self, from: data)
            self.selection = decoded
        } catch {
            print("Failed to load selection: \(error)")
        }
    }
}
