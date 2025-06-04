//
//  MyFriendsListView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 04.06.25.
//

import SwiftUI

struct MyFriendsListView: View {
    
    @EnvironmentObject private var viewModel: FriendsListView.ViewModel
    
    var body: some View {
        Group {
            // Friends list below
            if !viewModel.friends.isEmpty {
                Section(header: Text("Your Friends")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                ) {
                    ForEach(viewModel.friends) { friend in
                        NavigationLink {
                            FriendDetailView(friend: friend)
                        } label: {
                            FriendCardView(friend: friend, onChallenge: {})
                        }
                        .buttonStyle(.plain)
                    }
                }
            } else {
                EmptyFriendsView()
            }
        }
    }
}

#Preview {
    MyFriendsListView()
}
