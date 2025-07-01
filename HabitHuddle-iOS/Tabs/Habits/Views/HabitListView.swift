//
//  HomeView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 20.05.25.
//

import SwiftData
import SwiftUI

struct HabitListView: View {
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
                    CardView {
                        EmptyHabitsView(onAddHabit: { showNewHabitView = true })
                    }
                } else {
                    HabitsGridView(habits: habits)
                }
            }
            .background(Color(.systemGroupedBackground))
            .toolbar {
                if !habits.isEmpty {
                    ToolbarItem(placement: .topBarLeading) {
                        
                        Button {
                            
                        } label: {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .foregroundStyle(.blue)
                                .font(.title2)
                        }
                        
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
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
                HabitEditView(viewModel: HabitDetailView.ViewModel())
            }
            .navigationDestination(for: Habit.self) { habit in
                HabitDetailView(habit: habit)
            }
            .navigationTitle("Habits")
        }
        
    }
}

#Preview {
    HabitListView()
}
