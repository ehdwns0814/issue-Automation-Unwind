import SwiftUI

/// 집중 세션 중 카운트다운을 보여주는 전체 화면 뷰입니다.
struct TimerView: View {
    @ObservedObject var focusManager = FocusManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                if let schedule = focusManager.currentSchedule {
                    Text(schedule.name)
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                // 타이머 표시 (초 -> mm:ss 변환)
                Text(timeString(from: focusManager.remainingTime))
                    .font(.system(size: 80, weight: .thin, design: .monospaced))
                    .padding()
                
                VStack(spacing: 12) {
                    Text("집중 중입니다...")
                        .foregroundColor(.secondary)
                    
                    Text("다른 앱의 사용이 제한됩니다.")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button(action: {
                    focusManager.stopFocus()
                }) {
                    Text("포기하기")
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 15)
                        .background(Capsule().stroke(Color.red, lineWidth: 1))
                }
                .padding(.bottom, 50)
            }
        }
    }
    
    /// 초 단위를 MM:SS 형식의 문자열로 변환합니다.
    private func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}

#Preview {
    TimerView()
}
