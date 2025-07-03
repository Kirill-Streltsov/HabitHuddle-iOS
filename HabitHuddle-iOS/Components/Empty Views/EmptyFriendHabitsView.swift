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
            title: "\(name) has no habits",
            description: "\(name) might be keeping their habits private — or just getting started.\nEither way, a challenge from you could be the perfect motivation!"
        )
    }
}

#Preview {
    EmptyFriendHabitsView(name: "Jack")
}
