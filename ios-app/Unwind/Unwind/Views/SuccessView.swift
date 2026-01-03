import SwiftUI

struct SuccessView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var animateCheckmark = false
    @State private var animateText = false
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // 축하 아이콘 (체크마크 애니메이션)
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.green)
                    .scaleEffect(animateCheckmark ? 1.0 : 0.5)
                    .opacity(animateCheckmark ? 1.0 : 0)
            }
            
            VStack(spacing: 12) {
                Text("집중 완료!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("오늘 하루도 한 걸음 더 나아갔네요.\n고생 많으셨습니다!")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .scaleEffect(animateText ? 1.0 : 0.8)
            .opacity(animateText ? 1.0 : 0)
            
            Spacer()
            
            Button {
                dismiss()
            } label: {
                Text("완료")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 30)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0)) {
                animateCheckmark = true
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
                animateText = true
            }
        }
    }
}

#Preview {
    SuccessView()
}

