//
//  FriendDetailView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 02.06.25.
//

import SwiftUI

struct FriendDetailView: View {
    
    let friend: User
    
    var body: some View {
        Text(friend.username)
    }
}

#Preview {
    FriendDetailView(friend: User(id: UUID(), username: "username", name: "Jack", createdAt: .now, updatedAt: .now, habits: []))
}
