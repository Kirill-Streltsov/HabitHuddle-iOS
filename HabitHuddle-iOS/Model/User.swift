//
//  User.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 19.05.25.
//

import Foundation

struct User: Identifiable, Decodable {
    let id: UUID
    let username: String
    let name: String
    let createdAt: Date?
    let updatedAt: Date?
}
