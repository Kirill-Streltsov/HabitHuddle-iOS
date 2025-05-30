//
//  HomeView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 20.05.25.
//

import SwiftData
import SwiftUI

struct HomeView: View {
    @Query var habits: [Habit]

    @EnvironmentObject var appState: AppState

    @State private var showAllHabits = false
    @State private var isShowingNewHabitView = false

    var body: some View {
        UserDataView { user in
            NavigationStack {
                ScrollView {
                    HStack {
                        Text(user.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        Spacer()
                    }
                    
                    if habits.isEmpty {
                        EmptyStateView(title: "You don't have any habits yet", subtitle: "Add your first one!") {
                            isShowingNewHabitView = true
                        }
                    } else {
                        // Today's habits section
                        HabitsGridView(habits: habits)
                    }
                }
                .toolbar {
                    if !habits.isEmpty {
                        Button {
                            isShowingNewHabitView = true
                        } label: {
                            Text("Add a habit")
                        }
                    }
                }
                .navigationDestination(isPresented: $isShowingNewHabitView) {
                    HabitFormView()
                }
                .navigationDestination(for: Habit.self) { habit in
                    HabitFormView(habit: habit)
                }
                .navigationTitle("Habits of the day")
            }
        }
    }
}

#Preview {
    HomeView()
}
