//
//  MyFriendsListView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 04.06.25.
//

import SwiftUI

struct MyFriendsListView: View {
    
    @EnvironmentObject private var viewModel: ViewModel
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
                                await viewModel.sendChallenge(to: friend.id, for: habit.id, of: .competitive, with: .now, and: .now)
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
                
            } else {
                EmptyFriendsView()
            }
        }
        .task {
            await viewModel.getMyFriends()
        }
    }
}

#Preview {
    MyFriendsListView(isInFriendsTab: true)
}
