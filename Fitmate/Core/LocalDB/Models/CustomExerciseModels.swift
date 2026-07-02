//
//  CustomExerciseModels.swift
//  Fitmate
//
//  Created by Akan Akysh on 02/07/26.
//

import Foundation
import SwiftData

// MARK: - Custom Exercise

@Model
final class CustomExerciseLocal {
    @Attribute(.unique) var id: UUID
    var name: String
    var subtitle: String
    var imageLink: String?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        subtitle: String,
        imageLink: String? = nil,
        createdAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.subtitle = subtitle
        self.imageLink = imageLink
        self.createdAt = createdAt
    }
}
