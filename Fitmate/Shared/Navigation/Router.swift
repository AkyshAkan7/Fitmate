//
//  Router.swift
//  Fitmate
//
//  Created by Akan Akysh on 22/02/26.
//

import SwiftUI
import Combine

// MARK: - Route

enum Route: Hashable {
    case profile
    case exerciseSelection(mode: ExerciseSelectionMode)
    case workoutConfirm(exercises: [Exercise])
    case workoutSession(exercises: [Exercise])
    case workoutComplete
    case createTemplate
    case confirmTemplate(templateName: String, exercises: [Exercise])
    case createCustomExercise
    case replaceExercise
    case strengthProgress
    case exerciseProgress(name: String, subtitle: String)
}

// MARK: - Router

final class Router: ObservableObject {
    @Published var path = NavigationPath()

    var onExerciseReplace: ((Exercise) -> Void)?

    func navigate(to route: Route) {
        path.append(route)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path = NavigationPath()
    }
}
