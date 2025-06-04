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
            print("STARTED LOOKING FOR FRIENDS")
            do {
                let fetchedFriends = try await NetworkManager.shared.request(
                    endpoint: .getMyFriends(),
                    method: .get,
                    responseType: [UserDTO].self)
                friends = fetchedFriends
                print("FOUND FRIENDS: \(friends)")
            } catch {
                print("COULDN'T FETCH FRIENDS")
            }
        }
        
        func sendChallenge(to userID: UUID, for habitID: UUID, of type: ChallengeType, with startDate: Date, and endDate: Date) async {
            let payload = ChallengeRequest(
                receiverID: userID,
                habitID: habitID,
                startDate: startDate,
                endDate: endDate,
                type: type)
            do {
                let sentChallenge = try await NetworkManager.shared.request(
                    endpoint: .sendChallenge(),
                    method: .post,
                    body: payload,
                    responseType: ChallengeDTO.self)
                print("JUST SENT A CHALLENGE: \(sentChallenge)")
            } catch {
                print("COULDN'T SEND CHALLENGE")
            }
        }
    }
}
