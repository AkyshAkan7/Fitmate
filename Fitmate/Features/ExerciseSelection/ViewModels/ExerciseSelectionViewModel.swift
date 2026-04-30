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

    private let service: ExerciseService

    init() {
        self.service = AppDependencies.exerciseService
    }

    init(service: ExerciseService) {
        self.service = service
    }

    var allExercises: [Exercise] {
        availableGroups.flatMap { exercisesByGroup[$0] ?? [] }
    }

    func exercises(for group: MuscleGroup) -> [Exercise] {
        exercisesByGroup[group] ?? []
    }

    func load() async {
        if case .loaded = state { return }
        state = .loading
        do {
            let sections = try await service.fetchMuscleGroups()
            apply(sections)
            state = .loaded
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    private func apply(_ sections: [MuscleGroupSection]) {
        var groups: [MuscleGroup] = []
        var byGroup: [MuscleGroup: [Exercise]] = [:]

        for section in sections {
            let group = MuscleGroup(id: section.id, name: section.name, nameRu: section.nameRu)
            groups.append(group)
            byGroup[group] = section.exercises.map {
                Exercise(
                    name: $0.nameRu,
                    subtitle: $0.subtitleRu,
                    muscleGroup: group,
                    imageURL: $0.imageLink.flatMap { URL(string: $0) }
                )
            }
        }

        availableGroups = groups
        exercisesByGroup = byGroup
    }
}
