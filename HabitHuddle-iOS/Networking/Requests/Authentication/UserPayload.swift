//
//  RegisterPayload.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 19.05.25.
//

import Foundation

struct UserPayload: Encodable {
    let id: UUID
    let username: String
    let name: String
    let email: String?
    let password: String?
    let deviceToken: String

    init(id: UUID, username: String, name: String, email: String? = nil, password: String?, deviceToken: String) {
        self.id = id
        self.username = username
        self.name = name
        self.email = email
        self.password = password
        self.deviceToken = deviceToken
    }
}
