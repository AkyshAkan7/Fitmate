//
//  AppDependencies.swift
//  Fitmate
//
//  Created by Akan Akysh on 29/04/26.
//

import Foundation

@MainActor
enum AppDependencies {
    static let tokenStorage: TokenStorage = KeychainTokenStorage()
    static let apiClient: APIClient = DefaultAPIClient(tokenStorage: tokenStorage)

    // Services
    static let exerciseService: ExerciseService = DefaultExerciseService(client: apiClient)
    static let authService: AuthService = DefaultAuthService(client: apiClient, tokenStorage: tokenStorage)
}
