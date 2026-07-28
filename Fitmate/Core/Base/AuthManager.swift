//
//  AuthManager.swift
//  Fitmate
//
//  Created by Akan Akysh on 04/02/26.
//

import SwiftUI
import Combine
import GoogleSignIn

@MainActor
final class AuthManager: ObservableObject {
    @Published var isAuthenticated: Bool
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let authService: AuthService

    init(authService: AuthService = AppDependencies.authService) {
        self.authService = authService
        self.isAuthenticated = authService.isAuthenticated
    }

    func signInWithGoogle() async {
        guard let rootViewController = UIApplication.shared.rootViewController else {
            errorMessage = "Не удалось открыть окно авторизации"
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            guard let serverAuthCode = result.serverAuthCode else {
                errorMessage = "Не удалось получить код авторизации от Google"
                return
            }
            try await authService.signInWithGoogle(serverAuthCode: serverAuthCode)
            isAuthenticated = true
        } catch let error as GIDSignInError where error.code == .canceled {
            // User dismissed the Google sheet - not an error worth surfacing.
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }

    func signInWithApple() async {
        isLoading = true
        defer { isLoading = false }

        let coordinator = AppleSignInCoordinator()
        do {
            let identityToken = try await coordinator.signIn()
            try await authService.signInWithApple(identityToken: identityToken)
            isAuthenticated = true
        } catch AppleSignInError.cancelled {
            // User dismissed the Apple sheet - not an error worth surfacing.
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }

    func signOut() {
        authService.signOut()
        isAuthenticated = false
    }
}
