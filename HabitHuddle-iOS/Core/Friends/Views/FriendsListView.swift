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
    let friends: [User] = User.sampleFriends
    
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
                        viewModel.searchUsers(query: newValue)
                    }
                
                if viewModel.isLoading {
                    ProgressView("Searching...")
                        .padding()
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                } else if viewModel.results.isEmpty && searchText.count >= 2 {
                    Text("No users found.")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    List(viewModel.results) { user in
                        HStack(spacing: 12) {

                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .foregroundColor(.white)
                                )
                            
                            Text(user.username)
                                .font(.body)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            SlimButton(title: "Add Friend") {
                                Task {
                                    let result = await viewModel.addFriend(with: user.id)
                                    handleResult(result) { result in
                                        print("RESULT: \(result)")
                                    } onFailure: { error in
                                        print("RESULT ERROR: \(error)")
                                    }
                                }
                            }
                            .buttonStyle(.plain)

                        }
                        .padding(.vertical, 6)
                        .onAppear {
                            print("USER ID: \(user.id)")
                        }
                    }
                    .listStyle(PlainListStyle())
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
