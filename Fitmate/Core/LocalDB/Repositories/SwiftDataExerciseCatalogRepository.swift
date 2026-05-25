//
//  SwiftDataExerciseCatalogRepository.swift
//  Fitmate
//
//  Created by Akan Akysh on 24/05/26.
//

import Foundation
import SwiftData

@MainActor
final class SwiftDataExerciseCatalogRepository: ExerciseCatalogRepository {
    private let context: ModelContext
    private let service: ExerciseService

    init(context: ModelContext, service: ExerciseService) {
        self.context = context
        self.service = service
    }

    func cachedMuscleGroups() throws -> [MuscleGroupLocal] {
        let descriptor = FetchDescriptor<MuscleGroupLocal>(
            sortBy: [SortDescriptor(\.nameRu)]
        )
        return try context.fetch(descriptor)
    }

    func refreshFromNetwork() async throws {
        let sections = try await service.fetchMuscleGroups()

        try replaceCache(with: sections)
    }

    private func replaceCache(with sections: [MuscleGroupSection]) throws {
        try context.delete(model: ExerciseLocal.self)
        try context.delete(model: MuscleGroupLocal.self)

        for section in sections {
            let group = MuscleGroupLocal(
                id: section.id,
                name: section.name,
                nameRu: section.nameRu
            )
            context.insert(group)

            for exercise in section.exercises {
                let local = ExerciseLocal(
                    id: exercise.id,
                    name: exercise.name,
                    nameRu: exercise.nameRu,
                    subtitle: exercise.subtitle,
                    subtitleRu: exercise.subtitleRu,
                    imageLink: exercise.imageLink
                )
                local.muscleGroup = group
                context.insert(local)
            }
        }

        try context.save()
    }
}
