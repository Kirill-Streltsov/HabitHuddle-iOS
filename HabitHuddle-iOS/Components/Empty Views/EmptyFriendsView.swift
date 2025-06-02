//
//  EmptyFriendsView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 02.06.25.
//


import SwiftUI

struct EmptyFriendsView: View {
    @AppStorage("selectedTab") private var selectedTab: Int?

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.2.slash")
                .resizable()
                .scaledToFit()
                .frame(width: 70, height: 70)
                .foregroundStyle(.gray.opacity(0.4))

            Text("No Friends Yet")
                .font(.title2.weight(.semibold))
                .foregroundColor(.primary.opacity(0.7))

            Text("Go to the Friends tab to find and connect with someone you know.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button("Go to the Settings tab to log in or create an account.") {
                selectedTab = 1
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

#Preview {
    EmptyFriendsView()
}
