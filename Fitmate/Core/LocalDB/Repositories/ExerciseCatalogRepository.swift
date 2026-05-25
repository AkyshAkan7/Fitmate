//
//  ExerciseCatalogRepository.swift
//  Fitmate
//
//  Created by Akan Akysh on 24/05/26.
//

import Foundation

@MainActor
protocol ExerciseCatalogRepository: Sendable {
    func cachedMuscleGroups() throws -> [MuscleGroupLocal]
    func refreshFromNetwork() async throws
}
