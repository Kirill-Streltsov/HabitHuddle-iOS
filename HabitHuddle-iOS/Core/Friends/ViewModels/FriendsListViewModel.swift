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
        
        @Published var results: [UserDTO] = []
        @Published var friendRequests: [UserDTO] = []
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
                    
                    let users = try await NetworkManager.shared.request(
                        endpoint: .searchForUser(username: query),
                        method: .get,
                        responseType: [UserDTO].self)
                    
                    results = users
                } catch is CancellationError {
                    // Do nothing – task was cancelled
                } catch {
                    results = []
                    errorMessage = "Failed to fetch users: login or register to add friends!"
                }
                
                isLoading = false
            }
        }
                
        func getMyFriendRequests() async {
            do {
                let friends = try await NetworkManager.shared.request(
                    endpoint: .getFriendshipRequests(),
                    method: .get,
                    responseType: [UserDTO].self)
                print("These are the friendship requests: \(friends)")
                friendRequests = friends
            } catch {
                print("Couldn't get friendship requests: \(error)")
            }
        }
        
        func requestFriend(with id: UUID) async -> Result<HTTPStatus, HHError> {
            do {
                let payload = MakeFriendsRequest(friendID: id)
                let requestFriendResponse = try await NetworkManager.shared.requestStatusCode(
                    endpoint: .requestFriend(with: id),
                    method: .post,
                    body: payload)
                return .success(requestFriendResponse)
            } catch {
                return .failure(.decodingError(error))
            }
        }
        
        func acceptFriend(with id: UUID) async -> Result<UserDTO, HHError> {
            
            //TODO: Add the same logic for the other side
            do {
                let acceptedFriend = try await NetworkManager.shared.request(
                    endpoint: .acceptFriend(with: id),
                    method: .post,
                    responseType: UserDTO.self)
                return .success(acceptedFriend)
            } catch {
                return .failure(.decodingError(error))
            }
        }
        
        func rejectFriend(with id: UUID) async -> Result<HTTPStatus, HHError> {
            do {
                let rejectFriendResponse = try await NetworkManager.shared.requestStatusCode(
                    endpoint: .rejectFriend(with: id),
                    method: .post)
                return .success(rejectFriendResponse)
            } catch {
                return .failure(.decodingError(error))
            }
        }
    }
}
