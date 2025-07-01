//
//  HabitsGridView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 26.05.25.
//

import SwiftUI

struct HabitsGridView: View {
    let habits: [Habit]
    
    // Group habits with non-empty categories
    var groupedHabits: [String: [Habit]] {
        Dictionary(
            grouping: habits.filter { !$0.category.isEmpty },
            by: { $0.category }
        )
    }
    
    // Habits with empty category string
    var ungroupedHabits: [Habit] {
        habits.filter { $0.category.isEmpty }
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                if groupedHabits.isEmpty {
                    noCategoriesHabits
                } else {
                    groupedByCategoriesHabits
                    otherHabits
                }
            }
            .padding(.top)
            .padding(.bottom)
        }
    }
    
    private var noCategoriesHabits: some View {
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
    
    private var groupedByCategoriesHabits: some View {
        ForEach(groupedHabits.keys.sorted(), id: \.self) { category in
            if let habitsForCategory = groupedHabits[category], !habitsForCategory.isEmpty {
                Section {
                    Text(category)
                        .font(.headline)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: [GridItem(.flexible())], spacing: 12) {
                        ForEach(habitsForCategory) { habit in
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
