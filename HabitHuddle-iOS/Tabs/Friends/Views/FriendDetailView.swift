//
//  FriendDetailView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 02.06.25.
//

import SwiftUI

struct FriendDetailView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var viewModel = ViewModel()
    let friend: UserDTO
    
    @State private var showToast = false
    @State private var message = ""
    @State private var heatmapID = UUID()
    
    var body: some View {
        ScrollView {
            VStack {
                CardView {
                    VStack {
                        Text("\(friend.name)'s activity")
                            .font(.title2)
                            .fontWeight(.semibold)
                        HeatmapView(habits: viewModel.habits.map{ $0.toSwiftData() })
                            .id(heatmapID)
                    }
                }
                Divider()
                friendHabits
                Divider()
                friendChallenges
            }
            .task {
                await viewModel.getUserHabits(for: friend.id)
                await viewModel.getUserChallenges(for: friend.id)
            }
        }
        .onChange(of: viewModel.habits.count) { _, newValue in
            if newValue > 0 {
                heatmapID = UUID()
            }
        }
        .toast(isPresented: $showToast, message: message)
        .background(Color(.systemGroupedBackground))
        .toolbar {
            Button {
                Task {
                    await viewModel.deleteFriend(with: friend.id)
                }
                dismiss()
            } label: {
                Image(systemName: "trash")
                    .foregroundStyle(.red)
            }
        }
        .navigationTitle(friend.username)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var friendHabits: some View {
        Group {
            if !viewModel.habits.isEmpty {
                Text("\(friend.name)'s habits")
                    .font(.title2)
                    .fontWeight(.semibold)
                VStack(alignment: .center) {
                    ForEach(viewModel.habits) { habitDTO in
                        FriendHabitCard(habitDTO: habitDTO) {
                            Task {
                                let result = await viewModel.sendChallenge(to: friend.id, for: habitDTO.id, ofType: .supportive)
                                Helpers.handleResult(result) { result in
                                    showToast = true
                                    message = "Supportive challenge sent!"
                                }
                            }
                        } onCompetitiveCalled: {
                            Task {
                                let result = await viewModel.sendChallenge(to: friend.id, for: habitDTO.id, ofType: .competitive)
                                Helpers.handleResult(result) { result in
                                    showToast = true
                                    message = "Competitive challenge sent!"
                                }
                            }
                        }
                    }
                }
            } else {
                EmptyFriendHabitsView(name: friend.name)
            }
        }
    }
    
    private var friendChallenges: some View {
        Group {
            if !viewModel.challenges.isEmpty {
                VStack(alignment: .center) {
                    Text("\(friend.name)'s challenges")
                        .font(.title2)
                        .fontWeight(.semibold)
                    ForEach(viewModel.challenges) { challenge in
                        ChallengeProgressCardView(challenge: challenge)
                    }
                }
            }
        }
    }
}

#Preview {
    FriendDetailView(friend: UserDTO(id: UUID(), username: "username", name: "Jack", createdAt: .now, updatedAt: .now))
}



struct Hardcode {
    static let user = LightweightUser(id: UUID())
    static let calendar = Calendar.current
    static let today = Date()

    static func daysAgo(_ days: Int) -> Date {
        calendar.date(byAdding: .day, value: -days, to: today)!
    }

    static func checkIns(for habit: Habit, days: [Int]) -> [HabitCheckIn] {
        days.map { HabitCheckIn(date: daysAgo($0), habit: habit, habitID: habit.id) }
    }

    static var allHabits: [Habit] {
        var habits: [Habit] = []

        // Habit 1: Daily streak for 30 days
        let habit1 = Habit(
            id: UUID(),
            user: user,
            name: "Morning Run",
            description: "Run every morning for 30 minutes",
            duration: .oneMonth
        )
        habit1.checkIns = checkIns(for: habit1, days: Array(0..<30))
        habits.append(habit1)

        // Habit 2: Every 3 days over 90 days
        let habit2 = Habit(
            id: UUID(),
            user: user,
            name: "Read Book",
            description: "Read a book chapter",
            duration: .oneMonth
        )
        habit2.checkIns = checkIns(for: habit2, days: stride(from: 0, to: 90, by: 3).map { $0 })
        habits.append(habit2)

        // Habit 3: Weekdays only (Mon–Fri)
        let habit3 = Habit(
            id: UUID(),
            user: user,
            name: "Study German",
            description: "Practice German vocabulary",
            duration: .twoWeeks
        )
        habit3.checkIns = (0..<90).compactMap {
            let date = daysAgo($0)
            return calendar.isDateInWeekend(date) ? nil : HabitCheckIn(date: date, habit: habit3, habitID: habit3.id)
        }.prefix(30).map { $0 }
        habits.append(habit3)

        // Habit 4: Every weekend
        let habit4 = Habit(
            id: UUID(),
            user: user,
            name: "Call Parents",
            description: "Weekly check-in with family",
            duration: .oneWeek
        )
        habit4.checkIns = (0..<90).compactMap {
            let date = daysAgo($0)
            return calendar.isDateInWeekend(date) ? HabitCheckIn(date: date, habit: habit4, habitID: habit4.id) : nil
        }.prefix(30).map { $0 }
        habits.append(habit4)

        // Habit 5: First 30 days only
        let habit5 = Habit(
            id: UUID(),
            user: user,
            name: "30-Day Yoga Challenge",
            description: "Do yoga every day for 30 days",
            duration: .oneMonth
        )
        habit5.checkIns = checkIns(for: habit5, days: Array(60..<90))
        habits.append(habit5)

        // Habit 6: Random-looking but fixed spaced
        let habit6 = Habit(
            id: UUID(),
            user: user,
            name: "Drink Water",
            description: "Drink 2L of water",
            duration: .oneMonth
        )
        habit6.checkIns = checkIns(for: habit6, days: [0, 1, 2, 5, 6, 9, 12, 13, 14, 17, 18, 21, 24, 27, 28, 31, 32, 35, 38, 41, 44, 47, 50, 53, 56, 59, 62, 65, 68, 71])
        habits.append(habit6)

        // Habit 7: 2 check-ins per week
        let habit7 = Habit(
            id: UUID(),
            user: user,
            name: "Write Journal",
            description: "Write personal journal entries",
            duration: .twoWeeks
        )
        habit7.checkIns = checkIns(for: habit7, days: stride(from: 0, to: 90, by: 3).prefix(30).map { $0 })
        habits.append(habit7)

        // Habit 8: Mon/Wed/Fri routine
        let habit8 = Habit(
            id: UUID(),
            user: user,
            name: "Workout",
            description: "Gym workouts every Mon/Wed/Fri",
            duration: .oneMonth
        )
        habit8.checkIns = (0..<90).compactMap {
            let date = daysAgo($0)
            let weekday = calendar.component(.weekday, from: date)
            return [2, 4, 6].contains(weekday) ? HabitCheckIn(date: date, habit: habit8, habitID: habit8.id) : nil
        }.prefix(30).map { $0 }
        habits.append(habit8)

        // Habit 9: Alternating days
        let habit9 = Habit(
            id: UUID(),
            user: user,
            name: "Meditation",
            description: "Alternate day meditation",
            duration: .oneMonth
        )
        habit9.checkIns = checkIns(for: habit9, days: stride(from: 0, to: 60, by: 2).map { $0 })
        habits.append(habit9)

        // Habit 10: Every 5 days
        let habit10 = Habit(
            id: UUID(),
            user: user,
            name: "Practice Coding",
            description: "Solve coding problems",
            duration: .twoWeeks
        )
        habit10.checkIns = checkIns(for: habit10, days: stride(from: 0, to: 150, by: 5).prefix(30).map { $0 })
        habits.append(habit10)

        return habits
    }
}
