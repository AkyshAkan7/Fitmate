//
//  WorkoutSessionView.swift
//  Fitmate
//
//  Created by Akan Akysh on 25/02/26.
//

import SwiftUI
import SwiftData

// MARK: - WorkoutSessionView

struct WorkoutSessionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var router: Router

    @State private var exerciseSessions: [ExerciseSession]
    @State private var startedAt: Date
    @State private var activeWorkoutId: UUID?
    @State private var resumeWorkoutId: UUID?
    @State private var selectedIndex: Int = 0
    @State private var showFinishAlert: Bool = false
    @State private var showAddSetSheet: Bool = false
    // Edit/delete set alert
    @State private var showSetActionSheet: Bool = false
    @State private var showDeleteAlert: Bool = false
    @State private var selectedSetIndex: Int?

    init(exercises: [Exercise]) {
        let sessions = exercises.map { exercise in
            ExerciseSession(
                exercise: exercise,
                sets: [],
                lastResult: "0 кг x 0"
            )
        }
        _exerciseSessions = State(initialValue: sessions)
        _startedAt = State(initialValue: .now)
        _activeWorkoutId = State(initialValue: nil)
        _resumeWorkoutId = State(initialValue: nil)
    }

    init(workoutId: UUID) {
        _exerciseSessions = State(initialValue: [])
        _startedAt = State(initialValue: .now)
        _activeWorkoutId = State(initialValue: nil)
        _resumeWorkoutId = State(initialValue: workoutId)
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
        showAddSetSheet = true
    }

    private func addSet(weight: Double, reps: Int) {
        let newSet = WorkoutSet(weight: weight, reps: reps)
        exerciseSessions[selectedIndex].sets.append(newSet)
        persistCurrentState()
    }

    private func updateSet(at index: Int, weight: Double, reps: Int) {
        exerciseSessions[selectedIndex].sets[index].weight = weight
        exerciseSessions[selectedIndex].sets[index].reps = reps
        persistCurrentState()
    }

    private func deleteSet(at index: Int) {
        exerciseSessions[selectedIndex].sets.remove(at: index)
        persistCurrentState()
    }

    private func showSetActions(for index: Int) {
        selectedSetIndex = index
        showSetActionSheet = true
    }

    private func finishWorkout() {
        showFinishAlert = true
    }

    // MARK: - Persistence

    private func loadFromDB(id: UUID) {
        let repository = AppDependencies.workoutHistoryRepository(context: modelContext)
        guard let workout = try? repository.find(id: id) else { return }

        startedAt = workout.startedAt
        activeWorkoutId = workout.id
        exerciseSessions = workout.exercises
            .sorted { $0.sortOrder < $1.sortOrder }
            .map { ex in
                let exercise = Exercise(
                    catalogId: ex.exerciseId.isEmpty ? nil : ex.exerciseId,
                    name: ex.exerciseName,
                    subtitle: ex.exerciseSubtitle,
                    muscleGroup: .custom,
                    imageURL: ex.exerciseImageLink.flatMap { URL(string: $0) }
                )
                let sets = ex.sets
                    .sorted { $0.createdAt < $1.createdAt }
                    .map { WorkoutSet(weight: $0.weight, reps: $0.reps) }
                return ExerciseSession(
                    exercise: exercise,
                    sets: sets,
                    lastResult: "0 кг x 0"
                )
            }
    }

    /// Создаёт активную WorkoutLocal сразу при заходе в новую сессию.
    private func createActiveWorkoutIfNeeded() {
        guard activeWorkoutId == nil else { return }
        let workout = WorkoutLocal(startedAt: startedAt, endedAt: nil, synced: false)
        modelContext.insert(workout)
        activeWorkoutId = workout.id

        for (index, session) in exerciseSessions.enumerated() {
            let workoutExercise = WorkoutExerciseLocal(
                exerciseId: session.exercise.catalogId ?? "",
                sortOrder: index,
                exerciseName: session.exercise.name,
                exerciseSubtitle: session.exercise.subtitle,
                exerciseImageLink: session.exercise.imageURL?.absoluteString
            )
            workoutExercise.workout = workout
        }

        try? modelContext.save()
    }

    /// Зеркалит текущее состояние @State в БД (на каждую мутацию подходов/упражнений).
    private func persistCurrentState() {
        let repository = AppDependencies.workoutHistoryRepository(context: modelContext)

        let workout: WorkoutLocal
        if let id = activeWorkoutId, let existing = try? repository.find(id: id) {
            workout = existing
            for ex in workout.exercises {
                modelContext.delete(ex)
            }
        } else {
            workout = WorkoutLocal(startedAt: startedAt, endedAt: nil, synced: false)
            modelContext.insert(workout)
            activeWorkoutId = workout.id
        }

        for (index, session) in exerciseSessions.enumerated() {
            let workoutExercise = WorkoutExerciseLocal(
                exerciseId: session.exercise.catalogId ?? "",
                sortOrder: index,
                exerciseName: session.exercise.name,
                exerciseSubtitle: session.exercise.subtitle,
                exerciseImageLink: session.exercise.imageURL?.absoluteString
            )
            workoutExercise.workout = workout

            for set in session.sets {
                let setLocal = WorkoutSetLocal(weight: set.weight, reps: set.reps)
                setLocal.exercise = workoutExercise
            }
        }

        do {
            try modelContext.save()
        } catch {
            print("Persist failed: \(error)")
        }
    }

    private func finishAndSave() {
        persistCurrentState()
        guard let id = activeWorkoutId else { return }
        let repository = AppDependencies.workoutHistoryRepository(context: modelContext)
        guard let workout = try? repository.find(id: id) else { return }

        // Чистим упражнения без подходов — не попадут в историю
        for ex in workout.exercises where ex.sets.isEmpty {
            modelContext.delete(ex)
        }

        workout.endedAt = .now
        try? modelContext.save()
    }

    private func finishAndDelete() {
        guard let id = activeWorkoutId else { return }
        let repository = AppDependencies.workoutHistoryRepository(context: modelContext)
        try? repository.delete(id: id)
        activeWorkoutId = nil
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            navigationBar

            if exerciseSessions.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
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
        }
        .toolbar(.hidden, for: .navigationBar)
        .task {
            if let id = resumeWorkoutId, activeWorkoutId == nil {
                loadFromDB(id: id)
            } else if resumeWorkoutId == nil {
                createActiveWorkoutIfNeeded()
            }
        }
        .alert("Завершение", isPresented: $showFinishAlert) {
            Button("Сохранить", role: .cancel) {
                finishAndSave()
                router.navigate(to: .workoutComplete)
            }
            .keyboardShortcut(.defaultAction)
            Button("Удалить", role: .destructive) {
                finishAndDelete()
                router.popToRoot()
            }
        } message: {
            Text("Все невыполненные упражнения не сохранятся. Сохранить тренировку?")
        }
        .sheet(isPresented: $showAddSetSheet) {
            if let index = selectedSetIndex {
                let set = currentSession.sets[index]
                AddSetView(
                    setNumber: index + 1,
                    initialWeight: set.weight,
                    initialReps: set.reps,
                    isEditing: true
                ) { weight, reps in
                    updateSet(at: index, weight: weight, reps: reps)
                    selectedSetIndex = nil
                }
                .presentationDetents([.height(420)])
                .presentationDragIndicator(.visible)
            } else {
                AddSetView(setNumber: currentSession.sets.count + 1) { weight, reps in
                    addSet(weight: weight, reps: reps)
                }
                .presentationDetents([.height(420)])
                .presentationDragIndicator(.visible)
            }
        }
        .confirmationDialog("", isPresented: $showSetActionSheet, titleVisibility: .hidden) {
            Button("Редактировать") {
                showAddSetSheet = true
            }
            Button("Удалить", role: .destructive) {
                showDeleteAlert = true
            }
            Button("Отмена", role: .cancel) {}
        }
        .alert("Удаление", isPresented: $showDeleteAlert) {
            Button("Нет", role: .cancel) {}
            Button("Да") {
                if let index = selectedSetIndex {
                    deleteSet(at: index)
                    selectedSetIndex = nil
                }
            }
            .keyboardShortcut(.defaultAction)
        } message: {
            Text("Точно хотите удалить подход?")
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
            CachedAsyncImage(
                url: session.exercise.imageURL,
                content: { image in image.resizable().scaledToFill() },
                placeholder: { Color.lightGray }
            )
            .frame(width: 72, height: 72)
            .background(Color.lightGray)
            .clipShape(RoundedRectangle(cornerRadius: 16))
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
            iconURL: currentSession.exercise.imageURL,
            title: currentSession.exercise.name,
            subtitle: currentSession.exercise.subtitle,
            trailingIcon: Image("reload")
        ) {
            router.onExerciseReplace = { [self] newExercise in
                exerciseSessions[selectedIndex].exercise = newExercise
                persistCurrentState()
            }
            router.navigate(to: .replaceExercise)
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
                setRow(set, index: index)
            }
        }
    }

    private func setRow(_ set: WorkoutSet, index: Int) -> some View {
        AppCell(
            title: "\(index + 1) подход",
            value: set.displayText,
            trailingIcon: Image(systemName: "ellipsis")
        ) {
            showSetActions(for: index)
        }
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

#if DEBUG
#Preview {
    WorkoutSessionView(exercises: [
        Exercise(name: "Жим штангой", subtitle: "Отрицательный наклон", muscleGroup: .previewChest),
        Exercise(name: "Жим гантелей", subtitle: "На наклонной скамье", muscleGroup: .previewChest),
        Exercise(name: "Разводка гантелей", subtitle: "На горизонтальной скамье", muscleGroup: .previewChest),
        Exercise(name: "Кроссовер", subtitle: "Верхний блок", muscleGroup: .previewChest),
        Exercise(name: "Отжимания", subtitle: "На брусьях", muscleGroup: .previewChest),
        Exercise(name: "Кроссовер", subtitle: "Верхний блок", muscleGroup: .previewChest),
        Exercise(name: "Брусья", subtitle: "На наклонной скамье", muscleGroup: .previewChest),
    ])
}
#endif
