//
//  Config.swift
//  HabitHuddle-iOS
//

import Foundation

enum Config {
    static let baseURL: URL = {
        #if DEBUG
        URL(string: "http://localhost:8080/api/")!
        #else
        URL(string: "https://habithuddle-backend.onrender.com/api/")!
        #endif
    }()
}
