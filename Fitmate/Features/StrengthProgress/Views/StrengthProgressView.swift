//
//  StrengthProgressView.swift
//  Fitmate
//
//  Created by Akan Akysh on 30/04/26.
//

import SwiftUI
import SwiftData

struct StrengthProgressView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var router: Router

    @Query(sort: \MuscleGroupLocal.nameRu)
    private var allMuscleGroups: [MuscleGroupLocal]

    @Query(sort: \ExerciseLocal.nameRu)
    private var allExercises: [ExerciseLocal]

    @Query private var workouts: [WorkoutLocal]

    @State private var selectedGroup: MuscleGroup?

    private var completedWorkouts: [WorkoutLocal] {
        workouts.filter { $0.endedAt != nil }
    }

    // ID каталожных упражнений, которые юзер реально делал в завершённых тренировках
    private var doneExerciseIds: Set<String> {
        Set(
            completedWorkouts
                .flatMap { $0.exercises }
                .map { $0.exerciseId }
                .filter { !$0.isEmpty }
        )
    }

    // Сделанные кастомные упражнения (без exerciseId) — по уникальному имени
    private var doneCustomExercises: [ProgressRow] {
        var seen = Set<String>()
        var result: [ProgressRow] = []
        for exercise in completedWorkouts.flatMap({ $0.exercises }) where exercise.exerciseId.isEmpty {
            guard !exercise.exerciseName.isEmpty, seen.insert(exercise.exerciseName).inserted else { continue }
            result.append(
                ProgressRow(
                    id: "custom:\(exercise.exerciseName)",
                    name: exercise.exerciseName,
                    subtitle: exercise.exerciseSubtitle,
                    imageURL: exercise.exerciseImageLink.flatMap { URL(string: $0) },
                    exerciseId: ""
                )
            )
        }
        return result
    }

    // Группы, в которых есть хоть одно сделанное упражнение (+ «Мои» для кастомных)
    private var availableGroups: [MuscleGroup] {
        let doneGroupIds = Set(
            allExercises
                .filter { doneExerciseIds.contains($0.id) }
                .compactMap { $0.muscleGroup?.id }
        )
        var groups = allMuscleGroups
            .filter { doneGroupIds.contains($0.id) }
            .map { MuscleGroup(id: $0.id, name: $0.name, nameRu: $0.nameRu) }
        if !doneCustomExercises.isEmpty {
            groups.insert(.custom, at: 0)
        }
        return groups
    }

    // Строки выбранной группы, которые юзер делал
    private var groupExercises: [ProgressRow] {
        guard let group = selectedGroup ?? availableGroups.first else { return [] }
        if group.id == MuscleGroup.custom.id {
            return doneCustomExercises
        }
        return allExercises
            .filter { $0.muscleGroup?.id == group.id && doneExerciseIds.contains($0.id) }
            .map { exercise in
                ProgressRow(
                    id: exercise.id,
                    name: exercise.nameRu,
                    subtitle: exercise.subtitleRu,
                    imageURL: exercise.imageLink.flatMap { URL(string: $0) },
                    exerciseId: exercise.id
                )
            }
    }

    var body: some View {
        VStack(spacing: 0) {
            navigationBar

            if availableGroups.isEmpty {
                emptyState
            } else {
                content
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            if selectedGroup == nil {
                selectedGroup = availableGroups.first
            }
        }
        .onChange(of: availableGroups) { _, new in
            if let current = selectedGroup {
                if !new.contains(current) {
                    selectedGroup = new.first
                }
            } else {
                selectedGroup = new.first
            }
        }
    }

    // MARK: - Content

    private var content: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(groupExercises) { row in
                    AppCell(
                        icon: Image(systemName: "dumbbell"),
                        iconURL: row.imageURL,
                        title: row.name,
                        subtitle: row.subtitle,
                        trailingIcon: Image("chevronRight")
                    ) {
                        router.navigate(to: .exerciseProgress(name: row.name, subtitle: row.subtitle, exerciseId: row.exerciseId))
                    }
                }
            }
            .padding(.top, 16)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack {
            Spacer()
            Text("Нет данных")
                .body15Regular()
                .foregroundStyle(Color.appGray)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Navigation Bar

    private var navigationBar: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 16) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(Color.primary)
                    }

                    Text("Прогресс силовых")
                        .headline24Semibold()
                }
                .padding(.horizontal, 16)

                if !availableGroups.isEmpty {
                    AppChipGroup(
                        items: availableGroups,
                        selected: Binding(
                            get: { selectedGroup ?? availableGroups[0] },
                            set: { selectedGroup = $0 }
                        ),
                        titleFor: { $0.displayName }
                    )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 12)

            Divider()
        }
    }
}

// MARK: - Models

private struct ProgressRow: Identifiable {
    let id: String
    let name: String
    let subtitle: String
    let imageURL: URL?
    /// Пусто для кастомных — прогресс матчится по имени.
    let exerciseId: String
}

#Preview {
    StrengthProgressView()
}
