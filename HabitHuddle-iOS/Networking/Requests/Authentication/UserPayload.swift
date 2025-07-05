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
    let password: String?
    let deviceToken: String
}
