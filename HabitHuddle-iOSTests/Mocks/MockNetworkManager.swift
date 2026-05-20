//
//  MockNetworkManager.swift
//  HabitHuddle-iOSTests
//

import Foundation
@testable import HabitHuddle_iOS

actor MockNetworkManager: NetworkManagerProtocol {
    private var responseQueue: [Result<Any, Error>] = []
    private(set) var requestLog: [(path: String, method: HTTPMethod)] = []

    func enqueue<T>(_ value: T) {
        responseQueue.append(.success(value as Any))
    }

    func enqueueError(_ error: Error = HHError.serverError) {
        responseQueue.append(.failure(error))
    }

    private func next<T>() throws -> T {
        guard !responseQueue.isEmpty else {
            throw HHError.unknown
        }
        let response = responseQueue.removeFirst()
        switch response {
        case .success(let value):
            guard let typed = value as? T else {
                throw HHError.decodingError(
                    NSError(domain: "MockNetworkManager", code: -1, userInfo: [
                        NSLocalizedDescriptionKey: "Type mismatch: expected \(T.self), got \(type(of: value))"
                    ])
                )
            }
            return typed
        case .failure(let error):
            throw error
        }
    }

    func request<T: Decodable, U: Encodable>(
        endpoint: Endpoint,
        method: HTTPMethod,
        body: U,
        headers: [String: String]?,
        responseType: T.Type,
        isLoggingIn: Bool
    ) async throws -> T {
        requestLog.append((endpoint.path, method))
        return try next()
    }

    func request<T: Decodable>(
        endpoint: Endpoint,
        method: HTTPMethod,
        headers: [String: String]?,
        responseType: T.Type,
        isLoggingIn: Bool
    ) async throws -> T {
        requestLog.append((endpoint.path, method))
        return try next()
    }

    func requestStatusCode(
        endpoint: Endpoint,
        method: HTTPMethod,
        headers: [String: String]?,
        isLoggingIn: Bool
    ) async throws -> HTTPStatus {
        requestLog.append((endpoint.path, method))
        return try next()
    }

    func requestStatusCode<U: Encodable>(
        endpoint: Endpoint,
        method: HTTPMethod,
        body: U,
        headers: [String: String]?,
        isLoggingIn: Bool
    ) async throws -> HTTPStatus {
        requestLog.append((endpoint.path, method))
        return try next()
    }
}
