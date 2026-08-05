//
//  AuthManager.swift
//  Fitmate
//
//  Created by Akan Akysh on 04/02/26.
//

import SwiftUI
import Combine
import AuthenticationServices

@MainActor
final class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isSigningIn = false
    @Published var authErrorMessage: String?

    private let authService: AuthService
    private var appleCoordinator: AppleSignInCoordinator?

    init(authService: AuthService? = nil) {
        let service = authService ?? AppDependencies.authService
        self.authService = service
        self.isAuthenticated = service.isAuthenticated
    }

    func signInWithApple() async {
        guard !isSigningIn else { return }
        isSigningIn = true
        authErrorMessage = nil
        defer {
            isSigningIn = false
            appleCoordinator = nil
        }

        let coordinator = AppleSignInCoordinator()
        appleCoordinator = coordinator

        do {
            let credential = try await coordinator.signIn()
            guard let tokenData = credential.identityToken,
                  let identityToken = String(data: tokenData, encoding: .utf8) else {
                throw ASAuthorizationError(.invalidResponse)
            }

            // Apple передаёт имя только при первом входе — сохраняем сразу
            saveDisplayNameIfNeeded(credential.fullName)

            try await authService.signInWithApple(identityToken: identityToken)
            isAuthenticated = true
        } catch let error as ASAuthorizationError where error.code == .canceled {
            // пользователь закрыл окно — не ошибка
        } catch {
            authErrorMessage = "Не удалось войти. Попробуйте ещё раз"
        }
    }

    func signOut() {
        authService.signOut()
        isAuthenticated = false
    }

    private func saveDisplayNameIfNeeded(_ name: PersonNameComponents?) {
        guard let name else { return }
        let displayName = PersonNameComponentsFormatter.localizedString(from: name, style: .default)
        guard !displayName.isEmpty else { return }
        UserDefaults.standard.set(displayName, forKey: StorageKeys.userDisplayName)
    }
}
