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
        
        @Published var results: [CodableUser] = []
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
        
        func addFriend(with id: UUID) async -> Result<HTTPStatus, APIError> {
            do {
                let payload = MakeFriendsRequest(friendID: id)
                let addFriendResponse = try await NetworkingManager.shared.requestStatusCode(
                    endpoint: .addFriend(with: id),
                    method: .post,
                    body: payload)
                return .success(.ok)
            } catch {
                print("DIDN'T ADD FRIEND")
                return .failure(.decodingError(error))
            }
        }
    }
}
