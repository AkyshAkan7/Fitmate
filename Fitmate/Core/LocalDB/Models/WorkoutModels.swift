//
//  WorkoutModels.swift
//  Fitmate
//
//  Created by Akan Akysh on 24/05/26.
//

import Foundation
import SwiftData

// MARK: - Workout

@Model
final class WorkoutLocal {
    @Attribute(.unique) var id: UUID
    var startedAt: Date
    var endedAt: Date?
    var notes: String
    var synced: Bool

    @Relationship(deleteRule: .cascade, inverse: \WorkoutExerciseLocal.workout)
    var exercises: [WorkoutExerciseLocal] = []

    init(
        id: UUID = UUID(),
        startedAt: Date = .now,
        endedAt: Date? = nil,
        notes: String = "",
        synced: Bool = false
    ) {
        self.id = id
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.notes = notes
        self.synced = synced
    }
}

// MARK: - Workout Exercise

@Model
final class WorkoutExerciseLocal {
    @Attribute(.unique) var id: UUID
    var exerciseId: String
    var sortOrder: Int

    // Денормализованный снапшот каталога — чтобы история работала
    // полностью оффлайн и переживала удаление/переименование упражнения.
    // В sync на сервер эти поля не отправляются.
    var exerciseName: String
    var exerciseSubtitle: String
    var exerciseImageLink: String?

    var workout: WorkoutLocal?

    @Relationship(deleteRule: .cascade, inverse: \WorkoutSetLocal.exercise)
    var sets: [WorkoutSetLocal] = []

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

// MARK: - Workout Set

@Model
final class WorkoutSetLocal {
    @Attribute(.unique) var id: UUID
    var weight: Double
    var reps: Int
    var createdAt: Date
    var exercise: WorkoutExerciseLocal?

    init(
        id: UUID = UUID(),
        weight: Double,
        reps: Int,
        createdAt: Date = .now
    ) {
        self.id = id
        self.weight = weight
        self.reps = reps
        self.createdAt = createdAt
    }
}
