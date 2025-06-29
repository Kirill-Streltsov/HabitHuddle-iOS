//
//  ChatRequest.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 29.06.25.
//

import Foundation
struct ChatRequest: Codable {
    let model: String
    let messages: [ChatMessage]
}
