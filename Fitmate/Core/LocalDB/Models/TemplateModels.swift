//
//  TemplateModels.swift
//  Fitmate
//
//  Created by Akan Akysh on 02/07/26.
//

import Foundation
import SwiftData

// MARK: - Workout Template

@Model
final class WorkoutTemplateLocal {
    @Attribute(.unique) var id: UUID
    var name: String
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \WorkoutTemplateExerciseLocal.template)
    var exercises: [WorkoutTemplateExerciseLocal] = []

    init(
        id: UUID = UUID(),
        name: String,
        createdAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
    }
}

// MARK: - Workout Template Exercise

@Model
final class WorkoutTemplateExerciseLocal {
    @Attribute(.unique) var id: UUID
    var exerciseId: String
    var sortOrder: Int

    // Денормализованный снапшот каталога — чтобы шаблон работал оффлайн
    // и переживал удаление/переименование упражнения.
    var exerciseName: String
    var exerciseSubtitle: String
    var exerciseImageLink: String?

    var template: WorkoutTemplateLocal?

    init(
        id: UUID = UUID(),
        exerciseId: String,
        sortOrder: Int,
        exerciseName: String,
        exerciseSubtitle: String,
        exerciseImageLink: String? = nil
    ) {
        self.id = id
        self.exerciseId = exerciseId
        self.sortOrder = sortOrder
        self.exerciseName = exerciseName
        self.exerciseSubtitle = exerciseSubtitle
        self.exerciseImageLink = exerciseImageLink
    }
}
