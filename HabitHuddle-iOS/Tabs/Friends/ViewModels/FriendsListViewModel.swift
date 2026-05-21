//
//  FriendsListViewModel.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 02.06.25.
//

import SwiftUI

extension MyFriendsView {
    @MainActor
    final class ViewModel: ObservableObject {

        @Published var results: [UserDTO] = []
        @Published var friendRequests: [UserDTO] = []
        @Published var isLoading = false
        @Published var errorMessage: String?

        private let network: any NetworkManagerProtocol
        private var searchTask: Task<Void, Never>?

        init(network: any NetworkManagerProtocol = NetworkManager.shared) {
            self.network = network
        }

        func searchUsers(query: String) {
            searchTask?.cancel()

            guard query.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2 else {
                self.results = []
                return
            }

            let network = network
            searchTask = Task {
                do {
                    try await Task.sleep(nanoseconds: 300 * 1_000_000)

                    guard !Task.isCancelled else { return }

                    isLoading = true
                    errorMessage = nil

                    let users = try await network.request(
                        endpoint: .searchForUser(username: query),
                        method: .get,
                        responseType: [UserDTO].self)

                    results = users
                } catch is CancellationError {
                    // Do nothing – task was cancelled
                } catch {
                    results = []
                    errorMessage = String(localized: .failedToFetchUsersLoginOrRegisterToAddFriends)
                }

                isLoading = false
            }
        }

        func getMyFriendRequests() async {
            do {
                let friends = try await network.request(
                    endpoint: .getFriendshipRequests(),
                    method: .get,
                    responseType: [UserDTO].self)
                friendRequests = friends
            } catch {
                print("❌ Error: Couldn't get friendship requests: \(error)")
            }
        }

        func requestFriend(with id: UUID) async {
            do {
                let payload = MakeFriendsRequest(friendID: id)
                let requestStatus = try await network.requestStatusCode(
                    endpoint: .requestFriend(),
                    method: .post,
                    body: payload)
                print("✅ Requested friend. Status code: \(requestStatus)")
            } catch {
                errorMessage = "❌ Error: Couldn't request friendship: \(error)"
            }
        }

        func acceptFriend(with id: UUID) async -> Result<UserDTO, HHError> {
            do {
                let acceptedFriend = try await network.request(
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
                let rejectFriendResponse = try await network.requestStatusCode(
                    endpoint: .rejectFriend(with: id),
                    method: .post)
                return .success(rejectFriendResponse)
            } catch {
                return .failure(.decodingError(error))
            }
        }
    }
}
