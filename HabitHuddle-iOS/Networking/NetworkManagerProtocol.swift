//
//  NetworkManagerProtocol.swift
//  HabitHuddle-iOS
//

import Foundation

protocol NetworkManagerProtocol: Actor {
    func request<T: Decodable, U: Encodable>(
        endpoint: Endpoint,
        method: HTTPMethod,
        body: U,
        headers: [String: String]?,
        responseType: T.Type,
        isLoggingIn: Bool
    ) async throws -> T

    func request<T: Decodable>(
        endpoint: Endpoint,
        method: HTTPMethod,
        headers: [String: String]?,
        responseType: T.Type,
        isLoggingIn: Bool
    ) async throws -> T

    func requestStatusCode(
        endpoint: Endpoint,
        method: HTTPMethod,
        headers: [String: String]?,
        isLoggingIn: Bool
    ) async throws -> HTTPStatus

    func requestStatusCode<U: Encodable>(
        endpoint: Endpoint,
        method: HTTPMethod,
        body: U,
        headers: [String: String]?,
        isLoggingIn: Bool
    ) async throws -> HTTPStatus
}

extension NetworkManagerProtocol {
    func request<T: Decodable, U: Encodable>(
        endpoint: Endpoint,
        method: HTTPMethod,
        body: U,
        responseType: T.Type
    ) async throws -> T {
        try await request(endpoint: endpoint, method: method, body: body, headers: nil, responseType: responseType, isLoggingIn: false)
    }

    func request<T: Decodable, U: Encodable>(
        endpoint: Endpoint,
        method: HTTPMethod,
        body: U,
        responseType: T.Type,
        isLoggingIn: Bool
    ) async throws -> T {
        try await request(endpoint: endpoint, method: method, body: body, headers: nil, responseType: responseType, isLoggingIn: isLoggingIn)
    }

    func request<T: Decodable>(
        endpoint: Endpoint,
        method: HTTPMethod,
        responseType: T.Type
    ) async throws -> T {
        try await request(endpoint: endpoint, method: method, headers: nil, responseType: responseType, isLoggingIn: false)
    }

    func requestStatusCode(
        endpoint: Endpoint,
        method: HTTPMethod
    ) async throws -> HTTPStatus {
        try await requestStatusCode(endpoint: endpoint, method: method, headers: nil, isLoggingIn: false)
    }

    func requestStatusCode<U: Encodable>(
        endpoint: Endpoint,
        method: HTTPMethod,
        body: U
    ) async throws -> HTTPStatus {
        try await requestStatusCode(endpoint: endpoint, method: method, body: body, headers: nil, isLoggingIn: false)
    }
}
