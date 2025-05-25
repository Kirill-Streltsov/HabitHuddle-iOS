//
//  CodableUser.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 19.05.25.
//

import Foundation

struct CodableUser: Identifiable, Codable {
    let id: UUID
    let username: String
    let name: String
    let createdAt: Date?
    let updatedAt: Date?
}
