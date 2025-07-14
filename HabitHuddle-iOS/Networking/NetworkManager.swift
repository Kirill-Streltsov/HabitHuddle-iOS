//
//  NetworkingManager.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 19.05.25.
//

import Foundation

actor NetworkManager {
    static let shared = NetworkManager()
    
    //private let baseURL = URL(string: "http://localhost:8080/api/")!
    private let baseURL = URL(string: "https://fdca-95-223-76-171.ngrok-free.app/api/")!
    //private let baseURL = URL(string: "https://habithuddle-backend.fly.dev/api/")!
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
            //print("RECEIVED DATA: \(data.prettyPrintedJSONString)")
            do {
                let decoded = try jsonDecoder.decode(T.self, from: data)
                return decoded
            } catch let DecodingError.keyNotFound(key, context) {
                print("❌ Error: Missing key: \(key.stringValue) in \(context.codingPath.map(\.stringValue))")
                throw HHError.decodingError(DecodingError.keyNotFound(key, context))
            } catch let DecodingError.typeMismatch(type, context) {
                print("❌ Error: Type mismatch for type \(type) in \(context.codingPath.map(\.stringValue)): \(context.debugDescription)")
                throw HHError.decodingError(DecodingError.typeMismatch(type, context))
            } catch let DecodingError.valueNotFound(value, context) {
                print("❌ Error: Value not found: \(value) in \(context.codingPath.map(\.stringValue)): \(context.debugDescription)")
                throw HHError.decodingError(DecodingError.valueNotFound(value, context))
            } catch let DecodingError.dataCorrupted(context) {
                print("❌ Error: Data corrupted: \(context.debugDescription)")
                throw HHError.decodingError(DecodingError.dataCorrupted(context))
            } catch {
                print("❌ Error: Unknown decoding error: \(error.localizedDescription)")
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
