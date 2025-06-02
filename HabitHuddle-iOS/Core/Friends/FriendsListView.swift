//
//  FriendsListView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 02.06.25.
//

import SwiftUI

struct FriendsListView: View {
    let friends: [User] = User.sampleFriends

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(friends, id: \.id) { friend in
                        NavigationLink(value: friend) {
                            FriendCardView(user: friend) {
                                print("Challenge sent to \(friend.username)")
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.top)
            }
            .navigationDestination(for: User.self) { friend in
                FriendDetailView(friend: )
            }
            .navigationTitle("Your Friends")
            .background(Color(.systemGroupedBackground))
        }
    }
}

#Preview {
    FriendsListView()
}
