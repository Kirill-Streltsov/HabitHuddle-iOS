//
//  HomeView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 20.05.25.
//

import SwiftData
import SwiftUI

struct HomeView: View {
    @Query(sort: [SortDescriptor(\Habit.createdAt, order: .reverse)])
    var habits: [Habit]
        
    @EnvironmentObject private var userManager: LocalUserManager
    @EnvironmentObject private var appState: AppState
    @Environment(\.modelContext) private var context
    
    @State private var showAllHabits = false
    @State private var showNewHabitView = false    
    
    var body: some View {
        NavigationStack {
            ScrollView {

                if habits.isEmpty {
                    EmptyHabitsView(onAddHabit: { showNewHabitView = true })
                } else {
                    HabitsGridView(habits: habits)
                }
            }
            .toolbar {
                if !habits.isEmpty {
                    Button {
                        showNewHabitView = true
                    } label: {
                        Text("Add a habit")
                    }
                }
            }
            .navigationDestination(isPresented: $showNewHabitView) {
                HabitDetailView()
            }
            .navigationDestination(for: Habit.self) { habit in
                HabitDetailView(habit: habit)
            }
            .navigationTitle("Habits")
        }
        
    }
}

#Preview {
    HomeView()
}
