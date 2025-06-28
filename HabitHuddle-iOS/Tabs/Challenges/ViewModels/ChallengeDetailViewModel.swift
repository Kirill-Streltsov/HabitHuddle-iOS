//
//  ChallengeDetailViewModel.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 28.06.25.
//

import SwiftUI

extension ChallengeDetailView {
    @MainActor
    final class ViewModel: ObservableObject {
        @Published var initiatorDates = [Date]()
        @Published var receiverDates = [Date]()
        
        func getCheckInDates(for initiatorHabitID: UUID, and receiverHabitID: UUID) async {
            do {
                async let initiatorCheckInDates = try NetworkManager.shared.request(
                    endpoint: .getHabitCheckIns(for: initiatorHabitID),
                    method: .get,
                    responseType: [HabitCheckInDTO].self)
                
                async let receiverCheckInDates = try NetworkManager.shared.request(
                    endpoint: .getHabitCheckIns(for: receiverHabitID),
                    method: .get,
                    responseType: [HabitCheckInDTO].self)
                
                (initiatorDates, receiverDates) = try await (initiatorCheckInDates.map{$0.date}, receiverCheckInDates.map{$0.date})
            } catch {
                print("❌ Error: Couldn't load the habit check ins for the challenge")
            }
        }
    }
}
