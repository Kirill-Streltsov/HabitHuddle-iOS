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
                .foregroundStyle(.primary.opacity(0.7))

            Text("Connect with friends to send challenges, track habits together, and stay motivated.")
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
    EmptyFriendsView()
}
