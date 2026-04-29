//
//  AuthService.swift
//  Fitmate
//
//  Created by Akan Akysh on 27/04/26.
//

import Foundation

protocol AuthService: Sendable {
    func signIn(email: String, password: String) async throws
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

    func signIn(email: String, password: String) async throws {
        let response: SignInResponse = try await client.send(
            AuthEndpoint.signIn(email: email, password: password)
        )
        tokenStorage.save(response.accessToken)
    }

    func signOut() {
        tokenStorage.clear()
    }
}

// MARK: - Endpoints

private enum AuthEndpoint: Endpoint {
    case signIn(email: String, password: String)

    var path: String {
        switch self {
        case .signIn: "/auth/sign-in"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .signIn: .post
        }
    }

    var requiresAuth: Bool { false }

    var body: (any Encodable)? {
        switch self {
        case .signIn(let email, let password):
            SignInRequest(email: email, password: password)
        }
    }
}

// MARK: - DTO

private struct SignInRequest: Encodable {
    let email: String
    let password: String
}

private struct SignInResponse: Decodable {
    let accessToken: String
}
