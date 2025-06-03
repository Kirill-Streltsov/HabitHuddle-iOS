//
//  NetworkingManager.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 19.05.25.
//

import Foundation

final class NetworkingManager {
    static let shared = NetworkingManager()
    private let baseURL = URL(string: "http://localhost:8080/api/")!
    private let jsonDecoder: JSONDecoder
    private let jsonEncoder: JSONEncoder

    private init() {
        jsonDecoder = JSONDecoder()
        jsonEncoder = JSONEncoder()
        jsonDecoder.dateDecodingStrategy = .iso8601
        jsonEncoder.dateEncodingStrategy = .iso8601
    }

    func request<T: Decodable, U: Encodable>(
        endpoint: Endpoint,
        method: HTTPMethod,
        body: U,
        headers: [String: String]? = nil,
        responseType _: T.Type
    ) async throws -> T {
        guard var components = URLComponents(url: baseURL.appendingPathComponent(endpoint.path), resolvingAgainstBaseURL: false) else {
            throw APIError.invalidURL
        }
        components.queryItems = endpoint.queryItems
        guard let finalURL = components.url else {
            throw APIError.invalidURL
        }
        var urlRequest = URLRequest(url: finalURL)
        urlRequest.httpMethod = method.rawValue

        if let token = TokenManager.token {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        headers?.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try jsonEncoder.encode(body)

        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let response = response as? HTTPURLResponse else {
            throw APIError.unknown
        }
        return try handleResponse(data: data, response: response, responseType: T.self)
    }

    func request<T: Decodable>(
        endpoint: Endpoint,
        method: HTTPMethod,
        headers: [String: String]? = nil,
        responseType _: T.Type
    ) async throws -> T {
        guard var components = URLComponents(url: baseURL.appendingPathComponent(endpoint.path), resolvingAgainstBaseURL: false) else {
            throw APIError.invalidURL
        }
        components.queryItems = endpoint.queryItems
        guard let finalURL = components.url else {
            throw APIError.invalidURL
        }
        var urlRequest = URLRequest(url: finalURL)
        urlRequest.httpMethod = method.rawValue

        if let token = TokenManager.token {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        headers?.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let response = response as? HTTPURLResponse else {
            throw APIError.unknown
        }
        return try handleResponse(data: data, response: response, responseType: T.self)
    }

    func requestStatusCode(
        endpoint: Endpoint,
        method: HTTPMethod,
        headers: [String: String]? = nil
    ) async throws -> HTTPStatus {
        var urlRequest = URLRequest(url: baseURL.appendingPathComponent(endpoint.path))
        urlRequest.httpMethod = method.rawValue

        if let token = TokenManager.token {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        headers?.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        let (_, response) = try await URLSession.shared.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.unknown
        }

        return HTTPStatus(statusCode: httpResponse.statusCode)
    }
    
    func requestStatusCode<U: Encodable>(
        endpoint: Endpoint,
        method: HTTPMethod,
        body: U,
        headers: [String: String]? = nil
    ) async throws -> HTTPStatus {
        var urlRequest = URLRequest(url: baseURL.appendingPathComponent(endpoint.path))
        urlRequest.httpMethod = method.rawValue

        if let token = TokenManager.token {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        headers?.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try jsonEncoder.encode(body)

        let (_, response) = try await URLSession.shared.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.unknown
        }

        return HTTPStatus(statusCode: httpResponse.statusCode)
    }

    func handleResponse<T: Decodable>(data: Data, response: HTTPURLResponse, responseType _: T.Type) throws -> T {
        switch response.statusCode {
        case 200 ..< 300:
            do {
                let decodedData = try jsonDecoder.decode(T.self, from: data)
                return decodedData
            } catch {
                throw APIError.decodingError(error)
            }
        case 401:
            throw APIError.unauthorized
        case 404:
            throw APIError.notFound
        case 409:
            throw APIError.conflict
        case 500 ..< 600:
            throw APIError.serverError
        default:
            throw APIError.requestFailed(statusCode: response.statusCode, data: data)
        }
    }
}
