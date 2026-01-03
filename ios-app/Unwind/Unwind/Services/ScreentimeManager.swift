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
        updateAuthorizationStatus()
    }
    
    func requestAuthorization() async throws {
        try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
        updateAuthorizationStatus()
    }
    
    func updateAuthorizationStatus() {
        DispatchQueue.main.async {
            self.authorizationStatus = AuthorizationCenter.shared.authorizationStatus
        }
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

