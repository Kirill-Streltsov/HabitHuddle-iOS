//
//  EmptyActivityView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 02.06.25.
//

import SwiftUI

struct EmptyActivityView: View {
    let friendName: String
    var onChallenge: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "sparkles.rectangle.stack")
                .resizable()
                .scaledToFit()
                .frame(width: 70, height: 70)
                .foregroundStyle(.gray.opacity(0.4))

            Text(.noActivityYet)
                .font(.title2.weight(.semibold))
                .foregroundStyle(.primary.opacity(0.7))

            Text(.hasntStartedAnyHabitsYetSendAChallengeToHelpGetThingsGoing(friendName))
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button(action: onChallenge) {
                Text(.challenge(friendName))
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding()
                    .frame(maxWidth: 260)
                    .background(Color(.systemBlue))
                    .cornerRadius(12)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    EmptyActivityView(friendName: "Jessica", onChallenge: {})
}
