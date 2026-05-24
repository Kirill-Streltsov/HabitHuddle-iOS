//
//  ChallengeDetailViewModel.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 28.06.25.
//

import SwiftUI

extension ChallengeCheckInsListView {
    @MainActor
    final class ViewModel: ObservableObject {
        @Published var initiatorDates = [Date]()
        @Published var receiverDates = [Date]()

        private let network: any NetworkManagerProtocol

        init(network: any NetworkManagerProtocol = NetworkManager.shared) {
            self.network = network
        }

        func getCheckInDates(forInitiator initiatorHabitID: UUID?, forReceiver receiverHabitID: UUID?) async {
            async let initiatorFetch = fetchDates(for: initiatorHabitID)
            async let receiverFetch = fetchDates(for: receiverHabitID)
            (initiatorDates, receiverDates) = await (initiatorFetch, receiverFetch)
        }

        private func fetchDates(for habitID: UUID?) async -> [Date] {
            guard let habitID else { return [] }
            do {
                let checkIns = try await network.request(
                    endpoint: .getHabitCheckIns(for: habitID),
                    method: .get,
                    responseType: [HabitCheckInDTO].self)
                return checkIns.map(\.date)
            } catch {
                print("❌ Error: Couldn't load check-ins for habit \(habitID): \(error)")
                return []
            }
        }
    }
}
