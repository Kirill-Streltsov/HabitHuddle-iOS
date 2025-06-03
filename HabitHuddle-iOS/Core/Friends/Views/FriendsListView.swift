//
//  FriendsListView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 02.06.25.
//

import SwiftUI

struct FriendsListView: View {
    
    @StateObject private var viewModel = ViewModel()
    @State private var searchText = ""
    @State private var requestIsSent = false
    
    var body: some View {
        NavigationStack {
            VStack {
                // Search bar
                TextField("Search usernames...", text: $searchText)
                    .padding(12)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.top)
                    .onChange(of: searchText) { _, newValue in
                        // Only search if 2 or more chars
                        if newValue.count >= 2 {
                            viewModel.searchUsers(query: newValue)
                        }
                    }
                
                Divider()
                    .padding(.vertical, 4)
                
                // Content area
                Group {
                    if searchText.count >= 2 {
                        searchingStateView
                    } else {
                        if viewModel.friendRequests.isEmpty && viewModel.friends.isEmpty {
                            EmptyFriendsView()
                                .padding()
                        } else {
                            ScrollView {
                                LazyVStack(spacing: 16) {
                                    friendRequests
                                    friends
                                }
                                .padding(.top)
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Friends")
            .task {
                await viewModel.getMyFriendRequests()
                await viewModel.getMyFriends()
            }
        }
    }
    
    private var friends: some View {
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
            }
        }
    }
    
    private var friendRequests: some View {
        Group {
            // Friend requests on top
            if !viewModel.friendRequests.isEmpty {
                Section(header: Text("Friend Requests")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                ) {
                    ForEach(viewModel.friendRequests) { request in
                        FriendRequestCardView(user: request) {
                            Task { await viewModel.acceptFriend(with: request.id) }
                        } onIgnore: {
                            Task { await viewModel.rejectFriend(with: request.id) }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
    }
    
    private var searchingStateView: some View {
        Group {
            // --- SEARCHING MODE ---
            if viewModel.isLoading {
                ProgressView("Searching...")
                    .padding()
            } else if let errorMessage = viewModel.errorMessage {
                NoConnectionView(errorMessage: errorMessage)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            withAnimation {
                                viewModel.errorMessage = nil
                            }
                        }
                    }
            } else if viewModel.results.isEmpty {
                Text("No users found.")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ScrollView {
                    LazyVStack {
                        ForEach(viewModel.results) { user in
                            FoundUserView(
                                username: user.username,
                                requestIsSent: $requestIsSent
                            ) {
                                Task {
                                    await viewModel.requestFriend(with: user.id)
                                }
                            }
                            .padding(.vertical, 6)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

#Preview {
    FriendsListView()
}
