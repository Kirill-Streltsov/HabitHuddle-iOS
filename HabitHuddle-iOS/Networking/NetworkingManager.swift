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
    let jsonEncoder: JSONEncoder

    private init() {
        jsonDecoder = JSONDecoder()
        jsonEncoder = JSONEncoder()
        jsonDecoder.dateDecodingStrategy = .iso8601
        jsonEncoder.dateEncodingStrategy = .iso8601
    }

    func request<T: Decodable, U: Encodable>(
        endpoint: Endpoint,
        method: HTTPMethod = .post,
        body: U,
        headers: [String: String]? = nil,
        responseType _: T.Type
    ) async throws -> T {
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
        print("DATA: \(body)")

        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let response = response as? HTTPURLResponse else {
            throw APIError.unknown
        }
        return try handleResponse(data: data, response: response, responseType: T.self)
    }

    func request<T: Decodable>(
        endpoint: Endpoint,
        method: HTTPMethod = .get,
        headers: [String: String]? = nil,
        responseType _: T.Type
    ) async throws -> T {
        var urlRequest = URLRequest(url: baseURL.appendingPathComponent(endpoint.path))
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

    func handleResponse<T: Decodable>(data: Data, response: HTTPURLResponse, responseType _: T.Type) throws -> T {
        switch response.statusCode {
        case 200 ..< 300:
            let decodedData = try jsonDecoder.decode(T.self, from: data)
            return decodedData
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

extension Data {
    var prettyPrintedJSONString: NSString? {
        guard let jsonObject = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: jsonObject,
                                                     options: [.prettyPrinted]),
              let prettyJSON = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        else {
            return nil
        }

        return prettyJSON
    }
}
