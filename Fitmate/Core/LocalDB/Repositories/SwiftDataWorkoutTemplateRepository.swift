//
//  SwiftDataWorkoutTemplateRepository.swift
//  Fitmate
//
//  Created by Akan Akysh on 02/07/26.
//

import Foundation
import SwiftData

@MainActor
final class SwiftDataWorkoutTemplateRepository: WorkoutTemplateRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func all() throws -> [WorkoutTemplateLocal] {
        let descriptor = FetchDescriptor<WorkoutTemplateLocal>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try context.fetch(descriptor)
    }

    func save(name: String, exercises: [Exercise]) throws {
        let template = WorkoutTemplateLocal(name: name)
        context.insert(template)

        for (index, exercise) in exercises.enumerated() {
            let templateExercise = WorkoutTemplateExerciseLocal(
                exerciseId: exercise.catalogId ?? "",
                sortOrder: index,
                exerciseName: exercise.name,
                exerciseSubtitle: exercise.subtitle,
                exerciseImageLink: exercise.imageURL?.absoluteString
            )
            templateExercise.template = template
        }

        try context.save()
    }

    func delete(id: UUID) throws {
        let descriptor = FetchDescriptor<WorkoutTemplateLocal>(
            predicate: #Predicate { $0.id == id }
        )
        guard let template = try context.fetch(descriptor).first else { return }
        context.delete(template)
        try context.save()
    }
}
