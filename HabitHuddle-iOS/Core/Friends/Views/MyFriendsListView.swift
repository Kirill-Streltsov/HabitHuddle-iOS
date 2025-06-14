//
//  MyFriendsListView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 04.06.25.
//

import SwiftUI
import SwiftData

struct MyFriendsListView: View {
    
    @EnvironmentObject private var viewModel: ViewModel
    @Environment(\.modelContext) private var context
    let isInFriendsTab: Bool
    var habit: Habit?
    
    var body: some View {
        Group {
            // Friends list below
            if !viewModel.friends.isEmpty {
                ForEach(viewModel.friends) { friend in
                    if !isInFriendsTab {
                        if let habit = habit {
                            FriendCardView(friend: friend, showChallengeButton: false) {
                                guard let endDate = Calendar.current.date(byAdding: .day, value: habit.duration.numberOfDays, to: Date.now) else {
                                    return
                                }
                                await viewModel.sendChallenge(to: friend.id, for: habit.id, of: .competitive, with: .now, and: endDate)
                            }
                            .onAppear {
                                print("THIS APPEARED HOME TAB")
                            }
                        }
                    } else {
                        NavigationLink {
                            FriendDetailView(friend: friend)
                        } label: {
                            FriendCardView(friend: friend, showChallengeButton: true) {}
                        }
                        .buttonStyle(.plain)
                        .onAppear {
                            print("THIS APPEARED FRIENDS TAB")
                        }
                    }
                }
                .onAppear {
                    for friend in viewModel.friends {
                        let user = friend.toSwiftData()
                        do {
                            try saveUserIfNeeded(user)
                        } catch {
                            print("Failed to save user \(user.id): \(error)")
                        }
                    }
                }
            } else {
                EmptyFriendsView()
            }
        }
        .task {
            await viewModel.getMyFriends()
        }
    }
    
    private func saveUserIfNeeded(_ user: User) throws {
        let userID = user.id
        let descriptor = FetchDescriptor<User>(predicate: #Predicate { $0.id == userID })
        let existing = try context.fetch(descriptor)
        if existing.isEmpty {
            context.insert(user)
        }
    }
}

#Preview {
    MyFriendsListView(isInFriendsTab: true)
}
