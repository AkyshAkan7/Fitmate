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
            sortBy: [SortDescriptor(\.sortOrder)]
        )
        return try context.fetch(descriptor)
    }

    func refreshFromNetwork() async throws {
        let sections = try await service.fetchMuscleGroups()

        try replaceCache(with: sections)
    }

    private func replaceCache(with sections: [MuscleGroupSection]) throws {
        let existingGroups = try context.fetch(FetchDescriptor<MuscleGroupLocal>())
        let existingExercises = try context.fetch(FetchDescriptor<ExerciseLocal>())

        var groupsById = Dictionary(existingGroups.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        var exercisesById = Dictionary(existingExercises.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })

        var incomingGroupIds = Set<String>()
        var incomingExerciseIds = Set<String>()

        for (index, section) in sections.enumerated() {
            incomingGroupIds.insert(section.id)

            let group: MuscleGroupLocal
            if let existing = groupsById[section.id] {
                existing.name = section.name
                existing.nameRu = section.nameRu
                existing.sortOrder = index
                group = existing
            } else {
                group = MuscleGroupLocal(
                    id: section.id,
                    name: section.name,
                    nameRu: section.nameRu,
                    sortOrder: index
                )
                context.insert(group)
                groupsById[section.id] = group
            }

            for (exerciseIndex, exercise) in section.exercises.enumerated() {
                incomingExerciseIds.insert(exercise.id)

                if let existing = exercisesById[exercise.id] {
                    existing.name = exercise.name
                    existing.nameRu = exercise.nameRu
                    existing.subtitle = exercise.subtitle
                    existing.subtitleRu = exercise.subtitleRu
                    existing.imageLink = exercise.imageLink
                    existing.sortOrder = exerciseIndex
                    existing.muscleGroup = group
                } else {
                    let local = ExerciseLocal(
                        id: exercise.id,
                        name: exercise.name,
                        nameRu: exercise.nameRu,
                        subtitle: exercise.subtitle,
                        subtitleRu: exercise.subtitleRu,
                        imageLink: exercise.imageLink,
                        sortOrder: exerciseIndex
                    )
                    local.muscleGroup = group
                    context.insert(local)
                    exercisesById[exercise.id] = local
                }
            }
        }

        for exercise in existingExercises where !incomingExerciseIds.contains(exercise.id) {
            context.delete(exercise)
        }

        for group in existingGroups where !incomingGroupIds.contains(group.id) {
            context.delete(group)
        }

        try context.save()
    }
}
