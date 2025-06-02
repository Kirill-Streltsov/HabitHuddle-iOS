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
        
    @EnvironmentObject var userManager: LocalUserManager
    @EnvironmentObject var appState: AppState
    @Environment(\.modelContext) private var context
    
    @State private var showAllHabits = false
    @State private var showNewHabitView = false    
    
    var body: some View {
        NavigationStack {
            ScrollView {
                HStack {
                    Text("Hello, \(userManager.profile.name) 👋")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    Spacer()
                }
                
                if habits.isEmpty {
                    EmptyHabitsView(onAddHabit: { showNewHabitView = true })
                } else {
                    // Today's habits section
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
            .onAppear {
                Task {
                    await SyncManager.shared.retry(from: context)
                }
                //                    let newHabits = Habit.createTestHabitsWithCheckIns()
                //                    for newHabit in newHabits {
                //                        context.insert(newHabit)
                //                    }
            }
            .navigationDestination(isPresented: $showNewHabitView) {
                HabitFormView()
            }
            .navigationDestination(for: Habit.self) { habit in
                HabitFormView(habit: habit)
            }
            .navigationTitle("Habits of the day")
        }
        
    }
}

#Preview {
    HomeView()
}
