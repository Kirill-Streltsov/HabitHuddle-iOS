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
        @Published var duration: HabitDuration = .oneWeek
        @Published var hasReminder: Bool = false
        @Published var reminderTime: Date = .init()

        func createHabit(with id: UUID) async -> Result<CodableHabit, APIError> {
            do {
                let reminder: Date? = hasReminder ? reminderTime : nil

                let payload = HabitPayload(
                    id: id,
                    name: name,
                    description: description,
                    duration: duration.rawValue,
                    reminderTime: reminder
                )

                let habitResponse = try await NetworkingManager.shared.request(
                    endpoint: .createHabit(),
                    method: .post,
                    body: payload,
                    responseType: CodableHabit.self
                )
                return .success(habitResponse)
            } catch let error as APIError {
                return .failure(error)
            } catch {
                return .failure(.unknown)
            }
        }

        func updateHabit(with id: UUID) async -> Result<CodableHabit, APIError> {
            do {
                let reminder: Date? = hasReminder ? reminderTime : nil

                let payload = HabitPayload(
                    id: id,
                    name: name,
                    description: description,
                    duration: duration.rawValue,
                    reminderTime: reminder
                )

                let habitResponse = try await NetworkingManager.shared.request(
                    endpoint: .updateHabit(with: id),
                    method: .put,
                    body: payload,
                    responseType: CodableHabit.self
                )
                return .success(habitResponse)
            } catch let error as APIError {
                return .failure(error)
            } catch {
                return .failure(.unknown)
            }
        }

        func checkIntoHabit(with id: UUID) async -> Result<HTTPStatus, APIError> {
            do {
                let checkInResponse = try await NetworkingManager.shared.requestStatusCode(
                    endpoint: .checkIntoHabit(with: id),
                    method: .post
                )
                return .success(.ok)
            } catch let error as APIError {
                return .failure(error)
            } catch {
                return .failure(.unknown)
            }
        }

        func deleteHabit(with id: UUID) async -> Result<CodableHabit, APIError> {
            do {
                let deletedHabitResponse = try await NetworkingManager.shared.request(
                    endpoint: .deleteHabit(with: id),
                    method: .delete,
                    responseType: CodableHabit.self
                )
                return .success(deletedHabitResponse)
            } catch let error as APIError {
                return .failure(error)
            } catch {
                return .failure(.unknown)
            }
        }
    }
}
