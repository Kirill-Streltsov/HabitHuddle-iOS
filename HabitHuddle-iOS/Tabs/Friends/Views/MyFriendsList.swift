//
//  MyFriendsListView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 04.06.25.
//

import SwiftUI
import SwiftData

struct MyFriendsList: View {
    
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
                // Friends list below
                if !appState.isAuthenticated {
                    UnauthenticatedView(description: "You need to log in to add friends.")
                } else {
                    if !viewModel.friends.isEmpty {
                        ForEach(viewModel.friends) { friend in
                            if !isInFriendsTab {
                                if let habit = habit {
                                    FriendCardView(friend: friend, showChallengeButton: true) {
                                        await viewModel.sendChallenge(to: friend.id, for: habit.id, ofType: .competitive)
                                    } onSupport: {
                                        await viewModel.sendChallenge(to: friend.id, for: habit.id, ofType: .supportive)
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
                            title: "No Friends Yet",
                            description: "Connect with friends to send challenges, track habits together, and stay motivated."
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
        let descriptor = FetchDescriptor<User>(predicate: #Predicate { $0.id == userID })
        let existing = try context.fetch(descriptor)
        if existing.isEmpty {
            print("💾 Saving user with id: \(userID) to Swift Data")
            context.insert(user)
        }
    }
}

#Preview {
    MyFriendsList(isInFriendsTab: true)
}
