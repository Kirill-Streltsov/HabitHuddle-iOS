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
            ZStack {
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 50, height: 50)
                Text(String(friend.name.prefix(1)).uppercased())
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }

            // User info
            VStack(alignment: .leading, spacing: 4) {
                Text(friend.name)
                    .font(.headline)

                Text("@\(friend.username)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if let joinDate = friend.createdAt {
                    Text(.memberSince(joinDate.formattedAsMonthYear()))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            // Challenge button
            if showChallengeButton {
                VStack {
                    SlimButton(title: .compete, color: .pink) {
                        Task {
                            await onCompete()
                            dismiss()
                        }
                    }
                    SlimButton(title: .support, color: .green) {
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
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color(.label).opacity(0.1), radius: 2, x: 0, y: 2)
        .padding(.horizontal)
    }
}

#Preview {
    FriendCardView(friend: UserDTO(id: UUID(), username: "username", name: "Username", createdAt: .now, updatedAt: .now), showChallengeButton: false, onCompete: {}, onSupport: {})
}
