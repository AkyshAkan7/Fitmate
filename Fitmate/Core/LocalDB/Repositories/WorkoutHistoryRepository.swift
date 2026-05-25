//
//  WorkoutHistoryRepository.swift
//  Fitmate
//
//  Created by Akan Akysh on 24/05/26.
//

import Foundation

@MainActor
protocol WorkoutHistoryRepository: Sendable {
    func all() throws -> [WorkoutLocal]
    func activeWorkout() throws -> WorkoutLocal?
    func find(id: UUID) throws -> WorkoutLocal?
    func save(_ workout: WorkoutLocal) throws
    func delete(id: UUID) throws
    func unsynced() throws -> [WorkoutLocal]
    func markSynced(ids: [UUID]) throws
}
