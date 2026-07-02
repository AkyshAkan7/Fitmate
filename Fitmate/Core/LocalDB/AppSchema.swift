//
//  AppSchema.swift
//  Fitmate
//
//  Created by Akan Akysh on 24/05/26.
//

import Foundation
import SwiftData

enum AppSchema {
    static let models: [any PersistentModel.Type] = [
        WorkoutLocal.self,
        WorkoutExerciseLocal.self,
        WorkoutSetLocal.self,
        MuscleGroupLocal.self,
        ExerciseLocal.self,
        WorkoutTemplateLocal.self,
        WorkoutTemplateExerciseLocal.self,
        CustomExerciseLocal.self
    ]

    @MainActor
    static func makeContainer() -> ModelContainer {
        do {
            return try ModelContainer(for: Schema(models))
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
}
