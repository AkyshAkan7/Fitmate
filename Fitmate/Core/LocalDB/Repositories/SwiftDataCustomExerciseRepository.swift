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

    init(context: ModelContext) {
        self.context = context
    }

    func all() throws -> [CustomExerciseLocal] {
        let descriptor = FetchDescriptor<CustomExerciseLocal>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try context.fetch(descriptor)
    }

    func save(name: String) throws {
        let exercise = CustomExerciseLocal(name: name, subtitle: "Моё упражнение")
        context.insert(exercise)
        try context.save()
    }

    func delete(id: UUID) throws {
        let descriptor = FetchDescriptor<CustomExerciseLocal>(
            predicate: #Predicate { $0.id == id }
        )
        guard let exercise = try context.fetch(descriptor).first else { return }
        context.delete(exercise)
        try context.save()
    }
}
