//
//  AuthService.swift
//  Fitmate
//
//  Created by Akan Akysh on 27/04/26.
//

import Foundation

protocol AuthService: Sendable {
    func signInWithGoogle(serverAuthCode: String) async throws
    func signInWithApple(identityToken: String) async throws
    func signOut()
    var isAuthenticated: Bool { get }
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

    func signInWithGoogle(serverAuthCode: String) async throws {
        let response: AuthTokenResponse = try await client.send(
            AuthEndpoint.googleCallback(code: serverAuthCode)
        )
        tokenStorage.save(response.token)
    }

    func signInWithApple(identityToken: String) async throws {
        let response: AuthTokenResponse = try await client.send(
            AuthEndpoint.apple(identityToken: identityToken)
        )
        tokenStorage.save(response.token)
    }

    func signOut() {
        tokenStorage.clear()
    }
}

// MARK: - Endpoints

private enum AuthEndpoint: Endpoint {
    case googleCallback(code: String)
    case apple(identityToken: String)

    var path: String {
        switch self {
        case .googleCallback: "/auth/callback"
        case .apple: "/auth/apple"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .googleCallback: .get
        case .apple: .post
        }
    }

    var query: [URLQueryItem]? {
        switch self {
        case .googleCallback(let code):
            [URLQueryItem(name: "code", value: code)]
        case .apple:
            nil
        }
    }

    var requiresAuth: Bool { false }

    var body: (any Encodable)? {
        switch self {
        case .googleCallback:
            nil
        case .apple(let identityToken):
            AppleSignInRequest(identityToken: identityToken)
        }
    }
}

// MARK: - DTO

private struct AppleSignInRequest: Encodable {
    let identityToken: String
}

private struct AuthTokenResponse: Decodable {
    let token: String
}
