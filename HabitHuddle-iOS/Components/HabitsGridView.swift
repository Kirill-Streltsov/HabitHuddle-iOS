//
//  HabitsGridView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 26.05.25.
//

import SwiftUI

struct HabitsGridView: View {
    let habits: [Habit]
    
    // Group habits with non-empty goals
    var groupedHabits: [String: [Habit]] {
        Dictionary(
            grouping: habits.filter { !$0.goal.isEmpty },
            by: { $0.goal }
        )
    }
    
    // Habits with empty goal string
    var ungroupedHabits: [Habit] {
        habits.filter { $0.goal.isEmpty }
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                if groupedHabits.isEmpty {
                    noGoalsHabits
                } else {
                    groupedByGoalsHabits
                    otherHabits
                }
            }
            .padding(.top)
            .padding(.bottom)
        }
    }
    
    private var noGoalsHabits: some View {
        LazyVGrid(columns: [GridItem(.flexible())], spacing: 12) {
            ForEach(habits) { habit in
                NavigationLink(value: habit) {
                    HabitCard(habit: habit)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal)
    }
    
    private var groupedByGoalsHabits: some View {
        ForEach(groupedHabits.keys.sorted(), id: \.self) { goal in
            if let habitsForGoal = groupedHabits[goal], !habitsForGoal.isEmpty {
                Section {
                    Text(goal)
                        .font(.headline)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: [GridItem(.flexible())], spacing: 12) {
                        ForEach(habitsForGoal) { habit in
                            NavigationLink(value: habit) {
                                HabitCard(habit: habit)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    private var otherHabits: some View {
        Group {
            if !ungroupedHabits.isEmpty {
                Section {
                    Text("Other Habits")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: [GridItem(.flexible())], spacing: 12) {
                        ForEach(ungroupedHabits) { habit in
                            NavigationLink(value: habit) {
                                HabitCard(habit: habit)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

#Preview {
    HabitsGridView(habits: Habit.createTestHabitsWithCheckIns())
}
