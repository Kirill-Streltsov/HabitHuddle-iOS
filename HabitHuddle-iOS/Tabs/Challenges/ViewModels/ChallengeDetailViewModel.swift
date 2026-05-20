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

        func getCheckInDates(for initiatorHabitID: UUID, and receiverHabitID: UUID) async {
            do {
                async let initiatorCheckInDates = try network.request(
                    endpoint: .getHabitCheckIns(for: initiatorHabitID),
                    method: .get,
                    responseType: [HabitCheckInDTO].self)

                async let receiverCheckInDates = try network.request(
                    endpoint: .getHabitCheckIns(for: receiverHabitID),
                    method: .get,
                    responseType: [HabitCheckInDTO].self)

                (initiatorDates, receiverDates) = try await (initiatorCheckInDates.map { $0.date }, receiverCheckInDates.map { $0.date })
            } catch {
                print("❌ Error: Couldn't load the habit check ins for the challenge")
            }
        }
    }
}
