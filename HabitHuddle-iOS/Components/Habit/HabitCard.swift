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
                if habit.isCompleted {
                    Text(LocalizedStringResource.finishedKeepTheStreakAlive)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.green)
                } else {
                    (Text(verbatim: "\(habit.checkIns.count) / ") + Text(.days(habit.duration.numberOfDays)))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
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
}

#Preview("Habit card") {
    let habit = Habit(id: UUID(), user: LightweightUser(id: UUID()), name: "Demo Habit", description: "This is some description", duration: .oneWeek)
    VStack {
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
