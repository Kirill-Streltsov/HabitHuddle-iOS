//
//  FriendDetailViewModel.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 03.06.25.
//

import SwiftUI

extension FriendDetailView {
    @MainActor
    final class ViewModel: ObservableObject {

        @Published var habits: [HabitDTO] = []
        @Published var challenges: [ChallengeDTO] = []

        private let network: any NetworkManagerProtocol

        init(network: any NetworkManagerProtocol = NetworkManager.shared) {
            self.network = network
        }

        func getUserHabits(for id: UUID) async {
            do {
                let fetchedHabits = try await network.request(
                    endpoint: .getUserHabits(for: id),
                    method: .get,
                    responseType: [HabitDTO].self)
                habits = fetchedHabits
            } catch {
                print("❌ Error: Something went wrong while fetching habits of a friend: \(error.localizedDescription)")
            }
        }

        func getUserChallenges(for id: UUID) async {
            do {
                let fetchedChallenges = try await network.request(
                    endpoint: .getChallenges(for: id),
                    method: .get,
                    responseType: [ChallengeDTO].self)
                challenges = fetchedChallenges
            } catch {
                print("❌ Error: Could not decode user challenges: \(error.localizedDescription)")
            }
        }

        func deleteFriend(with id: UUID) async -> Result<HTTPStatus, HHError> {
            do {
                let statusCode = try await network.requestStatusCode(
                    endpoint: .deleteFriend(with: id),
                    method: .delete)
                print("✅ Deleted friend with id: \(id)")
                return .success(statusCode)
            } catch {
                print("❌ Could not delete friend with id: \(id)")
                return .failure(.networkError(error))
            }
        }

        func sendBoost(to friendID: UUID, about habitID: UUID) async {
            do {
                let status = try await network.requestStatusCode(endpoint: .boostFriend(friendID, about: habitID), method: .post)
                print("✅ Sent a boost to friend \(friendID): \(status)")
            } catch {
                print("❌ Error: Couldn't send a boost to friend \(friendID): \(error)")
            }
        }
    }
}
