//
//  WorkoutSessionView.swift
//  Fitmate
//
//  Created by Akan Akysh on 25/02/26.
//

import SwiftUI

// MARK: - WorkoutSessionView

struct WorkoutSessionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var router: Router

    @State private var exerciseSessions: [ExerciseSession]
    @State private var selectedIndex: Int = 0
    @State private var showFinishAlert: Bool = false

    init(exercises: [Exercise]) {
        let sessions = exercises.map { exercise in
            ExerciseSession(
                exercise: exercise,
                sets: [],
                lastResult: "0 кг x 0"
            )
        }
        _exerciseSessions = State(initialValue: sessions)
    }

    // MARK: - Computed Properties

    private var currentSession: ExerciseSession {
        exerciseSessions[selectedIndex]
    }

    // MARK: - Actions

    private func selectExercise(at index: Int) {
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedIndex = index
        }
    }

    private func addSet() {
        let newSet = WorkoutSet(weight: 0, reps: 0)
        exerciseSessions[selectedIndex].sets.append(newSet)
    }

    private func finishWorkout() {
        showFinishAlert = true
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            navigationBar

            ScrollView {
                VStack(spacing: 0) {
                    exerciseSelector
                    exerciseInfo
                        .padding(.top, 16)
                    lastResultSection
                    setsSection
                }
                .padding(.top, 16)
            }

            bottomButton
        }
        .navigationBarHidden(true)
        .alert("Завершение", isPresented: $showFinishAlert) {
            Button("Нет", role: .cancel) {}
            Button("Да", role: .none) {
                router.navigate(to: .workoutComplete)
            }
            .keyboardShortcut(.defaultAction)
        } message: {
            Text("Все невыполненные упражнения не сохранятся. Точно завершить тренировку?")
        }
    }

    // MARK: - Navigation Bar

    private var navigationBar: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(Color.primary)
                }

                Spacer()

                Button {
                    finishWorkout()
                } label: {
                    Text("Завершить")
                        .body15Semibold()
                        .foregroundStyle(Color.red)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            Divider()
        }
    }

    // MARK: - Exercise Selector

    private var exerciseSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(exerciseSessions.enumerated()), id: \.element.id) { index, session in
                    exerciseThumbnail(for: session, at: index)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private func exerciseThumbnail(for session: ExerciseSession, at index: Int) -> some View {
        Button {
            selectExercise(at: index)
        } label: {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.lightGray)
                .frame(width: 72, height: 72)
                .overlay {
                    Image(systemName: "dumbbell")
                        .font(.system(size: 24))
                }
                .overlay {
                    if index == selectedIndex {
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(Color.appBlack, lineWidth: 1.5)
                    }
                }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Exercise Info

    private var exerciseInfo: some View {
        AppCell(
            title: currentSession.exercise.name,
            subtitle: currentSession.exercise.subtitle,
            trailingIcon: Image(systemName: "arrow.triangle.2.circlepath")
        ) {
            // TODO: Replace exercise
        }
    }

    // MARK: - Last Result Section

    private var lastResultSection: some View {
        VStack(spacing: 0) {
            AppCell(
                title: currentSession.lastResult ?? "0 кг x 0",
                subtitle: "Последний результат"
            ) {
                // TODO: Show history
            }

            Divider()
                .padding(.top, 8)
                .padding(.horizontal, 16)
        }
    }

    // MARK: - Sets Section

    private var setsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Подходы")
                .headline17Medium()
                .foregroundStyle(Color.appBlack)
                .padding(.horizontal, 16)
                .padding(.top, 16)

            if currentSession.sets.isEmpty {
                emptySetState
            } else {
                setsList
            }
        }
    }

    private var emptySetState: some View {
        Text("Добавь подход\nпосле его выполнения")
            .body15Regular()
            .multilineTextAlignment(.center)
            .foregroundStyle(Color.appGray)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 80)
    }

    private var setsList: some View {
        VStack(spacing: 4) {
            ForEach(Array(currentSession.sets.enumerated()), id: \.element.id) { index, set in
                setRow(set, number: index + 1)
            }
        }
    }

    private func setRow(_ set: WorkoutSet, number: Int) -> some View {
        AppCell(
            title: "\(number) подход",
            value: set.displayText,
            trailingIcon: Image(systemName: "ellipsis")
        )
    }

    // MARK: - Bottom Button

    private var bottomButton: some View {
        AppButton(title: "Добавить подход") {
            addSet()
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
}

// MARK: - Preview

#Preview {
    WorkoutSessionView(exercises: [
        Exercise(name: "Жим штангой", subtitle: "Отрицательный наклон", muscleGroup: .chest),
        Exercise(name: "Жим гантелей", subtitle: "На наклонной скамье", muscleGroup: .chest),
        Exercise(name: "Разводка гантелей", subtitle: "На горизонтальной скамье", muscleGroup: .chest),
        Exercise(name: "Кроссовер", subtitle: "Верхний блок", muscleGroup: .chest),
        Exercise(name: "Отжимания", subtitle: "На брусьях", muscleGroup: .chest),
        Exercise(name: "Кроссовер", subtitle: "Верхний блок", muscleGroup: .chest),
        Exercise(name: "Брусья", subtitle: "На наклонной скамье", muscleGroup: .chest),
    ])
}
