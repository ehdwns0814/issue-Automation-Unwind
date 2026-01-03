//
//  ContentView.swift
//  Unwind
//
//  Created by 동준 on 1/3/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var repository = ScheduleRepository.shared
    @State private var showingAddSheet = false
    
    var body: some View {
        NavigationStack {
            List {
                if repository.schedules.isEmpty {
                    VStack(spacing: 12) {
                        Spacer()
                        Image(systemName: "clock.badge.checkmark")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("아직 생성된 스케줄이 없습니다.")
                            .foregroundColor(.gray)
                        Button("첫 스케줄 만들기") {
                            showingAddSheet = true
                        }
                        .buttonStyle(.borderedProminent)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, minHeight: 300)
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(repository.schedules) { schedule in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(schedule.name)
                                    .font(.headline)
                                Text("\(schedule.durationSeconds / 60)분 집중")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            if schedule.syncStatus == .pending {
                                Image(systemName: "cloud.badge.plus")
                                    .foregroundColor(.orange)
                                    .font(.caption)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Unwind")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddSheet = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddScheduleView()
            }
        }
    }
}

#Preview {
    ContentView()
}
