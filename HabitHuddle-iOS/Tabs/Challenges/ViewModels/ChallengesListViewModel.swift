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

        @Published var pendingChallengesSent: [ChallengeDTO] = []
        @Published var pendingChallengesReceived: [ChallengeDTO] = []
        @Published var acceptedChallenges: [ChallengeDTO] = []
        @Published var declinedChallenges: [ChallengeDTO] = []

        var userID: UUID
        private let network: any NetworkManagerProtocol

        init(userID: UUID, network: any NetworkManagerProtocol = NetworkManager.shared) {
            self.userID = userID
            self.network = network
        }

        func getChallenges(for userID: UUID) async {
            self.userID = userID
            do {
                let fetchedChallenges = try await network.request(
                    endpoint: .getChallenges(for: userID),
                    method: .get,
                    responseType: [ChallengeDTO].self)
                challenges = fetchedChallenges
                updateChallengeData()
            } catch {
                print("❌ Error: Couldn't fetch challenges for \(userID): \(error.localizedDescription)")
            }
        }

        func acceptChallenge(with id: UUID) async -> Result<HTTPStatus, HHError> {
            do {
                let response = try await network.requestStatusCode(
                    endpoint: .acceptChallenge(id: id),
                    method: .post)
                print("✅ Accepted the challenge with id: \(id)")
                return .success(response)
            } catch {
                print("❌ Error: Couldn't accept the challenge with id: \(id)")
                return .failure(.networkError(error))
            }
        }

        func rejectChallenge(with id: UUID) async -> Result<HTTPStatus, HHError> {
            do {
                let response = try await network.requestStatusCode(
                    endpoint: .rejectChallenge(id: id),
                    method: .post)
                print("✅ Rejected the challenge with id: \(id)")
                return .success(response)
            } catch {
                print("❌ Error: Couldn't reject the challenge with id: \(id)")
                return .failure(.networkError(error))
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

        func getHabitFromChallenge(with habitID: UUID) async -> Result<HabitDTO, HHError> {
            do {
                let habit = try await network.request(
                    endpoint: .getHabit(with: habitID),
                    method: .get,
                    responseType: HabitDTO.self)
                return .success(habit)
            } catch {
                print("❌ Error: Couln't get habit with id: \(habitID)")
                return .failure(.networkError(error))
            }
        }

        func createHabitAfterAcceptingChallenge(habitDTO: HabitDTO, for challengeID: UUID) async -> Result<HabitDTO, HHError> {
            do {
                let payload = HabitPayload(
                    id: habitDTO.id,
                    name: habitDTO.name,
                    description: habitDTO.description,
                    isPublic: true,
                    category: habitDTO.category,
                    icon: habitDTO.icon,
                    duration: habitDTO.duration.rawValue,
                    reminderTime: habitDTO.reminderTime,
                    checkIns: [],
                    challenges: [LightweightChallenge(id: challengeID)]
                )
                let habitResponse = try await network.request(
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

        func updateChallengeData() {
            pendingChallengesSent = challenges.filter({ $0.status == .pending && $0.receiver.user.id != userID })
            pendingChallengesReceived = challenges.filter({ $0.status == .pending && $0.receiver.user.id == userID })
            acceptedChallenges = challenges.filter({ $0.status == .accepted })
            declinedChallenges = challenges.filter({ $0.status == .declined })
        }
    }
}
