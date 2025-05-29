//
//  HomeView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 20.05.25.
//

import SwiftData
import SwiftUI

struct HabitDummy: Identifiable {
    let id = UUID()
    let title: String
}

struct HomeView: View {
    @Query var habits: [Habit]

    @EnvironmentObject var appState: AppState

    @State private var showAllHabits = false
    @State private var isShowingNewHabitView = false

    @State private var friendsHabits: [HabitDummy] = [
        HabitDummy(title: "Meditate 🧘‍♂️"),
        HabitDummy(title: "Sleep early 🛌"),
        HabitDummy(title: "Study Swift 🦅"),
    ]

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

                    Divider()
                    HStack {
                        Text("Your friends")
                            .font(.title2)
                            .bold()
                            .padding(.horizontal)
                        Spacer()
                    }

                    // Friends section
                    VStack(alignment: .center, spacing: 16) {
                        ForEach(friendsHabits) { habit in
                            HabitCard(
                                title: habit.title,
                                cardWidth: 310,
                                habitProgress: 0.25,
                                frequency: "Daily"
                            )
                        }
                    }
                    Spacer()
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
                    NewHabitView(appState: appState)
                }
                .navigationTitle("Habits of the day")
            }
        }
    }
}

#Preview {
    HomeView()
}
