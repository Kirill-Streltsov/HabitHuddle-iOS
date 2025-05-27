//
//  UserDataView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 26.05.25.
//

import SwiftData
import SwiftUI

struct UserDataView<Content: View>: View {
    @Query private var users: [User]
    private var user: User? { users.first }

    let content: (User) -> Content

    init(@ViewBuilder content: @escaping (User) -> Content) {
        self.content = content
    }

    var body: some View {
        if let user = user {
            content(user)
        } else {
            VStack(spacing: 8) {
                ProgressView()
                Text("Loading user...")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()
        }
    }
}

#Preview {
    let container = try! ModelContainer(for: User.self, configurations: .init(isStoredInMemoryOnly: true))
    let context = container.mainContext
    let mockUser = User(id: UUID(), username: "anton_loginov", name: "Anton", createdAt: .now, updatedAt: .now, habits: [])
    context.insert(mockUser)

    return UserDataView { user in
        Text("Previewing \(user.name)")
    }
    //.modelContainer(container)
}
