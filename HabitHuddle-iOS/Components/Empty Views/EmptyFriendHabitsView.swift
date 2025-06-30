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
        VStack(spacing: 20) {
            Image(systemName: "checklist")
                .resizable()
                .scaledToFit()
                .frame(width: 70, height: 70)
                .foregroundStyle(.gray.opacity(0.4))

            Text("\(name) hasn't added any habits yet")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.primary.opacity(0.7))

            Text("Looks like \(name) hasn’t picked up any habits yet. Send them a challenge to get things rolling!")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    EmptyFriendHabitsView(name: "Jack")
}
