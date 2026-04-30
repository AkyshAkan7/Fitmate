//
//  ExerciseService.swift
//  Fitmate
//
//  Created by Akan Akysh on 27/04/26.
//

import Foundation

protocol ExerciseService: Sendable {
    func fetchMuscleGroups() async throws -> [MuscleGroupSection]
}

final class DefaultExerciseService: ExerciseService {
    private let client: APIClient

    init(client: APIClient) {
        self.client = client
    }

    func fetchMuscleGroups() async throws -> [MuscleGroupSection] {
        let dtos: [MuscleGroupDTO] = try await client.send(ExerciseEndpoint.list)
        return dtos.map(\.toDomain)
    }
}

// MARK: - Endpoints

private enum ExerciseEndpoint: Endpoint {
    case list

    var path: String { "/exercises" }
    var method: HTTPMethod { .get }
    var requiresAuth: Bool { false }
}

// MARK: - DTO

private struct MuscleGroupDTO: Decodable {
    let id: String
    let name: String
    let nameRu: String
    let exercises: [ExerciseDTO]

    var toDomain: MuscleGroupSection {
        MuscleGroupSection(
            id: id,
            name: name,
            nameRu: nameRu,
            exercises: exercises.map(\.toDomain)
        )
    }
}

private struct ExerciseDTO: Decodable {
    let id: String
    let name: String
    let nameRu: String
    let subtitle: String
    let subtitleRu: String
    let imageLink: String?

    var toDomain: CatalogExercise {
        CatalogExercise(
            id: id,
            name: name,
            nameRu: nameRu,
            subtitle: subtitle,
            subtitleRu: subtitleRu,
            imageLink: imageLink
        )
    }
}
