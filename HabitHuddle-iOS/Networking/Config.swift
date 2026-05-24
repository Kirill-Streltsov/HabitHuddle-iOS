//
//  Config.swift
//  HabitHuddle-iOS
//

import Foundation

enum Config {
    static let baseURL: URL = {
        #if DEBUG
        URL(string: "https://habithuddle-backend.onrender.com/api/")!
        #else
        URL(string: "https://habithuddle-backend.onrender.com/api/")!
        #endif
    }()
}
