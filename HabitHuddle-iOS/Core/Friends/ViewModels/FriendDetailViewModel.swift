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
        
        @Published var habits: [CodableHabit] = []
        
        func loadUserHabits(for id: UUID) async {
            do {
                let fetchedHabits = try await NetworkingManager.shared.request(
                    endpoint: .getUserHabits(for: id),
                    method: .get,
                    responseType: [CodableHabit].self)
                habits = fetchedHabits
            } catch {
                print("COULD NOT DECODE USER HABITS")
            }
        }
    }
}
