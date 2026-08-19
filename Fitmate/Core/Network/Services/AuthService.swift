//
//  AuthService.swift
//  Fitmate
//
//  Created by Akan Akysh on 27/04/26.
//

import Foundation

protocol AuthService: Sendable {
    var isAuthenticated: Bool { get }
    func signInWithApple(identityToken: String) async throws
    func signOut()
    func deleteAccount() async throws
}

final class DefaultAuthService: AuthService {
    private let client: APIClient
    private let tokenStorage: TokenStorage

    init(client: APIClient, tokenStorage: TokenStorage) {
        self.client = client
        self.tokenStorage = tokenStorage
    }

    var isAuthenticated: Bool {
        tokenStorage.read() != nil
    }

    func signInWithApple(identityToken: String) async throws {
        let response: TokenResponse = try await client.send(
            AuthEndpoint.apple(identityToken: identityToken)
        )
        tokenStorage.save(response.token)
    }

    func signOut() {
        tokenStorage.clear()
    }

    func deleteAccount() async throws {
        try await client.send(AuthEndpoint.deleteAccount)
        tokenStorage.clear()
    }
}

// MARK: - Endpoints

private enum AuthEndpoint: Endpoint {
    case apple(identityToken: String)
    case deleteAccount

    var path: String {
        switch self {
        case .apple: "/auth/apple"
        case .deleteAccount: "/user"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .apple: .post
        case .deleteAccount: .delete
        }
    }

    var requiresAuth: Bool {
        switch self {
        case .apple: false
        case .deleteAccount: true
        }
    }

    var body: (any Encodable)? {
        switch self {
        case .apple(let identityToken):
            AppleSignInRequest(identityToken: identityToken)
        case .deleteAccount:
            nil
        }
    }
}

// MARK: - DTO

private struct AppleSignInRequest: Encodable {
    let identityToken: String
}

private struct TokenResponse: Decodable {
    let token: String
}
