//
//  ResultHandler.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 26.05.25.
//

import Foundation

/// A centralized handler for `Result` values.
/// Simplifies repetitive success/failure handling in UI or business logic.
func handleResult<T>(
    _ result: Result<T, APIError>,
    onSuccess: (T) -> Void,
    onFailure: ((APIError) -> Void)? = nil
) {
    switch result {
    case let .success(value):
        onSuccess(value)
    case let .failure(error):
        if let onFailure = onFailure {
            onFailure(error)
        } else {
            // Default error handling
            print("⚠️ Error: \(error.localizedDescription)")
        }
    }
}
