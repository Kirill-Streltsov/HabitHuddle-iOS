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
        @Published private(set) var boostedHabitIDs: Set<UUID> = []

        private let network: any NetworkManagerProtocol

        init(network: any NetworkManagerProtocol = NetworkManager.shared) {
            self.network = network
            loadBoostedHabitIDs()
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

        /// Loads the challenges shared between the current user and this friend.
        ///
        /// The backend's `challenges/:userID` route only returns the *authenticated*
        /// user's own challenges — it 403s for any other userID — so we can't query
        /// the friend's ID directly. Instead we fetch our own list (which already
        /// includes every challenge we're a participant in) and keep the ones this
        /// friend is the other party to.
        func getChallenges(currentUserID: UUID, friendID: UUID) async {
            do {
                let fetchedChallenges = try await network.request(
                    endpoint: .getChallenges(for: currentUserID),
                    method: .get,
                    responseType: [ChallengeDTO].self)
                challenges = fetchedChallenges.filter {
                    $0.initiator.user.id == friendID || $0.receiver.user.id == friendID
                }
            } catch {
                print("❌ Error: Could not decode user challenges: \(error.localizedDescription)")
            }
        }

        func cancelChallenge(with id: UUID) async -> Result<HTTPStatus, HHError> {
            do {
                let status = try await network.requestStatusCode(
                    endpoint: .cancelChallenge(id: id),
                    method: .delete)
                return .success(status)
            } catch {
                print("❌ Error: Couldn't cancel challenge with id: \(id)")
                return .failure(.networkError(error))
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
                let status = try await network.requestStatusCode(
                    endpoint: .boostFriend(friendID, about: habitID),
                    method: .post)
                markBoosted(habitID)
                print("✅ Sent a boost to friend \(friendID): \(status)")
            } catch {
                print("❌ Error: Couldn't send a boost to friend \(friendID): \(error)")
            }
        }

        func sendChallenge(to receiverID: UUID, for receiverHabitID: UUID, durationDays: Int) async -> Bool {
            let payload = ChallengeRequest(
                receiverID: receiverID,
                initiatorHabitID: nil,
                receiverHabitID: receiverHabitID,
                durationDays: durationDays)
            do {
                _ = try await network.requestStatusCode(
                    endpoint: .sendChallenge(),
                    method: .post,
                    body: payload)
                await getUserHabits(for: receiverID)
                return true
            } catch {
                print("❌ Error: Couldn't send challenge for habit \(receiverHabitID): \(error)")
                return false
            }
        }

        func isBoosted(_ habitID: UUID) -> Bool {
            boostedHabitIDs.contains(habitID)
        }

        // MARK: - Boost persistence (resets daily)

        private func boostedHabitsKey() -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return "boostedHabits_\(formatter.string(from: .now))"
        }

        private func loadBoostedHabitIDs() {
            let ids = UserDefaults.standard.stringArray(forKey: boostedHabitsKey()) ?? []
            boostedHabitIDs = Set(ids.compactMap(UUID.init))
        }

        private func markBoosted(_ id: UUID) {
            var ids = UserDefaults.standard.stringArray(forKey: boostedHabitsKey()) ?? []
            ids.append(id.uuidString)
            UserDefaults.standard.set(ids, forKey: boostedHabitsKey())
            boostedHabitIDs.insert(id)
        }
    }
}
