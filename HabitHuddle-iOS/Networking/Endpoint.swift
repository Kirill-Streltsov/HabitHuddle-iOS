//
//  Endpoint.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 19.05.25.
//

import Foundation

struct Endpoint {
    let path: String
    let queryItems: [URLQueryItem]?
    
    init(path: String, queryItems: [URLQueryItem]? = nil) {
        self.path = path
        self.queryItems = queryItems
    }

    static func login() -> Endpoint {
        Endpoint(path: "auth/login")
    }

    static func register() -> Endpoint {
        Endpoint(path: "auth/register")
    }

    static func me() -> Endpoint {
        Endpoint(path: "auth/me")
    }

    static func createHabit() -> Endpoint {
        Endpoint(path: "habits/create")
    }

    static func updateHabit(with id: UUID) -> Endpoint {
        Endpoint(path: "habits/\(id)")
    }

    static func checkIntoHabit(with id: UUID) -> Endpoint {
        Endpoint(path: "habits/\(id)/toggle-checkin")
    }

    static func deleteHabit(with id: UUID) -> Endpoint {
        Endpoint(path: "habits/delete/\(id)")
    }

    static func getMyHabits() -> Endpoint {
        Endpoint(path: "habits/")
    }
    
    static func searchForUser(username: String) -> Endpoint {
        Endpoint(
            path: "users/search",
            queryItems: [URLQueryItem(name: "query", value: username)]
        )
    }
}
