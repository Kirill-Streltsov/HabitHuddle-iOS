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
        @Published var description: String = ""
        @Published var hasCheckedIn: Bool = false
        @Published var duration: HabitDuration = .twoWeeks
        @Published var hasReminder: Bool = false
        @Published var reminderTime: Date = .init()
        var habit: Habit?

        func createHabit(with id: UUID) async -> Result<HabitDTO, HHError> {
            do {
                let reminder: Date? = hasReminder ? reminderTime : nil

                let payload = HabitPayload(
                    id: id,
                    name: name,
                    description: description,
                    duration: duration.rawValue,
                    reminderTime: reminder,
                    checkIns: []
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

        func updateHabit(with id: UUID) async -> Result<HabitDTO, HHError> {
            do {
                guard let habit = habit else { return .failure(.notFound) }
                let reminder: Date? = hasReminder ? reminderTime : nil

                let payload = HabitPayload(
                    id: id,
                    name: name,
                    description: description,
                    duration: duration.rawValue,
                    reminderTime: reminder,
                    checkIns: habit.checkIns.map { LightweightCheckIn(id: $0.id, date: $0.date) }
                )

                let habitResponse = try await NetworkManager.shared.request(
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
                let checkInResponse = try await NetworkManager.shared.requestStatusCode(
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
                let deletedHabitResponse = try await NetworkManager.shared.request(
                    endpoint: .deleteHabit(with: id),
                    method: .delete,
                    responseType: HabitDTO.self
                )
                return .success(deletedHabitResponse)
            } catch {
                return .failure(.networkError(error))
            }
        }        
    }
}
