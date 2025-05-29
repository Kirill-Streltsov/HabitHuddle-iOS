//
//  TokenManager.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 19.05.25.
//

import Foundation
import Security

enum TokenManager {
    private static let tokenKey = "authToken"
    private static let service = "com.krlsrlsv.HabitHuddle-iOS"

    static var token: String? {
        get {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: tokenKey,
                kSecReturnData as String: true,
                kSecMatchLimit as String: kSecMatchLimitOne
            ]

            var dataTypeRef: AnyObject?

            let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

            if status == errSecSuccess, let data = dataTypeRef as? Data {
                return String(data: data, encoding: .utf8)
            }

            return nil
        }

        set {
            // First remove any existing item
            clearToken()

            guard let token = newValue else { return }

            let data = Data(token.utf8)
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: tokenKey,
                kSecValueData as String: data
            ]

            SecItemAdd(query as CFDictionary, nil)
        }
    }

    static func clearToken() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: tokenKey
        ]
        SecItemDelete(query as CFDictionary)
    }
}
