import SwiftUI
import FamilyControls

struct PermissionRequestView: View {
    @StateObject private var screentimeManager = ScreentimeManager.shared
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 80))
                .foregroundColor(.orange)
            
            VStack(spacing: 12) {
                Text("권한이 필요합니다")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("앱 차단 기능을 사용하기 위해서는\n스크린 타임 권한 허용이 필수적입니다.\n설정에서 권한을 허용해주세요.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .lineSpacing(4)
            }
            .padding(.horizontal, 40)
            
            Spacer()
            
            VStack(spacing: 16) {
                Button(action: {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Text("설정으로 이동")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(12)
                }
                
                Button(action: {
                    Task {
                        try? await screentimeManager.requestAuthorization()
                    }
                }) {
                    Text("다시 시도")
                        .font(.subheadline)
                        .foregroundColor(.orange)
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 50)
        }
        .background(Color(.systemBackground))
    }
}

#Preview {
    PermissionRequestView()
}

