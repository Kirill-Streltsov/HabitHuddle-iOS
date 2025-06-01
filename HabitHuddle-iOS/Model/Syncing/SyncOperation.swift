//
//  SyncOperation.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 01.06.25.
//

import Foundation
struct SyncOperation: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    let habitID: UUID
    let action: SyncAction
}
