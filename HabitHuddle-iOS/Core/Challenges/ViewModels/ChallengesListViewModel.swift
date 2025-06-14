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
        
        func acceptChallenge(with id: UUID) async -> Result<HTTPStatus, HHError> {
            do {
                let response = try await NetworkManager.shared.requestStatusCode(
                    endpoint: .acceptChallenge(id: id),
                    method: .post)
                print("Accepted the challenge with id: \(id)")
                return .success(response)
            } catch {
                print("Couldn't accept the challenge with id: \(id)")
                return .failure(.networkError(error))
            }
        }
        
        func rejectChallenge(with id: UUID) async -> Result<HTTPStatus, HHError> {
            do {
                let response = try await NetworkManager.shared.requestStatusCode(
                    endpoint: .rejectChallenge(id: id),
                    method: .post)
                print("Rejected the challenge with id: \(id)")
                return .success(response)
            } catch {
                print("Couldn't reject the challenge with id: \(id)")
                return .failure(.networkError(error))
            }
        }
        
        func getHabitFromChallenge(with habitID: UUID) async -> Result<HabitDTO, HHError> {
            do {
                let habit = try await NetworkManager.shared.request(
                    endpoint: .getHabit(with: habitID),
                    method: .get,
                    responseType: HabitDTO.self)
                return .success(habit)
            } catch {
                print("COULDN'T GET HABIT WITH ID: \(habitID)")
                return .failure(.networkError(error))
            }
        }
        
        func createHabitAfterAcceptingChallenge(habitDTO: HabitDTO, for challengeID: UUID) async -> Result<HabitDTO, HHError> {
            do {
                let payload = HabitPayload(
                    id: habitDTO.id,
                    name: habitDTO.name,
                    description: habitDTO.description,
                    duration: habitDTO.duration.rawValue,
                    reminderTime: habitDTO.reminderTime,
                    checkIns: [],
                    challenges: [LightweightChallenge(id: challengeID)]
                )

                let habitResponse = try await NetworkManager.shared.request(
                    endpoint: .createHabit(),
                    method: .post,
                    body: payload,
                    responseType: HabitDTO.self
                )
                return .success(habitResponse)
            } catch {
                return .failure(.networkError(error))
            }
        }
    }
}
