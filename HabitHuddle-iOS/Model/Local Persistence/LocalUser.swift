//
//  LocalUser.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 02.06.25.
//

import Foundation

struct LocalUser: Codable {
    let id: UUID
    let username: String
    let name: String
    let email: String?
    let isSignedInToServer: Bool
    let isEmailVerified: Bool

    init(id: UUID, username: String, name: String, email: String? = nil, isSignedInToServer: Bool, isEmailVerified: Bool = false) {
        self.id = id
        self.username = username
        self.name = name
        self.email = email
        self.isSignedInToServer = isSignedInToServer
        self.isEmailVerified = isEmailVerified
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        username = try container.decode(String.self, forKey: .username)
        name = try container.decode(String.self, forKey: .name)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        isSignedInToServer = try container.decode(Bool.self, forKey: .isSignedInToServer)
        isEmailVerified = try container.decodeIfPresent(Bool.self, forKey: .isEmailVerified) ?? false
    }

    static let `default` = LocalUser(id: UUID(), username: "guest", name: "New Person", isSignedInToServer: false)
}
