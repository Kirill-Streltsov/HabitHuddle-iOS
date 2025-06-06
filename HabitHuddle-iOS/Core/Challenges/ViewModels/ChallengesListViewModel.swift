//
//  ChallengesListViewModel.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 04.06.25.
//

import SwiftUI

extension ChallengesListView {
    @MainActor
    final class ViewModel: ObservableObject {
        
        @Published var challenges: [ChallengeDTO] = []
        
        func getChallenges(for userID: UUID) async {
            do {
                let fetchedChallenges = try await NetworkManager.shared.request(
                    endpoint: .getChallenges(for: userID),
                    method: .get,
                    responseType: [ChallengeDTO].self)
                challenges = fetchedChallenges
            } catch {
                print("COULDN'T FETCH CHALLENGES for \(userID): \(error.localizedDescription)")
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
        
        func acceptChallenge(with id: UUID) async {
            do {
                let response = try await NetworkManager.shared.requestStatusCode(
                    endpoint: .acceptChallenge(id: id),
                    method: .post)
                print("RESPONSE FOR ACCEPT CHALLENGE: \(response)")
            } catch {
                print("COULDN'T ACCEPT CHALLENGE")
            }
        }
        
        func rejectChallenge(with id: UUID) async {
            do {
                let response = try await NetworkManager.shared.requestStatusCode(
                    endpoint: .rejectChallenge(id: id),
                    method: .post)
                print("RESPONSE FOR REJECT CHALLENGE: \(response)")
            } catch {
                print("COULDN'T ACCEPT CHALLENGE")
            }
        }
    }
}
