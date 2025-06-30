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
            Image(systemName: "questionmark.folder")
                .resizable()
                .scaledToFit()
                .frame(width: 70, height: 70)
                .foregroundStyle(.gray.opacity(0.4))

            Text("\(name) has no habits")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.primary.opacity(0.7))

            Text("\(name) might be keeping their habits private — or just getting started.\nEither way, a challenge from you could be the perfect motivation!")
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
