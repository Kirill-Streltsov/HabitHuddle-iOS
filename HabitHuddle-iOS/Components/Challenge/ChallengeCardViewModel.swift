//
//  ChallengeCardViewModel.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 05.06.25.
//

import Foundation

extension ChallengeCardView {
    @MainActor
    final class ViewModel: ObservableObject {
        @Published var initiatorName: String = ""
        
        func getInitator(with userID: UUID) async {
            do {
                let initiator = try await NetworkManager.shared.request(
                    endpoint: .getUser(with: userID),
                    method: .get,
                    responseType: UserDTO.self)
                initiatorName = initiator.name
            } catch {
                print("COULDN'T GET THE INITIATOR")
            }
        }
    }
}
