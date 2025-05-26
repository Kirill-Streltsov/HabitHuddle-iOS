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
                        VStack(alignment: .leading) {
                            Text("Hello \(user.name)! 👋")
                                .font(.title)
                            Text("Today's Habits")
                                .font(.title2)
                        }
                        .fontWeight(.bold)
                        .padding(.horizontal)
                        Spacer()
                    }

                    // Today's habits section
                    HabitsGridView(habits: habits)

                    Divider()
                    HStack {
                        Text("Your Friends")
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
                    Button {
                        isShowingNewHabitView = true
                    } label: {
                        Text("Add habit")
                    }
                }
                .navigationDestination(isPresented: $isShowingNewHabitView) {
                    NewHabitView(appState: appState)
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
