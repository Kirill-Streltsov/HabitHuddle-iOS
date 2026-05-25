//
//  HTTPStatus.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 31.05.25.
//

import Foundation

enum HTTPStatus: Int {
    case ok = 200
    case created = 201
    case badRequest = 400
    case unauthorized = 401
    case notFound = 404
    case conflict = 409
    case gone = 410
    case serverError = 500

    init(statusCode: Int) {
        self = HTTPStatus(rawValue: statusCode) ?? .serverError
    }
}
