//
//  APIError.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 19.05.25.
//

import Foundation

enum APIError: Error, LocalizedError {
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

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL is invalid."
        case .unauthorized:
            return "Wrong username or password."
        case .forbidden:
            return "You don’t have permission to access this resource."
        case .notFound:
            return "The requested resource was not found."
        case .conflict:
            return "There’s a conflict with the current state of the resource."
        case .serverError:
            return "This username is already taken."
        case .noData:
            return "No data was received from the server."
        case let .requestFailed(statusCode, _):
            return "Request failed with status code \(statusCode)."
        case let .decodingError(error):
            return "Failed to decode response: \(error.localizedDescription)"
        case let .networkError(error):
            return "A network error occurred: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid HTTP response."
        case .unknown:
            return "An unknown error occurred."
        }
    }
}
