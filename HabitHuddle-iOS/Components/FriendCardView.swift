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
        HStack(alignment: .top, spacing: 16) {
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
                    Text("Member since \(formattedDate(joinDate))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            // Challenge button
            VStack {
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
                    .offset(x: 40)
                Spacer()
                Button(action: onChallenge) {
                    Text("Challenge")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.9))
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
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

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: date)
    }
}

#Preview {
    FriendCardView(user: User(id: UUID(), username: "username", name: "Username", createdAt: .now, updatedAt: .now), onChallenge: {})
}
