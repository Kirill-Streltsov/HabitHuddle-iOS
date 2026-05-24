//
//  MyFriendsListView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 04.06.25.
//

import SwiftUI
import SwiftData

struct MyFriendsList: View {
    
    @Query
    var users: [User]
    
    @EnvironmentObject private var viewModel: ViewModel
    @Environment(\.modelContext) private var context
    
    @EnvironmentObject private var appState: AppState
    
    let isInFriendsTab: Bool
    var habit: Habit?
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            ScrollView {
                if !isInFriendsTab, let habit = habit {
                    VStack(spacing: 4) {
                        Text(.challengeYourFriends)
                            .font(.title3)
                            .fontWeight(.bold)
                        Text(habit.name)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)
                    .padding(.bottom, 8)
                }
                // Friends list below
                if !appState.isAuthenticated {
                    UnauthenticatedView(description: .youNeedToLogInToAddFriends)
                } else {
                    if !viewModel.friends.isEmpty {
                        ForEach(viewModel.friends) { friend in
                            if !isInFriendsTab {
                                if let habit = habit {
                                    FriendCardView(friend: friend, showChallengeButton: true) {
                                        await viewModel.sendChallenge(to: friend.id, for: habit.id)
                                    }
                                }
                            } else {
                                NavigationLink {
                                    FriendDetailView(friend: friend)
                                } label: {
                                    FriendCardView(friend: friend, showChallengeButton: false)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.bottom, 4)
                        .onAppear {
                            for friend in viewModel.friends {
                                let user = friend.toSwiftData()
                                do {
                                    try saveUserIfNeeded(user)
                                } catch {
                                    print("❌ Error: Failed to save user \(user.id): \(error)")
                                }
                            }
                        }
                    } else {
                        EmptyContentView(
                            icon: "person.2.slash",
                            title: .noFriendsYet,
                            description: .connectWithFriendsToSendChallengesTrackHabitsTogetherAndStayMotivated
                        )
                    }
                }
            }
            .task {
                await viewModel.getMyFriends()
            }
        }
    }
    
    private func saveUserIfNeeded(_ user: User) throws {
        let userID = user.id
        let existing = users.filter({ $0.id == userID })
        if existing.isEmpty {
            print("💾 Saving user with id: \(userID) to Swift Data")
            context.insert(user)
        }
    }
}

#Preview("Friends tab") {
    let vm = MyFriendsList.ViewModel()
    let appState = AppState()
    appState.isAuthenticated = true
    return MyFriendsList(isInFriendsTab: true)
        .environmentObject(vm)
        .environmentObject(appState)
        .modelContainer(for: User.self, inMemory: true)
}

#Preview("Challenge mode") {
    let vm = MyFriendsList.ViewModel()
    vm.friends = [
        UserDTO(id: UUID(), username: "jdoe", name: "John Doe", createdAt: .now, updatedAt: .now),
        UserDTO(id: UUID(), username: "jsmith", name: "Jane Smith", createdAt: .now, updatedAt: .now),
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
    return MyFriendsList(isInFriendsTab: false, habit: habit)
        .environmentObject(vm)
        .environmentObject(appState)
        .modelContainer(for: User.self, inMemory: true)
}
