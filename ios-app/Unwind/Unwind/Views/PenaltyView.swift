import SwiftUI

struct PenaltyView: View {
    @State private var reason: String = ""
    @ObservedObject var penaltyManager = PenaltyManager.shared
    
    // 사유는 최소 10자 이상 입력해야 합니다.
    private var isReasonValid: Bool {
        reason.trimmingCharacters(in: .whitespacesAndNewlines).count >= 10
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Spacer()
                
                // 경고 아이콘 및 타이틀
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.red)
                        .symbolEffect(.bounce, value: true)
                    
                    Text("집중 모드 해제가 감지되었습니다")
                        .font(.title2.bold())
                        .multilineTextAlignment(.center)
                    
                    Text("집중 모드가 완료되기 전에 스크린타임 권한을 해제하셨습니다. 앱을 계속 사용하시려면 그 이유를 입력해주세요.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                }
                
                // 사유 입력 필드
                VStack(alignment: .leading, spacing: 8) {
                    Text("해제 사유 (최소 10자)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.leading, 4)
                    
                    TextEditor(text: $reason)
                        .padding(12)
                        .frame(height: 120)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                }
                .padding(.horizontal, 24)
                
                // 복귀 버튼
                Button(action: {
                    penaltyManager.clearPenalty(reason: reason)
                }) {
                    Text("반성하며 복귀하기")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(isReasonValid ? Color.blue : Color.gray)
                        .cornerRadius(14)
                }
                .disabled(!isReasonValid)
                .padding(.horizontal, 24)
                
                Spacer()
            }
            .navigationTitle("패널티 안내")
            .navigationBarTitleDisplayMode(.inline)
        }
        // 제스처로 닫기 방지 (iOS 15+)
        .interactiveDismissDisabled()
    }
}

#Preview {
    PenaltyView()
}

