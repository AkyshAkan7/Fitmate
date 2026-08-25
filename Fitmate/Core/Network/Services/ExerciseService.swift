//
//  ExerciseService.swift
//  Fitmate
//
//  Created by Akan Akysh on 27/04/26.
//

import Foundation

protocol ExerciseService: Sendable {
    func fetchMuscleGroups() async throws -> [MuscleGroupSection]
    func createCustomExercise(nameRu: String, name: String, imageLink: String) async throws
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

    func createCustomExercise(nameRu: String, name: String, imageLink: String) async throws {
        try await client.send(ExerciseEndpoint.create(name: name, nameRu: nameRu, imageLink: imageLink))
    }
}

// MARK: - Endpoints

private enum ExerciseEndpoint: Endpoint {
    case list
    case create(name: String, nameRu: String, imageLink: String)

    var path: String { "/exercises" }

    var method: HTTPMethod {
        switch self {
        case .list: .get
        case .create: .post
        }
    }

    var requiresAuth: Bool {
        switch self {
        case .list: false
        case .create: true
        }
    }

    var body: (any Encodable)? {
        switch self {
        case .list:
            nil
        case .create(let name, let nameRu, let imageLink):
            CreateExerciseRequest(name: name, nameRu: nameRu, imageLink: imageLink)
        }
    }
}

// MARK: - Create Exercise Request

private struct CreateExerciseRequest: Encodable {
    let name: String
    let nameRu: String
    let imageLink: String
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
