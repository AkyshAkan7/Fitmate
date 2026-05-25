//
//  CatalogModels.swift
//  Fitmate
//
//  Created by Akan Akysh on 24/05/26.
//

import Foundation
import SwiftData

// MARK: - Muscle Group

@Model
final class MuscleGroupLocal {
    @Attribute(.unique) var id: String
    var name: String
    var nameRu: String

    @Relationship(deleteRule: .cascade, inverse: \ExerciseLocal.muscleGroup)
    var exercises: [ExerciseLocal] = []

    init(
        id: String,
        name: String,
        nameRu: String
    ) {
        self.id = id
        self.name = name
        self.nameRu = nameRu
    }
}

// MARK: - Exercise (catalog)

@Model
final class ExerciseLocal {
    @Attribute(.unique) var id: String
    var name: String
    var nameRu: String
    var subtitle: String
    var subtitleRu: String
    var imageLink: String?
    var muscleGroup: MuscleGroupLocal?

    init(
        id: String,
        name: String,
        nameRu: String,
        subtitle: String,
        subtitleRu: String,
        imageLink: String? = nil
    ) {
        self.id = id
        self.name = name
        self.nameRu = nameRu
        self.subtitle = subtitle
        self.subtitleRu = subtitleRu
        self.imageLink = imageLink
    }
}
