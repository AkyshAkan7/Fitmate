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

        // Бэк подмешивает кастомные упражнения пользователя прямо в
        // GET /exercises отдельной группой "custom" — это не каталог,
        // а зеркало наших CustomExerciseLocal, обрабатываем отдельно.
        let catalogSections = sections.filter { $0.id != "custom" }
        let customSection = sections.first { $0.id == "custom" }

        try replaceCache(with: catalogSections)
        try mergeCustomExercises(from: customSection?.exercises ?? [])
    }

    private func mergeCustomExercises(from serverExercises: [CatalogExercise]) throws {
        let deletedNames = Set(
            UserDefaults.standard.stringArray(forKey: StorageKeys.deletedCustomExerciseNames) ?? []
        )

        let existing = try context.fetch(FetchDescriptor<CustomExerciseLocal>())
        let existingByName = Dictionary(
            existing.map { ($0.name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(), $0) },
            uniquingKeysWith: { first, _ in first }
        )

        for serverExercise in serverExercises {
            let normalizedName = serverExercise.nameRu.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            guard !deletedNames.contains(normalizedName) else { continue }

            if let local = existingByName[normalizedName] {
                // Уже знаем эту запись локально — просто подтверждаем синк
                // (самолечение на случай, если POST у нас "упал" по коду,
                // но на бэке всё же создалось).
                local.synced = true
            } else {
                // Есть на бэке, но не на этом устройстве — например, после
                // переустановки приложения или входа на новом устройстве.
                let local = CustomExerciseLocal(
                    name: serverExercise.nameRu,
                    subtitle: "Моё упражнение",
                    imageLink: serverExercise.imageLink,
                    synced: true
                )
                context.insert(local)
            }
        }

        try context.save()
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
