import SwiftUI

struct TimerView: View {
    @StateObject private var focusManager = FocusManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showingAbandonAlert = false
    
    var body: some View {
        VStack(spacing: 40) {
            if let schedule = focusManager.currentSchedule {
                Text(schedule.name)
                    .font(.title)
                    .fontWeight(.bold)
            }
            
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.linear, value: focusManager.timeRemaining)
                
                Text(timeString)
                    .font(.system(size: 60, weight: .medium, design: .monospaced))
            }
            .frame(width: 280, height: 280)
            
            VStack(spacing: 20) {
                Text("집중 모드가 활성화되었습니다.")
                    .foregroundColor(.secondary)
                
                Button(role: .destructive) {
                    showingAbandonAlert = true
                } label: {
                    Text("포기하기")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(12)
                }
                .padding(.horizontal, 40)
            }
        }
        .padding()
        .onReceive(focusManager.$isFocusing) { isFocusing in
            if !isFocusing {
                dismiss()
            }
        }
        .alert("정말 포기하시겠습니까?", isPresented: $showingAbandonAlert) {
            Button("계속 집중하기", role: .cancel) { }
            Button("포기하기", role: .destructive) {
                focusManager.abandonFocus()
            }
        } message: {
            Text("이번 집중은 실패로 기록됩니다.")
        }
    }
    
    private var progress: CGFloat {
        guard let total = focusManager.currentSchedule?.durationSeconds, total > 0 else { return 0 }
        return CGFloat(focusManager.timeRemaining) / CGFloat(total)
    }
    
    private var timeString: String {
        let minutes = focusManager.timeRemaining / 60
        let seconds = focusManager.timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    TimerView()
}
