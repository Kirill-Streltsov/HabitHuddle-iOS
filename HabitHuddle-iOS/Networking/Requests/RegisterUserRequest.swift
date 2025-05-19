//
//  RegisterUserRequest.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 19.05.25.
//

struct RegisterUserRequest: Encodable {
    let username: String
    let name: String
    let password: String
}
