//
//  FriendRequestCardView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 03.06.25.
//

import SwiftUI

struct FriendRequestCardView: View {
    let user: UserDTO
    var onAccept: () -> Void
    var onIgnore: () -> Void

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
                    .foregroundStyle(.secondary)

                if let joinDate = user.createdAt {
                    Text("Joined \(joinDate.formattedAsMonthYear())")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            // Action buttons
            VStack(alignment: .trailing) {
                Button("Ignore") {
                    onIgnore()
                }
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.gray.opacity(0.1))
                .foregroundStyle(.gray)
                .clipShape(Capsule())
                
                Button("Accept") {
                    onAccept()
                }
                .font(.subheadline.bold())
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.green.opacity(0.1))
                .foregroundStyle(.green)
                .clipShape(Capsule())
            }
            
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color(.label).opacity(0.05), radius: 6, x: 0, y: 2)
        )
        .padding(.horizontal)
    }
}

#Preview {
    FriendRequestCardView(user: UserDTO(id: UUID(), username: "big_enthusiast", name: "Kirill", createdAt: .now, updatedAt: .now), onAccept: {}, onIgnore: {})
}
