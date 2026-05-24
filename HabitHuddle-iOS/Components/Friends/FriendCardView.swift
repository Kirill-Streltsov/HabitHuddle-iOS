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
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                // Profile icon
                ZStack {
                    Circle()
                        .fill(Color.accentColor)
                        .frame(width: 46, height: 46)
                    Text(String(friend.name.prefix(1)).uppercased())
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }

                // User info
                VStack(alignment: .leading, spacing: 2) {
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

                if !showChallengeButton {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                }
            }

            if showChallengeButton {
                HStack(spacing: 10) {
                    Button {
                        Task {
                            await onCompete()
                            dismiss()
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "flame.fill")
                            Text(.compete)
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.pink)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }

                    Button {
                        Task {
                            await onSupport()
                            dismiss()
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "hands.clap.fill")
                            Text(.support)
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.green)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color(.label).opacity(0.1), radius: 2, x: 0, y: 2)
        .padding(.horizontal)
    }
}

#Preview("Friends tab — no buttons") {
    FriendCardView(
        friend: UserDTO(id: UUID(), username: "username", name: "Username", createdAt: .now, updatedAt: .now),
        showChallengeButton: false
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("Challenge mode — with buttons") {
    FriendCardView(
        friend: UserDTO(id: UUID(), username: "jdoe", name: "John Doe", createdAt: .now, updatedAt: .now),
        showChallengeButton: true,
        onCompete: {},
        onSupport: {}
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}
