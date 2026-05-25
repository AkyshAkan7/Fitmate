//
//  AppDependencies.swift
//  Fitmate
//
//  Created by Akan Akysh on 29/04/26.
//

import Foundation
import SwiftData

@MainActor
enum AppDependencies {
    static let tokenStorage: TokenStorage = KeychainTokenStorage()
    static let apiClient: APIClient = DefaultAPIClient(tokenStorage: tokenStorage)

    // Services
    static let exerciseService: ExerciseService = DefaultExerciseService(client: apiClient)
    static let authService: AuthService = DefaultAuthService(client: apiClient, tokenStorage: tokenStorage)

    // Repositories (требуют ModelContext — инстанцируются на месте использования)
    static func workoutHistoryRepository(context: ModelContext) -> WorkoutHistoryRepository {
        SwiftDataWorkoutHistoryRepository(context: context)
    }

    static func exerciseCatalogRepository(context: ModelContext) -> ExerciseCatalogRepository {
        SwiftDataExerciseCatalogRepository(context: context, service: exerciseService)
    }
}
