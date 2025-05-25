//
//  RegisterPayload.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 19.05.25.
//

struct RegisterPayload: Encodable {
    let username: String
    let name: String
    let password: String
}
