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

    // ID упражнений, которые юзер реально делал в завершённых тренировках
    private var doneExerciseIds: Set<String> {
        Set(
            workouts
                .filter { $0.endedAt != nil }
                .flatMap { $0.exercises }
                .map { $0.exerciseId }
                .filter { !$0.isEmpty }
        )
    }

    // Группы, в которых есть хоть одно сделанное упражнение
    private var availableGroups: [MuscleGroup] {
        let doneGroupIds = Set(
            allExercises
                .filter { doneExerciseIds.contains($0.id) }
                .compactMap { $0.muscleGroup?.id }
        )
        return allMuscleGroups
            .filter { doneGroupIds.contains($0.id) }
            .map { MuscleGroup(id: $0.id, name: $0.name, nameRu: $0.nameRu) }
    }

    // Упражнения выбранной группы, которые юзер делал
    private var groupExercises: [ExerciseLocal] {
        guard let group = selectedGroup ?? availableGroups.first else { return [] }
        return allExercises.filter { ex in
            ex.muscleGroup?.id == group.id && doneExerciseIds.contains(ex.id)
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
                ForEach(groupExercises) { exercise in
                    AppCell(
                        icon: Image(systemName: "dumbbell"),
                        iconURL: exercise.imageLink.flatMap { URL(string: $0) },
                        title: exercise.nameRu,
                        subtitle: exercise.subtitleRu,
                        trailingIcon: Image("chevronRight")
                    ) {
                        router.navigate(to: .exerciseProgress(name: exercise.nameRu, subtitle: exercise.subtitleRu))
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

#Preview {
    StrengthProgressView()
}
