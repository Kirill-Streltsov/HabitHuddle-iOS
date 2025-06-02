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

    static let `default` = LocalUser(id: UUID(), username: "guest", name: "New Person")
}
