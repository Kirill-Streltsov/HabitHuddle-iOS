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
        URL(string: "https://5dbf-45-86-202-141.ngrok-free.app/api/")!
        #endif
    }()
}
