//
//  HabitFormViewModel.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 25.05.25.
//

import SwiftData
import SwiftUI

extension HabitFormView {
    @MainActor
    final class ViewModel: ObservableObject {

        @Published var name: String = ""
        @Published var description: String = ""
        @Published var hasCheckedIn: Bool = false
        @Published var duration: HabitDuration = .oneMonth
        @Published var hasReminder: Bool = false
        @Published var reminderTime: Date = Date()


        func createHabit() async -> Result<CodableHabit, APIError> {
            do {
                let reminder: Date? = hasReminder ? reminderTime : nil

                let payload = HabitPayload(
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
        
        func updateHabit(habitID: UUID) async -> Result<CodableHabit, APIError> {
            do {
                let reminder: Date? = hasReminder ? reminderTime : nil

                let payload = HabitPayload(
                    name: name,
                    description: description,
                    duration: duration.rawValue,
                    reminderTime: reminder
                )

                let habitResponse = try await NetworkingManager.shared.request(
                    endpoint: .updateHabit(habitID: habitID),
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
        
        func checkIntoHabit(habitID: UUID) async -> Result<HTTPStatus, APIError> {
            do {
                let checkInResponse = try await NetworkingManager.shared.requestStatusCode(
                    endpoint: .checkIntoHabit(habitID: habitID),
                    method: .post
                )
                return .success(checkInResponse)
            } catch let error as APIError {
                return .failure(error)
            } catch {
                return .failure(.unknown)
            }
        }
    }
}
