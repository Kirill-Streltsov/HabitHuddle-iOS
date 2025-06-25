//
//  FriendCardView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 02.06.25.
//

import SwiftUI

struct FriendCardView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    let friend: UserDTO
    let showChallengeButton: Bool
    var onCompete: @MainActor () async -> Void
    var onSupport: @MainActor () async -> Void
    
    init(friend: UserDTO, showChallengeButton: Bool, onCompete: @escaping () async -> Void = {}, onSupport: @escaping () async -> Void = {}) {
        self.friend = friend
        self.showChallengeButton = showChallengeButton
        self.onCompete = onCompete
        self.onSupport = onSupport
    }

    var body: some View {
        HStack(spacing: 16) {
            // Profile icon
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundStyle(.blue.opacity(0.85))

            // User info
            VStack(alignment: .leading, spacing: 4) {
                Text(friend.name)
                    .font(.headline)

                Text("@\(friend.username)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if let joinDate = friend.createdAt {
                    Text("Member since \(joinDate.formattedAsMonthYear())")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            // Challenge button
            if showChallengeButton {
                VStack {
                    SlimButton(title: "Competitive", color: .pink) {
                        Task {
                            await onCompete()
                            dismiss()
                        }
                    }
                    SlimButton(title: "Supportive", color: .green) {
                        Task {
                            await onSupport()
                            dismiss()
                        }
                    }
                }
                
            } else {
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color(.label).opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal)
    }
}

#Preview {
    FriendCardView(friend: UserDTO(id: UUID(), username: "username", name: "Username", createdAt: .now, updatedAt: .now), showChallengeButton: false, onCompete: {}, onSupport: {})
}
