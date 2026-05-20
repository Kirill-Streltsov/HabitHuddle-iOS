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
            return String(localized: .theUrlIsInvalid)
        case .unauthorized:
            return String(localized: .wrongUsernameOrPassword)
        case .forbidden:
            return String(localized: .youDontHavePermissionToAccessThisResource)
        case .notFound:
            return String(localized: .theRequestedResourceWasNotFound)
        case .conflict:
            return String(localized: .theresAConflictWithTheCurrentStateOfTheResource)
        case .serverError:
            return String(localized: .serverErrorOccurred)
        case .noData:
            return String(localized: .noDataWasReceivedFromTheServer)
        case let .requestFailed(statusCode, _):
            return String(localized: .requestFailedWithStatusCode(statusCode))
        case let .decodingError(error):
            return String(localized: .failedToDecodeResponse(error.localizedDescription))
        case let .networkError(error):
            return String(localized: .aNetworkErrorOccurred(error.localizedDescription))
        case .invalidResponse:
            return String(localized: .invalidHttpResponse)
        case .unknown:
            return String(localized: .anUnknownErrorOccurred)
        case .partialFailure(updated: let habits, failedIDs: let failedIDs):
            return "Couldn’t update all habits. Updated: \(habits.count). Failed: \(failedIDs.count)."
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
