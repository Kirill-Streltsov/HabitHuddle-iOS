//
//  LoginResponse.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 19.05.25.
//

struct LoginResponse: Decodable {
    let token: String
    let user: User
}
