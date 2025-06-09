//
//  NetworkingManager.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 19.05.25.
//

import Foundation

actor NetworkManager {
    static let shared = NetworkManager()
    
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
        responseType _: T.Type,
        isLoggingIn: Bool = false
    ) async throws -> T {
        
        guard var components = URLComponents(url: baseURL.appendingPathComponent(endpoint.path), resolvingAgainstBaseURL: false) else {
            throw HHError.invalidURL
        }
        
        components.queryItems = endpoint.queryItems
        guard let finalURL = components.url else {
            throw HHError.invalidURL
        }
        var urlRequest = URLRequest(url: finalURL)
        
        if !isLoggingIn {
            guard let token = TokenManager.token else { throw HHError.unauthorized }
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        urlRequest.httpMethod = method.rawValue
        
        headers?.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try jsonEncoder.encode(body)

        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let response = response as? HTTPURLResponse else {
            throw HHError.unknown
        }
        return try handleResponse(data: data, response: response, responseType: T.self)
    }

    func request<T: Decodable>(
        endpoint: Endpoint,
        method: HTTPMethod,
        headers: [String: String]? = nil,
        responseType _: T.Type,
        isLoggingIn: Bool = false
    ) async throws -> T {
        
        guard var components = URLComponents(url: baseURL.appendingPathComponent(endpoint.path), resolvingAgainstBaseURL: false) else {
            throw HHError.invalidURL
        }
        components.queryItems = endpoint.queryItems
        guard let finalURL = components.url else {
            throw HHError.invalidURL
        }
        
        var urlRequest = URLRequest(url: finalURL)
        
        if !isLoggingIn {
            guard let token = TokenManager.token else { throw HHError.unauthorized }
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        urlRequest.httpMethod = method.rawValue
        headers?.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let response = response as? HTTPURLResponse else {
            throw HHError.unknown
        }
        return try handleResponse(data: data, response: response, responseType: T.self)
    }

    func requestStatusCode(
        endpoint: Endpoint,
        method: HTTPMethod,
        headers: [String: String]? = nil,
        isLoggingIn: Bool = false
    ) async throws -> HTTPStatus {
        
        var urlRequest = URLRequest(url: baseURL.appendingPathComponent(endpoint.path))
        
        if !isLoggingIn {
            guard let token = TokenManager.token else { throw HHError.unauthorized }
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        urlRequest.httpMethod = method.rawValue

        headers?.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        let (_, response) = try await URLSession.shared.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw HHError.unknown
        }

        return HTTPStatus(statusCode: httpResponse.statusCode)
    }

    func requestStatusCode<U: Encodable>(
        endpoint: Endpoint,
        method: HTTPMethod,
        body: U,
        headers: [String: String]? = nil,
        isLoggingIn: Bool = false
    ) async throws -> HTTPStatus {
        
        var urlRequest = URLRequest(url: baseURL.appendingPathComponent(endpoint.path))
        
        if !isLoggingIn {
            guard let token = TokenManager.token else { throw HHError.unauthorized }
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        urlRequest.httpMethod = method.rawValue
        headers?.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try jsonEncoder.encode(body)

        let (_, response) = try await URLSession.shared.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw HHError.unknown
        }

        return HTTPStatus(statusCode: httpResponse.statusCode)
    }

    private func handleResponse<T: Decodable>(data: Data, response: HTTPURLResponse, responseType _: T.Type) throws -> T {
        switch response.statusCode {
        case 200 ..< 300:
            do {
                let decodedData = try jsonDecoder.decode(T.self, from: data)
                return decodedData
            } catch {
                throw HHError.decodingError(error)
            }
        case 401:
            throw HHError.unauthorized
        case 404:
            throw HHError.notFound
        case 409:
            throw HHError.conflict
        case 500 ..< 600:
            throw HHError.serverError
        default:
            throw HHError.requestFailed(statusCode: response.statusCode, data: data)
        }
    }
}
