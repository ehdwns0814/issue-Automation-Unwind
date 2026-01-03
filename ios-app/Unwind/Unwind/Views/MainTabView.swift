import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ContentView()
                .tabItem {
                    Label("스케줄", systemImage: "calendar")
                }
                .tag(0)
            
            Text("통계 화면 (준비 중)")
                .tabItem {
                    Label("통계", systemImage: "chart.bar.fill")
                }
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Label("설정", systemImage: "gearshape.fill")
                }
                .tag(2)
        }
    }
}

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("차단 설정")) {
                    NavigationLink {
                        BlockedAppsView()
                    } label: {
                        Label("차단할 앱 관리", systemImage: "app.badge.fill")
                    }
                }
                
                Section(header: Text("앱 정보")) {
                    HStack {
                        Text("버전")
                        Spacer()
                        Text("v1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("설정")
        }
    }
}

#Preview {
    MainTabView()
}

