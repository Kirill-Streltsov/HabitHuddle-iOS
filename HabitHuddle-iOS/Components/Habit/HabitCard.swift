//
//  HabitCard.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 23.05.25.
//

import SwiftUI
import SwiftData

struct HabitCard: View {

    @Environment(\.modelContext) private var context
    @State private var scale = 1.0
    @State private var challengeButtonPressed = false
    @State private var completedScale = 1.0
    @State private var ringProgress = 0.0

    let habit: Habit

    @Query
    var users: [User]

    var detent: PresentationDetent {
        if users.count >= 0 && users.count <= 2 {
            return .fraction(0.4)
        } else if users.count > 2 && users.count < 5 {
            return .medium
        } else {
            return .large
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerSection

            if habit.isCompleted {
                completedSection
            } else {
                activeSection
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color(.label).opacity(0.1), radius: 5, x: 0, y: 4)
        .frame(maxWidth: .infinity)
        .animation(.easeInOut(duration: 0.3), value: scale)
        .sheet(isPresented: $challengeButtonPressed) {
            MyFriendsList(isInFriendsTab: false, habit: habit)
                .presentationDetents([detent])
                .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Sections

    @ViewBuilder
    private var headerSection: some View {
        HStack(alignment: .top) {
            if let icon = habit.icon {
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .padding(4)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            VStack(alignment: .leading) {
                HStack(alignment: .top, spacing: 8) {
                    Text(habit.name)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .lineLimit(2)
                    Spacer()
                    HStack {
                        Image(systemName: habit.isSyncable ? "antenna.radiowaves.left.and.right" : "antenna.radiowaves.left.and.right.slash")
                            .foregroundStyle(habit.isSyncable ? .green : .gray)
                        Image(systemName: habit.reminderTime != nil ? "bell.fill" : "bell.slash.fill")
                            .foregroundStyle(habit.reminderTime != nil ? .orange : .gray)
                    }
                }
                if !habit.habitDescription.isEmpty {
                    Text(habit.habitDescription)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var completedSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                Circle()
                    .trim(from: 0, to: ringProgress)
                    .stroke(.yellow, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Image(systemName: "trophy.fill")
                    .font(.system(size: 38))
                    .foregroundStyle(habit.isCheckedInToday ? Color.yellow : Color.gray)
                    .flickering(shouldFlicker: !habit.isCheckedInToday)
            }
            .frame(width: 85, height: 85)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
            .scaleEffect(completedScale)
            .animation(.easeInOut(duration: 0.3), value: completedScale)
            .onAppear {
                ringProgress = habit.isCheckedInToday ? 1.0 : 0.0
            }
            .onTapGesture {
                HapticManager.trigger(.success)
                let targetProgress = habit.isCheckedInToday ? 0.0 : 1.0
                habit.toggleCheckIn(in: context)
                withAnimation(.easeOut(duration: 0.8)) {
                    ringProgress = targetProgress
                }
                completedScale += 0.15
                Task { completedScale -= 0.15 }
            }

            HStack {
                StatItem(title: .longestStreak, value: .days(habit.longestStreak))
                Spacer()
                StatItem(title: .done, value: "\(habit.completionPercentage)%")
            }
            .animation(.easeInOut(duration: 0.3), value: habit.checkIns.count)

            Text(.finishedKeepTheStreakAlive)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.orange)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 4)
        }
        .padding(.top, 16)
    }

    @ViewBuilder
    private var activeSection: some View {
        ZStack {
            CheckedInStateView(
                isOn: habit.isCheckedInToday,
                fontSize: 85,
                shouldFlicker: true,
                iconOn: "checkmark.circle.fill",
                iconOff: "checkmark.circle",
                color: .green
            )
            .offset(y: -5)
            .scaleEffect(scale)
            .onTapGesture {
                HapticManager.trigger(.success)
                habit.toggleCheckIn(in: context)
                scale += 0.15
                Task { scale -= 0.15 }
            }
            HStack {
                StatItem(title: .longestStreak, value: .days(habit.longestStreak))
                Spacer()
                StatItem(title: .done, value: "\(habit.completionPercentage)%")
            }
        }
        .offset(y: 15)
        .frame(maxWidth: .infinity)

        HStack(alignment: .bottom) {
            (Text(verbatim: "\(habit.checkIns.count) / ") + Text(.days(habit.duration.numberOfDays)))
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            if habit.challenges.isEmpty {
                Button {
                    challengeButtonPressed = true
                } label: {
                    Image(systemName: "flag.pattern.checkered.2.crossed")
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
            } else {
                Image(systemName: "flag.pattern.checkered.2.crossed")
                    .foregroundStyle(Color.accentColor)
            }
        }
        .padding(.bottom, 4)
        .frame(maxWidth: .infinity)

        HabitProgressView(habit: habit, height: 8)
    }
}

// MARK: - Previews

#Preview("Active habit") {
    let habit = Habit(
        id: UUID(),
        user: LightweightUser(id: UUID()),
        name: "Morning Run",
        description: "Track your daily progress",
        icon: "figure.run",
        duration: .oneWeek
    )
    return VStack {
        HabitCard(habit: habit)
    }
    .padding()
    .modelContainer(for: User.self, inMemory: true)
    .environmentObject(MyFriendsList.ViewModel())
    .environmentObject(AppState())
}

#Preview("Completed habit") {
    let calendar = Calendar.current
    let habit = Habit(
        id: UUID(),
        user: LightweightUser(id: UUID()),
        name: "Morning Run",
        description: "Track your daily progress",
        icon: "figure.run",
        duration: .oneWeek
    )
    habit.checkIns = (0..<7).map { i in
        let date = calendar.date(byAdding: .day, value: -i, to: .now)!
        return HabitCheckIn(date: date, habit: habit, habitID: habit.id)
    }
    return VStack {
        HabitCard(habit: habit)
    }
    .padding()
    .modelContainer(for: User.self, inMemory: true)
    .environmentObject(MyFriendsList.ViewModel())
    .environmentObject(AppState())
}

#Preview("Challenge sheet") {
    let vm = MyFriendsList.ViewModel()
    vm.friends = [
        UserDTO(id: UUID(), username: "jdoe", name: "John Doe", createdAt: .now, updatedAt: .now),
        UserDTO(id: UUID(), username: "jsmith", name: "Jane Smith", createdAt: .now, updatedAt: .now),
        UserDTO(id: UUID(), username: "agarcia", name: "Ana Garcia", createdAt: .now, updatedAt: .now),
    ]
    let appState = AppState()
    appState.isAuthenticated = true
    let habit = Habit(
        id: UUID(),
        user: LightweightUser(id: UUID()),
        name: "Morning Run",
        description: "Track your daily progress",
        duration: .oneWeek
    )
    return Color(.systemGroupedBackground)
        .ignoresSafeArea()
        .sheet(isPresented: .constant(true)) {
            MyFriendsList(isInFriendsTab: false, habit: habit)
                .presentationDetents([.fraction(0.6)])
                .presentationDragIndicator(.visible)
                .environmentObject(vm)
                .environmentObject(appState)
                .modelContainer(for: User.self, inMemory: true)
        }
}
