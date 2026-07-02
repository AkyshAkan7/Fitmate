//
//  CustomExerciseRepository.swift
//  Fitmate
//
//  Created by Akan Akysh on 02/07/26.
//

import Foundation

@MainActor
protocol CustomExerciseRepository: Sendable {
    func all() throws -> [CustomExerciseLocal]
    func save(name: String) throws
    func delete(id: UUID) throws
}
