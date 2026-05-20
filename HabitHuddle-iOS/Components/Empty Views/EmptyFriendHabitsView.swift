//
//  EmptyFriendHabitsView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 30.06.25.
//

import SwiftUI

struct EmptyFriendHabitsView: View {
    
    let name: String
    
    var body: some View {
        EmptyContentView(
            icon: "questionmark.folder",
            title: .hasNoHabits(name),
            description: .mightBeKeepingTheirHabitsPrivateOrJustGettingStartedEitherWayAChallengeFromYouCouldBeThePerfectMotivation(name)
        )
    }
}

#Preview {
    EmptyFriendHabitsView(name: "Jack")
}
