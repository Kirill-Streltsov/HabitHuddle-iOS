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
        @Published var hasReminder: Bool = false
        @Published var reminderTime: Date = .init()
        @Published var openAIAnswer = ""
        var habit: Habit?

        func createHabit(with id: UUID) async -> Result<HabitDTO, HHError> {
            do {
                let reminder: Date? = hasReminder ? reminderTime : nil

                let payload = HabitPayload(
                    id: id,
                    name: name,
                    description: description,
                    icon: icon,
                    duration: duration.rawValue,
                    reminderTime: reminder,
                    checkIns: [],
                    challenges: []
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
                    icon: icon,
                    duration: duration.rawValue,
                    reminderTime: reminder,
                    checkIns: habit.checkIns.map { LightweightCheckIn(id: $0.id, date: $0.date) },
                    challenges: []
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
        
        func askAI(about habit: Habit) async {
            let openAIResult = await NetworkManager.shared.askOpenAI(prompt: buildMotivationalPrompt(for: habit))
            Helpers.handleResult(openAIResult) { openAIMessage in
                openAIAnswer = ""
                openAIAnswer = openAIMessage
            }
        }
        
        func buildMotivationalPrompt(for habit: Habit) -> String {
            return """
            I will provide you with a habit description. Please respond in a friendly and natural manner as follows:

            - List scientifically proven benefits of this habit as concise bullet points.
            - If there are no proven benefits or if the habit may be harmful, clearly state: "There are no scientifically proven benefits for this habit" or "This habit could be potentially harmful."
            - Then write a motivational message to encourage the user, explaining how they will feel after successfully doing this habit for \(habit.duration.numberOfDays) days.

            Do not write a label like "Motivational Message:" in your response. You may write something like "What could motivate you". You can also write "Benefits" or "Scientifically proven benefits". Just write the bullet points and then motivation as a continuous, natural text.

            Here is the habit name: \(habit.name)
            Here is the habit description: \(habit.habitDescription)
            """
        }
    }
}
