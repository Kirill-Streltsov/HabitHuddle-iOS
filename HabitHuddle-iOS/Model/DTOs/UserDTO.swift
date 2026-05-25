//
//  CodableUser.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 19.05.25.
//

import Foundation

enum AuthProvider: String, Codable {
    case password
    case google
    case apple
}

struct UserDTO: Identifiable, Codable, Equatable {
    let id: UUID
    let username: String
    let name: String
    let email: String?
    let isEmailVerified: Bool
    let authProvider: AuthProvider
    let createdAt: Date?
    let updatedAt: Date?

    static func == (lhs: UserDTO, rhs: UserDTO) -> Bool {
        return lhs.id == rhs.id
    }

    init(id: UUID, username: String, name: String, email: String? = nil, isEmailVerified: Bool = false, authProvider: AuthProvider = .password, createdAt: Date?, updatedAt: Date?) {
        self.id = id
        self.username = username
        self.name = name
        self.email = email
        self.isEmailVerified = isEmailVerified
        self.authProvider = authProvider
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        username = try container.decode(String.self, forKey: .username)
        name = try container.decode(String.self, forKey: .name)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        isEmailVerified = try container.decodeIfPresent(Bool.self, forKey: .isEmailVerified) ?? false
        authProvider = try container.decodeIfPresent(AuthProvider.self, forKey: .authProvider) ?? .password
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt)
    }
}
