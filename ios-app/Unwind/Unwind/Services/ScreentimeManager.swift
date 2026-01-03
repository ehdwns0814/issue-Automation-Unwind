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
    
    private init() {
        loadSelection()
    }
    
    func requestAuthorization() async throws {
        try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
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

