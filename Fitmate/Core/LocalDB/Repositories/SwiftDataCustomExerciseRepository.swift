//
//  SwiftDataCustomExerciseRepository.swift
//  Fitmate
//
//  Created by Akan Akysh on 02/07/26.
//

import Foundation
import SwiftData

@MainActor
final class SwiftDataCustomExerciseRepository: CustomExerciseRepository {
    private let context: ModelContext
    private let service: ExerciseService

    init(context: ModelContext, service: ExerciseService) {
        self.context = context
        self.service = service
    }

    func all() throws -> [CustomExerciseLocal] {
        let descriptor = FetchDescriptor<CustomExerciseLocal>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try context.fetch(descriptor)
    }

    func save(name: String) async throws {
        let exercise = CustomExerciseLocal(name: name, subtitle: "Моё упражнение")
        context.insert(exercise)
        try context.save()

        // Локальное сохранение — источник правды и работает офлайн/без
        // авторизации. Синк на бэк — best-effort: без авторизации/сети
        // эндпоинт недоступен, но `synced` остаётся false, и запись
        // дозальётся через syncPending() при следующем входе.
        do {
            try await service.createCustomExercise(nameRu: name, name: name, imageLink: "")
            exercise.synced = true
            try? context.save()
        } catch {}
    }

    func syncPending() async {
        guard let pending = try? context.fetch(
            FetchDescriptor<CustomExerciseLocal>(predicate: #Predicate { !$0.synced })
        ), !pending.isEmpty else { return }

        for exercise in pending {
            do {
                try await service.createCustomExercise(nameRu: exercise.name, name: exercise.name, imageLink: "")
                exercise.synced = true
            } catch {}
        }
        try? context.save()
    }

    func delete(id: UUID) throws {
        let descriptor = FetchDescriptor<CustomExerciseLocal>(
            predicate: #Predicate { $0.id == id }
        )
        guard let exercise = try context.fetch(descriptor).first else { return }

        // На бэке нет DELETE /exercises — при следующем GET /exercises сервер
        // снова пришлёт это упражнение в группе "custom". Запоминаем имя,
        // чтобы SwiftDataExerciseCatalogRepository не воскрешал его при мёрдже.
        var deletedNames = Set(UserDefaults.standard.stringArray(forKey: StorageKeys.deletedCustomExerciseNames) ?? [])
        deletedNames.insert(exercise.name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased())
        UserDefaults.standard.set(Array(deletedNames), forKey: StorageKeys.deletedCustomExerciseNames)

        context.delete(exercise)
        try context.save()
    }
}
