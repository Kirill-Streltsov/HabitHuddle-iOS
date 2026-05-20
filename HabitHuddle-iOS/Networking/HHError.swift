//
//  APIError.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 19.05.25.
//

import Foundation

enum HHError: Error, LocalizedError, Equatable {
    case invalidURL
    case requestFailed(statusCode: Int, data: Data?)
    case decodingError(Error)
    case noData
    case networkError(Error)
    case unauthorized
    case forbidden
    case notFound
    case conflict
    case serverError
    case unknown
    case invalidResponse
    case partialFailure(updated: [HabitDTO], failedIDs: [UUID])
    case customError(errorText: String)

    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return String(localized: "The URL is invalid.")
        case .unauthorized:
            return String(localized: "Wrong username or password.")
        case .forbidden:
            return String(localized: "You don’t have permission to access this resource.")
        case .notFound:
            return String(localized: "The requested resource was not found.")
        case .conflict:
            return String(localized: "There’s a conflict with the current state of the resource.")
        case .serverError:
            return String(localized: "Server error occurred.")
        case .noData:
            return String(localized: "No data was received from the server.")
        case let .requestFailed(statusCode, _):
            return String(localized: "Request failed with status code \(statusCode).")
        case let .decodingError(error):
            return String(localized: "Failed to decode response: \(error.localizedDescription)")
        case let .networkError(error):
            return String(localized: "A network error occurred: \(error.localizedDescription)")
        case .invalidResponse:
            return String(localized: "Invalid HTTP response.")
        case .unknown:
            return String(localized: "An unknown error occurred.")
        case .partialFailure(updated: let habits, failedIDs: let failedIDs):
            return String(localized: "Couldn’t update all habits. Habit updated: \(habits). Failed IDs: \(failedIDs)")
        case .customError(errorText: let errorText):
            return errorText
        }
    }
    
    static func == (lhs: HHError, rhs: HHError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.unauthorized, .unauthorized),
             (.forbidden, .forbidden),
             (.notFound, .notFound),
             (.conflict, .conflict),
             (.serverError, .serverError),
             (.noData, .noData),
             (.invalidResponse, .invalidResponse),
             (.unknown, .unknown):
            return true
            
        case let (.requestFailed(lhsCode, _), .requestFailed(rhsCode, _)):
            return lhsCode == rhsCode

        case let (.customError(lhsText), .customError(rhsText)):
            return lhsText == rhsText

        case let (.partialFailure(lhsUpdated, lhsFailed), .partialFailure(rhsUpdated, rhsFailed)):
            return lhsUpdated == rhsUpdated && lhsFailed == rhsFailed

        default:
            return false
        }
    }
}
