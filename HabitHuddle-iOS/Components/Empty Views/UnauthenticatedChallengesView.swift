//
//  UnauthenticatedChallengesView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 02.06.25.
//

import SwiftUI

struct UnauthenticatedChallengesView: View {
    
    @AppStorage("selectedTab") private var selectedTab: Int?
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "gear")
                .resizable()
                .scaledToFit()
                .frame(width: 70, height: 70)
                .foregroundStyle(.gray.opacity(0.4))

            Text("Not Signed In")
                .font(.title2.weight(.semibold))
                .foregroundColor(.primary.opacity(0.7))

            Text("You need to sign in to view and participate in challenges.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button("Go to the Settings tab to log in or create an account.") {
                selectedTab = 3
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}
