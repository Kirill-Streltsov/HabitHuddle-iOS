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
    let friends: [User] = User.sampleFriends
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    // Search bar
                    TextField("Search usernames...", text: $searchText)
                        .padding(12)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .padding(.top)
                        .onChange(of: searchText) { _, newValue in
                            viewModel.searchUsers(query: newValue)
                        }
                    
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
                    } else if viewModel.results.isEmpty && searchText.count >= 2 {
                        Text("No users found.")
                            .foregroundStyle(.secondary)
                            .padding()
                    } else {
                        EmptyFriendsView()
//                        ForEach(viewModel.results) { user in
//                            FoundUserView(username: user.username, requestIsSent: $requestIsSent) {
//                                Task {
//                                    let result = await viewModel.addFriend(with: user.id)
//                                    handleResult(result) { result in
//                                        print("RESULT: \(result)")
//                                    } onFailure: { error in
//                                        print("RESULT ERROR: \(error)")
//                                    }
//                                }
//                            }
//                            .padding(.vertical, 6)
//                            .onAppear {
//                                print("USER ID: \(user.id)")
//                            }
//                        }
//                        .listStyle(PlainListStyle())
                    }
                    Spacer()
                }
            }
            //            ScrollView {
            //
            //                VStack(spacing: 16) {
            //                    ForEach(friends, id: \.id) { friend in
            //                        NavigationLink(value: friend) {
            //                            FriendCardView(user: friend) {
            //                                print("Challenge sent to \(friend.username)")
            //                            }
            //                        }
            //                        .buttonStyle(.plain)
            //                    }
            //                }
            //                .padding(.top)
            //            }
            //            .navigationDestination(for: User.self) { friend in
            //                FriendDetailView(friend: friend)
            //            }
            //            .navigationTitle("Your Friends")
            //            .background(Color(.systemGroupedBackground))
        }
    }
}

#Preview {
    FriendsListView()
}
