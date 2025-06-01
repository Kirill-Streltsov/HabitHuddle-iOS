//
//  StatisticsList.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 01.06.25.
//

import SwiftUI
import SwiftData

struct StatisticsList: View {
    
    @Environment(\.modelContext) private var context
    @Query(sort: [SortDescriptor(\Habit.createdAt, order: .reverse)])
    var habits: [Habit]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if habits.isEmpty {
                    EmptyStatisticsView()
                } else {
                    ForEach(habits) { habit in
                        NavigationLink(value: habit) {
                            HabitStatsCard(habit: habit)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .navigationDestination(for: Habit.self) { habit in
                StatisticsDetailView(habit: habit)
            }
            .navigationTitle("Statistics")
        }
    }
}

#Preview {
    StatisticsList()
}
