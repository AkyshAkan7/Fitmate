//
//  WorkoutTemplateRepository.swift
//  Fitmate
//
//  Created by Akan Akysh on 02/07/26.
//

import Foundation

@MainActor
protocol WorkoutTemplateRepository: Sendable {
    func all() throws -> [WorkoutTemplateLocal]
    func save(name: String, exercises: [Exercise]) throws
    func delete(id: UUID) throws
}
