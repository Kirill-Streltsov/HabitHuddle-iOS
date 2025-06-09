//
//  UserDTO+toSwiftData.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 09.06.25.
//

import Foundation
extension UserDTO {
    func toSwiftData() -> User {
        let user = User(id: id, username: username, name: name, createdAt: createdAt, updatedAt: updatedAt)
        return user
    }
}
