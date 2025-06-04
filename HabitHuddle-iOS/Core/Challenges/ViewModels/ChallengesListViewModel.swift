//
//  ChallengesListViewModel.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 04.06.25.
//

import SwiftUI

extension ChallengesListView {
    @MainActor
    final class ViewModel: ObservableObject {
        
        @Published var challenges: [ChallengeDTO] = []
        
    }
}
