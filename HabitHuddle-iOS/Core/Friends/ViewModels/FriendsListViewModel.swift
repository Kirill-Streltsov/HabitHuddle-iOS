//
//  FriendsListViewModel.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 02.06.25.
//

import SwiftUI

extension FriendsListView {
    @MainActor
    final class ViewModel: ObservableObject {
        
        @Published var friends: [CodableUser] = []
        @Published var results: [CodableUser] = []
        @Published var friendRequests: [CodableUser] = []
        @Published var isLoading = false
        @Published var errorMessage: String?
        
        private var searchTask: Task<Void, Never>?
        
        func searchUsers(query: String) {
            // Cancel previous search task if it's still running
            searchTask?.cancel()
            
            guard query.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2 else {
                self.results = []
                return
            }
            
            searchTask = Task {
                do {
                    try await Task.sleep(nanoseconds: 300 * 1_000_000) // 300ms debounce
                    
                    guard !Task.isCancelled else { return }
                    
                    isLoading = true
                    errorMessage = nil
                    
                    let users = try await NetworkingManager.shared.request(
                        endpoint: .searchForUser(username: query),
                        method: .get,
                        responseType: [CodableUser].self)
                    
                    results = users
                } catch is CancellationError {
                    // Do nothing – task was cancelled
                } catch {
                    results = []
                    errorMessage = "Failed to fetch users: \(error.localizedDescription)"
                }
                
                isLoading = false
            }
        }
        
        func getMyFriends() async {
            do {
                let fetchedFriends = try await NetworkingManager.shared.request(
                    endpoint: .getMyFriends(),
                    method: .get,
                    responseType: [CodableUser].self)
                friends = fetchedFriends
            } catch {
                print("COULDN'T FETCH FRIENDS")
            }
        }
        
        func getMyFriendRequests() async {
            do {
                let friends = try await NetworkingManager.shared.request(
                    endpoint: .getFriendshipRequests(),
                    method: .get,
                    responseType: [CodableUser].self)
                print("These are the friendship requests: \(friends)")
                friendRequests = friends
            } catch {
                print("Couldn't get friendship requests: \(error)")
            }
        }
        
        func requestFriend(with id: UUID) async -> Result<HTTPStatus, APIError> {
            do {
                let payload = MakeFriendsRequest(friendID: id)
                let requestFriendResponse = try await NetworkingManager.shared.requestStatusCode(
                    endpoint: .requestFriend(with: id),
                    method: .post,
                    body: payload)
                print("RESPONSE: \(requestFriendResponse)")
                return .success(.ok)
            } catch {
                print("DIDN'T REQUEST FRIEND")
                return .failure(.decodingError(error))
            }
        }
        
        func acceptFriend(with id: UUID) async -> Result<HTTPStatus, APIError> {
            do {
                let requestFriendResponse = try await NetworkingManager.shared.requestStatusCode(
                    endpoint: .acceptFriend(with: id),
                    method: .post)
                print("RESPONSE: \(requestFriendResponse)")
                return .success(.ok)
            } catch {
                print("DIDN'T ACCEPT FRIEND")
                return .failure(.decodingError(error))
            }
        }
        
        func rejectFriend(with id: UUID) async -> Result<HTTPStatus, APIError> {
            do {
                let payload = MakeFriendsRequest(friendID: id)
                let requestFriendResponse = try await NetworkingManager.shared.requestStatusCode(
                    endpoint: .rejectFriend(with: id),
                    method: .post)
                print("RESPONSE: \(requestFriendResponse)")
                return .success(.ok)
            } catch {
                print("DIDN'T REJECT FRIEND")
                return .failure(.decodingError(error))
            }
        }
    }
}
