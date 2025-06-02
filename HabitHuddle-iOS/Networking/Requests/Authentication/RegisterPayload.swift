//
//  RegisterPayload.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 19.05.25.
//

import Foundation

struct RegisterPayload: Encodable {
    let id: UUID
    let username: String
    let name: String
    let password: String
}
