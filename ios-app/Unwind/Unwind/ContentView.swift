//
//  ContentView.swift
//  Unwind
//
//  Created by 동준 on 1/3/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var showingAddSheet = false
    @State private var editingSchedule: Schedule?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                DateStripView(viewModel: viewModel)
                    .dividerUnderline()
                
                List {
                    if viewModel.filteredSchedules.isEmpty {
                        emptyStateView
                    } else {
                        scheduleList
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Unwind")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        editingSchedule = nil
                        showingAddSheet = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddScheduleView(scheduleToEdit: editingSchedule)
            }
            .fullScreenCover(isPresented: Binding(
                get: { FocusManager.shared.isFocusing },
                set: { if !$0 { FocusManager.shared.stopFocus() } }
            )) {
                TimerView()
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "calendar.badge.plus")
            .font(.system(size: 48))
            .foregroundColor(.gray)
            Text("이 날짜에는 스케줄이 없습니다.")
            .foregroundColor(.gray)
            Button("이 날에 추가하기") {
                editingSchedule = nil
                showingAddSheet = true
            }
            .buttonStyle(.bordered)
            Spacer()
        }
        .frame(maxWidth: .infinity, minHeight: 300)
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
    
    private var scheduleList: some View {
        ForEach(viewModel.filteredSchedules) { schedule in
            HStack {
                VStack(alignment: .leading) {
                    Text(schedule.name)
                        .font(.headline)
                    Text("\(schedule.durationSeconds / 60)분 집중")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                
                Button(action: {
                    FocusManager.shared.startFocus(for: schedule)
                }) {
                    Image(systemName: "play.circle.fill")
                        .font(.title2)
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(.plain)
                
                if schedule.syncStatus == .pending {
                    Image(systemName: "cloud.badge.plus")
                        .foregroundColor(.orange)
                        .font(.caption)
                }
            }
            .padding(.vertical, 4)
            .contextMenu {
                if !schedule.isCompleted {
                    Button {
                        editingSchedule = schedule
                        showingAddSheet = true
                    } label: {
                        Label("수정", systemImage: "pencil")
                    }
                }
            }
        }
    }
}

extension View {
    func dividerUnderline() -> some View {
        self.overlay(
            Rectangle()
                .fill(Color.gray.opacity(0.1))
                .frame(height: 1),
            alignment: .bottom
        )
    }
}

#Preview {
    ContentView()
}
