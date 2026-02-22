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
    case quickStart
    case workoutConfirm(exercises: [Exercise])
    case createTemplate
}

// MARK: - Router

final class Router: ObservableObject {
    @Published var path = NavigationPath()

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
