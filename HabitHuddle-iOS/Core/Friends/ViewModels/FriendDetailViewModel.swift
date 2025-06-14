//
//  FriendDetailViewModel.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 03.06.25.
//

import SwiftUI

extension FriendDetailView {
    @MainActor
    final class ViewModel: ObservableObject {
        
        @Published var habits: [HabitDTO] = []
        @Published var challenges: [ChallengeDTO] = []
        
        func getUserHabits(for id: UUID) async {
            do {
                let fetchedHabits = try await NetworkManager.shared.request(
                    endpoint: .getUserHabits(for: id),
                    method: .get,
                    responseType: [HabitDTO].self)
                habits = fetchedHabits
            } catch {
                print("❌ Something went wrong while fetching habits of a friend: \(error.localizedDescription)")
            }
        }
        
        func getUserChallenges(for id: UUID) async {
            do {
                let fetchedChallenges = try await NetworkManager.shared.request(
                    endpoint: .getChallenges(for: id),
                    method: .get,
                    responseType: [ChallengeDTO].self)
                challenges = fetchedChallenges
            } catch {
                print("❌ Could not decode user challenges: \(error.localizedDescription)")
            }
        }
    }
}
