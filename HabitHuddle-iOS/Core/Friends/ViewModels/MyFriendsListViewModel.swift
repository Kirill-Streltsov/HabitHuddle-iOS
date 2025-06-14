//
//  MyFriendsListViewModel.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 04.06.25.
//

import Foundation

extension MyFriendsListView {
    @MainActor
    final class ViewModel: ObservableObject {
        
        @Published var friends: [UserDTO] = []
        
        func getMyFriends() async {
            do {
                let fetchedFriends = try await NetworkManager.shared.request(
                    endpoint: .getMyFriends(),
                    method: .get,
                    responseType: [UserDTO].self)
                friends = fetchedFriends
            } catch {
                print("❌ Couldn't fetch friends: \(error.localizedDescription)")
            }
        }
        
        func sendChallenge(to userID: UUID, for habitID: UUID, ofType type: ChallengeType) async {
            let payload = ChallengeRequest(
                receiverID: userID,
                initiatorHabitID: habitID,
                receiverHabitID: nil,
                type: type)
            do {
                let sentChallenge = try await NetworkManager.shared.request(
                    endpoint: .sendChallenge(),
                    method: .post,
                    body: payload,
                    responseType: ChallengeDTO.self)
                print("✅ Just sent a challenge: \(sentChallenge)")
            } catch {
                print("❌ Couldn't send challenge: \(error)")
            }
        }
    }
}
