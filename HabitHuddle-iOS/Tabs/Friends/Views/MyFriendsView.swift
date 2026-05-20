//
//  FriendsListView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 02.06.25.
//

import SwiftUI

struct MyFriendsView: View {
    
    @Environment(\.modelContext) private var context
    @StateObject private var viewModel = ViewModel()
    
    @EnvironmentObject private var appState: AppState
    
    @FocusState private var searchIsFocused: Bool
    
    @State private var searchText = ""
    @State private var requestIsSent = false
    @State private var friendsListID = UUID()
    
    @State private var showToast = false
    @State private var toastMessage = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    VStack {
                        if appState.isAuthenticated {
                            searchBar
                            Divider()
                                .padding(.vertical, 4)
                        }
                    }

                    Group {
                        if searchText.count >= 2 {
                            searchingStateView
                        } else {
                            LazyVStack(spacing: 16) {
                                friendRequests
                                MyFriendsList(isInFriendsTab: true)
                                    .id(friendsListID)
                                    .padding(.bottom, 24)
                            }
                        }
                    }
                }
            }
            .toast(isPresented: $showToast, message: toastMessage, icon: "person.2")
            .background(Color(.systemGroupedBackground))
            .navigationTitle(String(localized: .friends))
            .task {
                await viewModel.getMyFriendRequests()
                friendsListID = UUID()
            }
            .refreshable {
                await viewModel.getMyFriendRequests()
                friendsListID = UUID()
            }
        }
    }
    
    private var searchBar: some View {
        TextField("Search usernames...", text: $searchText)
            .focused($searchIsFocused)
            .padding(12)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
            .padding(.horizontal)
            .padding(.top)
            .onChange(of: searchText) { _, newValue in
                if newValue.count >= 2 {
                    viewModel.searchUsers(query: newValue)
                }
            }
    }
    
    private var friendRequests: some View {
        Group {
            // Friend requests on top
            if !viewModel.friendRequests.isEmpty {
                Section(header: Text(.friendRequests)
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                ) {
                    ForEach(viewModel.friendRequests) { request in
                        FriendRequestCardView(user: request) {
                            Task {
                                let result = await viewModel.acceptFriend(with: request.id)
                                Helpers.handleResult(result) { friend in
                                    showToast = true
                                    toastMessage = String(localized: .friendRequestAccepted)
                                    Task {
                                        await viewModel.getMyFriendRequests()
                                    }
                                    friendsListID = UUID()
                                    let user = User(id: friend.id, username: friend.username, name: friend.name, createdAt: friend.createdAt, updatedAt: friend.updatedAt, habits: [])
                                    context.insert(user)
                                    context.saveOrLog()
                                } onFailure: { _ in
                                    print("❌ Error: Couldn't accept friend")
                                }
                            }
                        } onIgnore: {
                            Task {
                                showToast = true
                                toastMessage = String(localized: .friendRequestIgnored)
                                let _ = await viewModel.rejectFriend(with: request.id)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
    }
    
    private var searchingStateView: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Searching...")
                    .padding()
            } else if let errorMessage = viewModel.errorMessage {
                NoConnectionView(errorMessage: errorMessage)
                    .onAppear {
                        Task {
                            try? await Task.sleep(for: .seconds(5))
                            withAnimation { viewModel.errorMessage = nil }
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
                                    showToast = true
                                    toastMessage = String(localized: .friendRequestSent)
                                    await viewModel.requestFriend(with: user.id)
                                    searchText = ""
                                    searchIsFocused = false
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
    MyFriendsView()
}
