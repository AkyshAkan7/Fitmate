//
//  ExerciseSelectionViewModel.swift
//  Fitmate
//
//  Created by Akan Akysh on 29/04/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class ExerciseSelectionViewModel {
    enum LoadState: Equatable {
        case idle
        case loading
        case loaded
        case failed(String)
    }

    private(set) var state: LoadState = .idle
    private(set) var availableGroups: [MuscleGroup] = []
    private(set) var exercisesByGroup: [MuscleGroup: [Exercise]] = [:]

    var allExercises: [Exercise] {
        availableGroups.flatMap { exercisesByGroup[$0] ?? [] }
    }

    func exercises(for group: MuscleGroup) -> [Exercise] {
        exercisesByGroup[group] ?? []
    }

    func load(repository: ExerciseCatalogRepository) async {
        // 1. Сначала — кеш (мгновенно, если есть).
        if let cached = try? repository.cachedMuscleGroups(), !cached.isEmpty {
            apply(local: cached)
            state = .loaded
        } else if exercisesByGroup.isEmpty {
            state = .loading
        }

        // 2. Затем — refresh с сети.
        do {
            try await repository.refreshFromNetwork()
            if let updated = try? repository.cachedMuscleGroups() {
                apply(local: updated)
                state = .loaded
            }
        } catch {
            // Если кеш уже отрисован — молча оставляем его.
            if exercisesByGroup.isEmpty {
                state = .failed(error.localizedDescription)
            }
        }
    }

    private func apply(local groups: [MuscleGroupLocal]) {
        var availableGroups: [MuscleGroup] = []
        var byGroup: [MuscleGroup: [Exercise]] = [:]

        for local in groups {
            let group = MuscleGroup(id: local.id, name: local.name, nameRu: local.nameRu)
            availableGroups.append(group)
            byGroup[group] = local.exercises.map { ex in
                Exercise(
                    catalogId: ex.id,
                    name: ex.nameRu,
                    subtitle: ex.subtitleRu,
                    muscleGroup: group,
                    imageURL: ex.imageLink.flatMap { URL(string: $0) }
                )
            }
        }

        self.availableGroups = availableGroups
        self.exercisesByGroup = byGroup
    }
}
