//
//  SwiftDataWorkoutHistoryRepository.swift
//  Fitmate
//
//  Created by Akan Akysh on 24/05/26.
//

import Foundation
import SwiftData

@MainActor
final class SwiftDataWorkoutHistoryRepository: WorkoutHistoryRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func all() throws -> [WorkoutLocal] {
        let descriptor = FetchDescriptor<WorkoutLocal>(
            sortBy: [SortDescriptor(\.startedAt, order: .reverse)]
        )
        return try context.fetch(descriptor)
    }

    func activeWorkout() throws -> WorkoutLocal? {
        let descriptor = FetchDescriptor<WorkoutLocal>(
            predicate: #Predicate { $0.endedAt == nil }
        )
        return try context.fetch(descriptor).first
    }

    func find(id: UUID) throws -> WorkoutLocal? {
        let descriptor = FetchDescriptor<WorkoutLocal>(
            predicate: #Predicate { $0.id == id }
        )
        return try context.fetch(descriptor).first
    }

    func save(_ workout: WorkoutLocal) throws {
        if workout.modelContext == nil {
            context.insert(workout)
        }
        try context.save()
    }

    func delete(id: UUID) throws {
        let descriptor = FetchDescriptor<WorkoutLocal>(
            predicate: #Predicate { $0.id == id }
        )
        guard let workout = try context.fetch(descriptor).first else { return }
        context.delete(workout)
        try context.save()
    }

    func unsynced() throws -> [WorkoutLocal] {
        let descriptor = FetchDescriptor<WorkoutLocal>(
            predicate: #Predicate { $0.synced == false && $0.endedAt != nil }
        )
        return try context.fetch(descriptor)
    }

    func markSynced(ids: [UUID]) throws {
        guard !ids.isEmpty else { return }
        let descriptor = FetchDescriptor<WorkoutLocal>(
            predicate: #Predicate { ids.contains($0.id) }
        )
        let workouts = try context.fetch(descriptor)
        for workout in workouts {
            workout.synced = true
        }
        try context.save()
    }
}
