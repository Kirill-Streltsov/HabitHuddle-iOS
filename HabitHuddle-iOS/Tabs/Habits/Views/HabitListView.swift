//
//  HomeView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 20.05.25.
//

import SwiftData
import SwiftUI

struct HabitListView: View {
    @Query
    var habits: [Habit]
        
    @EnvironmentObject private var userManager: LocalUserManager
    @EnvironmentObject private var appState: AppState
    @Environment(\.modelContext) private var context
    
    @State private var showAllHabits = false
    @State private var showNewHabitView = false
    
    @StateObject private var newHabitViewModel = HabitDetailView.ViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if habits.isEmpty {
                    EmptyHabitsView() {
                        resetNewHabitViewModel()
                        showNewHabitView = true
                    }
                } else {
                    HabitsGridView(habits: habits)
                }
            }
            .background(Color(.systemGroupedBackground))
            .toolbar {
                if !habits.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            resetNewHabitViewModel()
                            showNewHabitView = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(.blue)
                                .font(.title2)
                        }
                    }
                }
            }
            .navigationDestination(isPresented: $showNewHabitView) {
                HabitEditView(viewModel: newHabitViewModel)
            }
            .navigationDestination(for: Habit.self) { habit in
                HabitDetailView(habit: habit)
            }
            .navigationTitle("Habits")
        }
    }

    private func resetNewHabitViewModel() {
        newHabitViewModel.name = ""
        newHabitViewModel.description = ""
        newHabitViewModel.category = ""
        newHabitViewModel.icon = nil
        newHabitViewModel.duration = .twoWeeks
        newHabitViewModel.isSynced = false
        newHabitViewModel.isPublic = false
        newHabitViewModel.hasReminder = false
        newHabitViewModel.reminderTime = Date()
        newHabitViewModel.habit = nil
        newHabitViewModel.openAIAnswer = ""
    }
}

#Preview {
    HabitListView()
}
