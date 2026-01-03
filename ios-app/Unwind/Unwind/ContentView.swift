//
//  ContentView.swift
//  Unwind
//
//  Created by 동준 on 1/3/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var repository = ScheduleRepository.shared
    @StateObject private var homeViewModel = HomeViewModel()
    @StateObject private var focusManager = FocusManager.shared
    @State private var showingAddSheet = false
    @State private var editingSchedule: Schedule?
    @State private var scheduleToDelete: Schedule?
    @State private var showingTimer = false
    @State private var showingAllInAlert = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if focusManager.isAllInModeActive {
                    allInModeBanner
                }
                
                DateStripView(viewModel: homeViewModel)
                
                List {
                    if homeViewModel.filteredSchedules.isEmpty {
                        emptyStateView
                    } else {
                        scheduleListView
                    }
                }
            }
            .navigationTitle("Unwind")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    allInModeToggle
                }
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddSheet = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddScheduleView()
            }
            .sheet(item: $editingSchedule) { schedule in
                AddScheduleView(scheduleToEdit: schedule)
            }
            .fullScreenCover(isPresented: $showingTimer) {
                TimerView()
            }
            .alert("올인 모드", isPresented: $showingAllInAlert) {
                Button("확인") { }
            } message: {
                Text("오늘 예정된 미완료 스케줄이 없습니다.")
            }
            .alert("스케줄 삭제", isPresented: Binding(
                get: { scheduleToDelete != nil },
                set: { if !$0 { scheduleToDelete = nil } }
            )) {
                Button("취소", role: .cancel) {}
                Button("삭제", role: .destructive) {
                    if let schedule = scheduleToDelete {
                        repository.deleteSchedule(id: schedule.id)
                    }
                }
            } message: {
                Text("이 스케줄을 정말 삭제하시겠습니까?")
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "clock.badge.checkmark")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            Text("해당 날짜에 생성된 스케줄이 없습니다.")
                .foregroundColor(.gray)
            Button("첫 스케줄 만들기") {
                showingAddSheet = true
            }
            .buttonStyle(.borderedProminent)
            Spacer()
        }
        .frame(maxWidth: .infinity, minHeight: 300)
        .listRowBackground(Color.clear)
    }
    
    private var scheduleListView: some View {
        ForEach(homeViewModel.filteredSchedules) { schedule in
            Button {
                if !schedule.isCompleted && !focusManager.isAllInModeActive {
                    focusManager.startFocus(on: schedule)
                    showingTimer = true
                }
            } label: {
                HStack {
                    VStack(alignment: .leading) {
                        Text(schedule.name)
                            .font(.headline)
                            .foregroundColor(schedule.isCompleted ? .secondary : .primary)
                        Text("\(schedule.durationSeconds / 60)분 집중")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    if schedule.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    } else if schedule.syncStatus == .pending {
                        Image(systemName: "cloud.badge.plus")
                            .foregroundColor(.orange)
                            .font(.caption)
                    }
                }
                .padding(.vertical, 4)
            }
            .buttonStyle(.plain)
            .contentShape(Rectangle())
            .disabled(focusManager.isAllInModeActive && !schedule.isCompleted)
            .contextMenu {
                if !schedule.isCompleted {
                    Button {
                        editingSchedule = schedule
                    } label: {
                        Label("수정", systemImage: "pencil")
                    }
                }
                
                Button(role: .destructive) {
                    scheduleToDelete = schedule
                } label: {
                    Label("삭제", systemImage: "trash")
                }
            }
        }
        .onDelete { indexSet in
            indexSet.forEach { index in
                let schedule = homeViewModel.filteredSchedules[index]
                scheduleToDelete = schedule
            }
        }
    }

    private var allInModeBanner: some View {
        HStack {
            Image(systemName: "flame.fill")
            Text("올인 모드 진행 중")
                .fontWeight(.bold)
            Spacer()
            Button("중단") {
                focusManager.stopAllInMode()
            }
            .buttonStyle(.bordered)
            .tint(.white)
        }
        .padding()
        .background(Color.orange)
        .foregroundColor(.white)
    }
    
    private var allInModeToggle: some View {
        Button {
            if focusManager.isAllInModeActive {
                focusManager.stopAllInMode()
            } else {
                if homeViewModel.hasIncompleteSchedulesToday {
                    focusManager.startAllInMode()
                } else {
                    showingAllInAlert = true
                }
            }
        } label: {
            Image(systemName: focusManager.isAllInModeActive ? "bolt.fill" : "bolt")
                .foregroundColor(focusManager.isAllInModeActive ? .orange : .primary)
        }
    }
}

#Preview {
    ContentView()
}
