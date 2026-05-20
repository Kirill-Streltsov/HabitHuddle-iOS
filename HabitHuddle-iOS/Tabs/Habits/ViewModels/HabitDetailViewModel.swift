//
//  HabitDetailViewModel.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 25.05.25.
//

import SwiftData
import SwiftUI

extension HabitDetailView {
    @MainActor
    final class ViewModel: ObservableObject {
        @Published var name: String = ""
        @Published var icon: String? = nil
        @Published var description: String = ""

        @Published var hasCheckedIn: Bool = false
        @Published var duration: HabitDuration = .twoWeeks

        @Published var category: String = ""

        @Published var isSynced: Bool = false
        @Published var isPublic: Bool = false

        @Published var hasReminder: Bool = false
        @Published var reminderTime: Date = .init()

        @Published var openAIAnswer = ""
        @Published var isLoadingAIResponse = false

        @AppStorage("deviceToken") private var deviceToken: String = ""
        @AppStorage("hasSentDeviceToken") private var hasSentDeviceToken: Bool = false

        var habit: Habit?

        private let network: any NetworkManagerProtocol

        init(network: any NetworkManagerProtocol = NetworkManager.shared) {
            self.network = network
        }

        func createHabit(with id: UUID) async -> Result<HabitDTO, HHError> {
            do {
                let reminder: Date? = hasReminder ? reminderTime : nil
                let payload = HabitPayload(
                    id: id,
                    name: name,
                    description: description,
                    isPublic: isPublic,
                    category: category,
                    icon: icon,
                    duration: duration.rawValue,
                    reminderTime: reminder,
                    checkIns: [],
                    challenges: []
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

        func updateHabit(with id: UUID) async -> Result<HabitDTO, HHError> {
            do {
                guard let habit = habit else { return .failure(.notFound) }
                let reminder: Date? = hasReminder ? reminderTime : nil
                let payload = HabitPayload(
                    id: id,
                    name: name,
                    description: description,
                    isPublic: isPublic,
                    category: category,
                    icon: icon,
                    duration: duration.rawValue,
                    reminderTime: reminder,
                    checkIns: habit.checkIns.map { LightweightCheckIn(id: $0.id, date: $0.date) },
                    challenges: []
                )
                let habitResponse = try await network.request(
                    endpoint: .updateHabit(with: id),
                    method: .put,
                    body: payload,
                    responseType: HabitDTO.self
                )
                return .success(habitResponse)
            } catch {
                return .failure(.networkError(error))
            }
        }

        func checkIntoHabit(with id: UUID) async -> Result<HTTPStatus, HHError> {
            do {
                let checkInResponse = try await network.requestStatusCode(
                    endpoint: .checkIntoHabit(with: id),
                    method: .post
                )
                return .success(checkInResponse)
            } catch {
                return .failure(.networkError(error))
            }
        }

        func deleteHabit(with id: UUID) async -> Result<HabitDTO, HHError> {
            do {
                let deletedHabitResponse = try await network.request(
                    endpoint: .deleteHabit(with: id),
                    method: .delete,
                    responseType: HabitDTO.self
                )
                return .success(deletedHabitResponse)
            } catch {
                return .failure(.networkError(error))
            }
        }

        func askAI(about habit: Habit) async {
            isLoadingAIResponse = true
            do {
                let description = habit.habitDescription.isEmpty ? "no description" : habit.habitDescription
                let openAIResult = try await network.request(
                    endpoint: .askOpenAI(habitName: habit.name, habitDescription: description, habitDuration: habit.duration.numberOfDays),
                    method: .post,
                    responseType: AIResponse.self
                )
                openAIAnswer = openAIResult.message
                isLoadingAIResponse = false
            } catch {
                isLoadingAIResponse = false
                if TokenManager.token == nil {
                    openAIAnswer = "You have to log in to use AI"
                } else {
                    openAIAnswer = "AI is not available at this moment. Try again later..."
                }
            }
        }

        func updateUser(user: LocalUser) async {
            do {
                let status = try await network.requestStatusCode(
                    endpoint: .updateUser(),
                    method: .put,
                    body: UserPayload(
                        id: user.id,
                        username: user.username,
                        name: user.name,
                        password: nil,
                        deviceToken: deviceToken)
                )
                if status == .ok && !deviceToken.isEmpty {
                    hasSentDeviceToken = true
                }
                print("✅ Successfully updated user data: \(status)")
            } catch {
                print("❌ Error: Couldn't update user data: \(error)")
            }
        }
    }
}
