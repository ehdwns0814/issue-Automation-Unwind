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
    @StateObject private var screentimeManager = ScreentimeManager.shared
    @State private var showingAddSheet = false
    @State private var editingSchedule: Schedule?
    @State private var scheduleToDelete: Schedule?
    @State private var showingTimer = false
    @State private var showingAllInAlert = false
    @State private var showingAllInAbandonAlert = false
    
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
                
                ToolbarItem(placement: .principal) {
                    if homeViewModel.currentStreak > 0 {
                        HStack(spacing: 4) {
                            Text("🔥")
                            Text("\(homeViewModel.currentStreak)일 연속")
                                .fontWeight(.bold)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(12)
                    }
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
            .alert("올인 모드 완료!", isPresented: $focusManager.showAllInCompletePopup) {
                Button("축하합니다!") {
                    focusManager.showAllInCompletePopup = false
                }
            } message: {
                Text("오늘의 모든 스케줄을 완료하셨습니다.\n정말 고생 많으셨어요! 🎉")
            }
            .alert("올인 모드 중단", isPresented: $showingAllInAbandonAlert) {
                Button("계속하기", role: .cancel) { }
                Button("포기하기", role: .destructive) {
                    focusManager.abandonAllInMode()
                }
            } message: {
                Text("지금 중단하면 오늘은 실패로 기록됩니다.\n정말 포기하시겠습니까?")
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
            .fullScreenCover(isPresented: .constant(screentimeManager.authorizationStatus == .denied)) {
                PermissionRequestView()
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
            HStack(spacing: 16) {
                // 체크박스 (올인 모드에서 주요 인터랙션)
                Button {
                    homeViewModel.toggleCompletion(for: schedule)
                } label: {
                    Image(systemName: schedule.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundColor(schedule.isCompleted ? .green : .gray)
                }
                .buttonStyle(.plain)
                
                // 스케줄 정보 (상세 보기/타이머 시작)
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
                        if !schedule.isCompleted && schedule.syncStatus == .pending {
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
            }
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
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "flame.fill")
                    Text("올인 모드 진행 중")
                        .fontWeight(.bold)
                }
                if !homeViewModel.todayProgressText.isEmpty {
                    Text(homeViewModel.todayProgressText)
                        .font(.caption)
                        .opacity(0.9)
                }
            }
            Spacer()
            Button("중단") {
                showingAllInAbandonAlert = true
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
                showingAllInAbandonAlert = true
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
