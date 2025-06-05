//
//  ChallengeProgressCardViewModel.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 05.06.25.
//

import Foundation
extension ChallengeProgressCardView {
    @MainActor
    final class ViewModel: ObservableObject {
        
        @Published var initiator: UserDTO = UserDTO(id: UUID(), username: "", name: "", createdAt: .now, updatedAt: .now)
        @Published var receiver: UserDTO = UserDTO(id: UUID(), username: "", name: "", createdAt: .now, updatedAt: .now)
        
        func getInitator(with userID: UUID) async {
            do {
                let fetchedInitiator = try await NetworkManager.shared.request(
                    endpoint: .getUser(with: userID),
                    method: .get,
                    responseType: UserDTO.self)
                initiator = fetchedInitiator
            } catch {
                print("COULDN'T GET THE INITIATOR")
            }
        }
        
        func getReceiver(with userID: UUID) async {
            do {
                let fetchedReceiver = try await NetworkManager.shared.request(
                    endpoint: .getUser(with: userID),
                    method: .get,
                    responseType: UserDTO.self)
                receiver = fetchedReceiver
            } catch {
                print("COULDN'T GET THE INITIATOR")
            }
        }
    }
}
