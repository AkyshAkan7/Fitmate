//
//  WorkoutSet.swift
//  Fitmate
//
//  Created by Akan Akysh on 25/02/26.
//

import Foundation

// MARK: - Workout Set

struct WorkoutSet: Identifiable, Hashable {
    let id = UUID()
    var weight: Double
    var reps: Int
    var isCompleted: Bool = false

    var displayText: String {
        "\(Int(weight)) кг x \(reps)"
    }
}

// MARK: - Exercise Session

struct ExerciseSession: Identifiable {
    let id = UUID()
    let exercise: Exercise
    var sets: [WorkoutSet]
    var lastResult: String?

    init(exercise: Exercise, sets: [WorkoutSet] = [], lastResult: String? = nil) {
        self.exercise = exercise
        self.sets = sets
        self.lastResult = lastResult
    }

    static func == (lhs: ExerciseSession, rhs: ExerciseSession) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
