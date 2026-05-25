//
//  LocalUserManager.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 02.06.25.
//

import SwiftUI

@MainActor
class LocalUserManager: ObservableObject {
    @AppStorage("userProfile") private var userProfileData: String?

    var profile: LocalUser {
        get {
            guard let data = userProfileData?.data(using: .utf8),
                  let decoded = try? JSONDecoder().decode(LocalUser.self, from: data)
            else {
                return LocalUser.default
            }
            return decoded
        }
        set {
            // `@AppStorage` in a non-View ObservableObject does not automatically
            // trigger `objectWillChange`, so views observing this manager via
            // `@EnvironmentObject` would not re-render on profile-only changes
            // (e.g. flipping `isEmailVerified` from a deep link). Notify explicitly.
            objectWillChange.send()
            if let data = try? JSONEncoder().encode(newValue),
               let jsonString = String(data: data, encoding: .utf8) {
                userProfileData = jsonString
            }
        }
    }

    /// Pulls the latest user from the server and writes it through to `profile`.
    /// Returns the fresh DTO on success, `nil` if there is no auth token, and
    /// rethrows any network or decoding error so callers can show feedback.
    @discardableResult
    func refreshFromServer() async throws -> UserDTO? {
        guard TokenManager.token != nil else { return nil }

        let dto = try await NetworkManager.shared.request(
            endpoint: .me(),
            method: .get,
            responseType: UserDTO.self
        )

        apply(dto)
        return dto
    }

    /// Overwrites `profile` with values from a fresh server DTO, preserving the
    /// `isSignedInToServer` flag (always true when we just successfully called `/me`).
    func apply(_ dto: UserDTO) {
        profile = LocalUser(
            id: dto.id,
            username: dto.username,
            name: dto.name,
            email: dto.email,
            isSignedInToServer: true,
            isEmailVerified: dto.isEmailVerified,
            authProvider: dto.authProvider
        )
    }
}
