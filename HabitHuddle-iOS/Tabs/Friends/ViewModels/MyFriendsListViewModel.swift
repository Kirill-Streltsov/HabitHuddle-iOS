//
//  MyFriendsListViewModel.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 04.06.25.
//

import Foundation

extension MyFriendsList {
    @MainActor
    final class ViewModel: ObservableObject {

        @Published var friends: [UserDTO] = []

        private let network: any NetworkManagerProtocol

        init(network: any NetworkManagerProtocol = NetworkManager.shared) {
            self.network = network
        }

        func getMyFriends() async {
            do {
                let fetchedFriends = try await network.request(
                    endpoint: .getMyFriends(),
                    method: .get,
                    responseType: [UserDTO].self)
                friends = fetchedFriends
            } catch {
                print("❌ Error: Couldn't fetch friends: \(error.localizedDescription)")
            }
        }

        func sendChallenge(to userID: UUID, for habitID: UUID, ofType type: ChallengeType) async {
            let payload = ChallengeRequest(
                receiverID: userID,
                initiatorHabitID: habitID,
                receiverHabitID: nil,
                type: type)
            do {
                let status = try await network.requestStatusCode(
                    endpoint: .sendChallenge(),
                    method: .post,
                    body: payload)
                print("✅ Just sent a challenge. Status: \(status)")
            } catch {
                print("❌ Error: Couldn't send challenge: \(error)")
            }
        }
    }
}
