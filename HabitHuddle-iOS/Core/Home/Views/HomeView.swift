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

    @Query var users: [User]
    
    @State private var showAllHabits = false
    @State private var isShowingNewHabitView = false
    @State private var todaysHabits: [HabitDummy] = [
        HabitDummy(title: "Drink Water 💧"),
        HabitDummy(title: "Exercise 🏋️‍♂️"),
        HabitDummy(title: "Read a book 📖"),
    ]
    
    @State private var friendsHabits: [HabitDummy] = [
        HabitDummy(title: "Meditate 🧘‍♂️"),
        HabitDummy(title: "Sleep early 🛌"),
        HabitDummy(title: "Study Swift 🦅"),
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Hello \(users.first!.name)! 👋")
                            .font(.title)
                        Text("Today's Habits")
                            .font(.title2)
                    }
                    .fontWeight(.bold)
                    .padding(.horizontal)
                    Spacer()
                }
                
                
                // Today's habits section
                VStack(alignment: .center, spacing: 16) {
                    ForEach(showAllHabits ? todaysHabits : Array(todaysHabits.prefix(2))) { habit in
                        HabitCard(
                            title: habit.title,
                            cardWidth: 310,
                            habitProgress: 0.25,
                            isCheckedInToday: true,
                            frequency: "Daily",
                            nextCheckIn: "Today, 8 PM"
                        )
                    }
                    
                    if todaysHabits.count > 2 {
                        Button(action: {
                            withAnimation {
                                showAllHabits.toggle()
                            }
                        }) {
                            Text(showAllHabits ? "Show Less" : "Show More")
                                .foregroundColor(.blue)
                                .padding(.horizontal)
                        }
                    }
                }
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
                            isCheckedInToday: true,
                            frequency: "Daily",
                            nextCheckIn: "Today, 8 PM"
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
                NewHabitView()
            }
        }
    }
}

#Preview {
    HomeView()
}
