//
//  CustomExerciseStore.swift
//  Fitmate
//
//  Created by Akan Akysh on 08/04/26.
//

import SwiftUI
import Combine

final class CustomExerciseStore: ObservableObject {
    @Published var exercises: [Exercise] = []

    func add(name: String) {
        let exercise = Exercise(name: name, subtitle: "Моё упражнение", muscleGroup: MuscleGroup.custom)
        exercises.append(exercise)
    }

    func remove(at index: Int) {
        exercises.remove(at: index)
    }
}
