import SwiftUI

/// 가로로 스크롤 가능한 날짜 선택 바입니다.
struct DateStripView: View {
    @ObservedObject var viewModel: HomeViewModel
    
    private let calendar = Calendar.current
    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E" // 요일 (Short)
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }()
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(viewModel.dateChips, id: \.self) { date in
                    dateItem(for: date)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Color(.systemBackground))
    }
    
    private func dateItem(for date: Date) -> some View {
        let isSelected = calendar.isDate(date, inSameDayAs: viewModel.selectedDate)
        let isToday = calendar.isDateInToday(date)
        
        return Button(action: {
            withAnimation(.spring()) {
                viewModel.selectDate(date)
            }
        }) {
            VStack(spacing: 6) {
                Text(dayFormatter.string(from: date))
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(isSelected ? .white : .secondary)
                
                Text("\(calendar.component(.day, from: date))")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(isSelected ? .white : .primary)
                
                if isToday {
                    Circle()
                        .fill(isSelected ? .white : Color.accentColor)
                        .frame(width: 4, height: 4)
                } else {
                    Spacer().frame(height: 4)
                }
            }
            .frame(width: 45, height: 65)
            .background(isSelected ? Color.accentColor : Color.clear)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.clear : Color.gray.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    DateStripView(viewModel: HomeViewModel())
}
