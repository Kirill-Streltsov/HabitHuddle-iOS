//
//  CodableUser.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 19.05.25.
//

import Foundation
struct UserDTO: Identifiable, Codable, Equatable {
    let id: UUID
    let username: String
    let name: String
    let createdAt: Date?
    let updatedAt: Date?
    
    static func == (lhs: UserDTO, rhs: UserDTO) -> Bool {
        return lhs.id == rhs.id
    }
}
