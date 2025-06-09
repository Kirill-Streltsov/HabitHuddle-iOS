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
    
    // MARK: Authentication

    static func login() -> Endpoint {
        Endpoint(path: "auth/login")
    }

    static func register() -> Endpoint {
        Endpoint(path: "auth/register")
    }

    static func me() -> Endpoint {
        Endpoint(path: "auth/me")
    }

    // MARK: Habits
    
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
    
    static func getHabit(with id: UUID) -> Endpoint {
        Endpoint(path: "habits/\(id)")
    }
    
    // MARK: Users and Friendships
    
    static func searchForUser(username: String) -> Endpoint {
        Endpoint(
            path: "users/search",
            queryItems: [URLQueryItem(name: "query", value: username)]
        )
    }
    
    static func getUser(with id: UUID) -> Endpoint {
        Endpoint(path: "users/\(id)")
    }
    
    static func getMyFriends() -> Endpoint {
        Endpoint(path: "friends")
    }
    
    static func requestFriend(with id: UUID) -> Endpoint {
        Endpoint(path: "friends/request")
    }
    
    static func acceptFriend(with id: UUID) -> Endpoint {
        Endpoint(path: "friends/accept/\(id)")
    }
    
    static func rejectFriend(with id: UUID) -> Endpoint {
        Endpoint(path: "friends/reject/\(id)")
    }
    
    static func deleteFriend(with id: UUID) -> Endpoint {
        Endpoint(path: "friends/\(id)")
    }
    
    static func getFriendshipRequests() -> Endpoint {
        Endpoint(path: "friends/requests")
    }
    
    static func getUserHabits(for id: UUID) -> Endpoint {
        Endpoint(path: "habits/\(id)")
    }
    
    // MARK: Challenges
    
    static func sendChallenge() -> Endpoint {
        Endpoint(path: "challenges/send")
    }
    
    static func acceptChallenge(id: UUID) -> Endpoint {
        Endpoint(path: "challenges/\(id)/accept")
    }
    
    static func rejectChallenge(id: UUID) -> Endpoint {
        Endpoint(path: "challenges/\(id)/reject")
    }
    
    static func getChallenges(for id: UUID) -> Endpoint {
        Endpoint(path: "challenges/\(id)")
    }
}
