//
//  GoogleAuthManager.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 20.06.25.
//

import GoogleSignIn
import UIKit

@MainActor
final class GoogleAuthManager {

    static let shared = GoogleAuthManager()

    private init() {}

    func signIn(completion: @escaping (Result<String, Error>) -> Void) {
        guard let presentingVC = UIApplication.topViewController() else {
            completion(.failure(NSError(domain: "NoRootVC", code: -1, userInfo: [NSLocalizedDescriptionKey: "No root view controller found."])))
            return
        }

        GIDSignIn.sharedInstance.signIn(withPresenting: presentingVC) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let idToken = result?.user.idToken?.tokenString else {
                completion(.failure(NSError(domain: "NoIDToken", code: -1, userInfo: [NSLocalizedDescriptionKey: "No ID Token found."])))
                return
            }
            completion(.success(idToken))
        }
    }
}
