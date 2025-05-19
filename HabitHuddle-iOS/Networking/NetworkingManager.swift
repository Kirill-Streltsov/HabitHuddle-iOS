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
    let jsonDecoder: JSONDecoder
    
    private init() {
        jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .iso8601
    }
    
    func request<T: Decodable>(
        endpoint: Endpoint,
        method: HTTPMethod = .get,
        parameters: [String: Any]? = nil,
        headers: [String: String]? = nil,
        responseType: T.Type
    ) async throws -> T {
        var urlRequest = URLRequest(url: baseURL.appendingPathComponent(endpoint.path))
        urlRequest.httpMethod = method.rawValue
        
        if let token = TokenManager.token {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        headers?.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        
        if let parameters = parameters {
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        }
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.unknown
        }
        
        switch httpResponse.statusCode {
        case 200..<300:
            let decodedData = try jsonDecoder.decode(T.self, from: data)
            return decodedData
        case 401:
            throw APIError.unauthorized
        case 404:
            throw APIError.notFound
        case 409:
            throw APIError.conflict
        case 500..<600:
            throw APIError.serverError
        default:
            throw APIError.requestFailed(statusCode: httpResponse.statusCode, data: data)
        }
    }
}
