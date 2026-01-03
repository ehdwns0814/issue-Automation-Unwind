import SwiftUI
import FamilyControls

struct BlockedAppsView: View {
    @StateObject private var screentimeManager = ScreentimeManager.shared
    @State private var isPickerPresented = false
    
    var body: some View {
        List {
            Section(header: Text("집중 시 차단될 앱들")) {
                if screentimeManager.selection.applicationTokens.isEmpty && 
                   screentimeManager.selection.categoryTokens.isEmpty &&
                   screentimeManager.selection.webDomainTokens.isEmpty {
                    Text("선택된 앱이 없습니다.")
                        .foregroundColor(.secondary)
                } else {
                    let totalCount = screentimeManager.selection.applicationTokens.count +
                                     screentimeManager.selection.categoryTokens.count +
                                     screentimeManager.selection.webDomainTokens.count
                    Text("\(totalCount)개의 항목이 선택되었습니다.")
                        .foregroundColor(.accentColor)
                }
                
                Button("앱 선택하기") {
                    isPickerPresented = true
                }
            }
            
            Section(footer: Text("여기서 선택한 앱들은 스케줄이 실행되는 동안 접근이 제한됩니다.")) {
                EmptyView()
            }
        }
        .navigationTitle("차단할 앱 관리")
        .familyActivityPicker(isPresented: $isPickerPresented, selection: $screentimeManager.selection)
        .task {
            do {
                try await screentimeManager.requestAuthorization()
            } catch {
                print("FamilyControls authorization failed: \(error)")
            }
        }
    }
}

#Preview {
    BlockedAppsView()
}

