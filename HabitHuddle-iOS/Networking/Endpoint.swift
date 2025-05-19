//
//  Endpoint.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 19.05.25.
//

import Foundation

struct Endpoint {
    
    let path: String
    
    static func login() -> Endpoint {
        Endpoint(path: "auth/login")
    }
    
    static func register() -> Endpoint {
        Endpoint(path: "auth/register")
    }
    
    static func me() -> Endpoint {
        Endpoint(path: "auth/me")
    }
}
