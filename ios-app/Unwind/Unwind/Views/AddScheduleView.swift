import SwiftUI

/// 새로운 스케줄을 추가하거나 기존 스케줄을 수정하기 위한 모달 뷰입니다.
struct AddScheduleView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: AddScheduleViewModel
    
    init(scheduleToEdit: Schedule? = nil) {
        _viewModel = StateObject(wrappedValue: AddScheduleViewModel(scheduleToEdit: scheduleToEdit))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("기본 정보")) {
                    TextField("스케줄 이름 (예: 독서, 코딩)", text: $viewModel.name)
                        .autocorrectionDisabled()
                }
                
                Section(header: Text("집중 시간")) {
                    Stepper(value: $viewModel.durationMinutes, in: 5...180, step: 5) {
                        HStack {
                            Text("\(viewModel.durationMinutes)분")
                                .fontWeight(.bold)
                            Spacer()
                            Text("집중")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                if let error = viewModel.errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle(viewModel.isEditing ? "스케줄 수정" : "새 스케줄 생성")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarItems
            }
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("취소") {
                dismiss()
            }
        }
        ToolbarItem(placement: .confirmationAction) {
            Button(viewModel.isEditing ? "수정" : "저장") {
                if viewModel.saveSchedule() {
                    dismiss()
                }
            }
            .disabled(!viewModel.isValid)
        }
    }
}

#Preview {
    AddScheduleView()
}
