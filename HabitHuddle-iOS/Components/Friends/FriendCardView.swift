//
//  FriendCardView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 02.06.25.
//

import SwiftUI

struct FriendCardView: View {
    let user: User
    var onChallenge: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            // Profile icon
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundStyle(.blue.opacity(0.85))

            // User info
            VStack(alignment: .leading, spacing: 4) {
                Text(user.name)
                    .font(.headline)

                Text("@\(user.username)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                if let joinDate = user.createdAt {
                    Text("Member since \(joinDate.formattedAsMonthYear())")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            // Challenge button
            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
            
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
    FriendCardView(user: User(id: UUID(), username: "username", name: "Username", createdAt: .now, updatedAt: .now), onChallenge: {})
}
