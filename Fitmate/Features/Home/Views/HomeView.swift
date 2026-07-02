//
//  HomeView.swift
//  Fitmate
//
//  Created by Akan Akysh on 04/02/26.
//

import SwiftUI
import SwiftData

private enum PendingStartAction {
    case quickStart
    case template(exercises: [Exercise])
}

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var authManager: AuthManager
    @EnvironmentObject private var router: Router
    @EnvironmentObject private var templateStore: TemplateStore
    @AppStorage(StorageKeys.isAIBannerHidden) private var isAIBannerHidden = false

    @Query private var workouts: [WorkoutLocal]

    @State private var pendingAction: PendingStartAction?
    @State private var showActiveWorkoutAlert: Bool = false

    private var activeWorkout: WorkoutLocal? {
        workouts.first { $0.endedAt == nil }
    }

    private var completedWorkoutsCount: Int {
        workouts.filter { $0.endedAt != nil }.count
    }

    private var distinctExercisesCount: Int {
        let keys = workouts
            .flatMap { $0.exercises }
            .map { ex -> String in
                ex.exerciseId.isEmpty ? "name:\(ex.exerciseName)" : "id:\(ex.exerciseId)"
            }
        return Set(keys).count
    }

    private var weekStatuses: [DayStatus] {
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        let mondayOffset = (weekday + 5) % 7
        guard let monday = calendar.date(byAdding: .day, value: -mondayOffset, to: today) else {
            return []
        }
        let mondayStart = calendar.startOfDay(for: monday)

        return (0..<7).map { offset in
            guard
                let dayStart = calendar.date(byAdding: .day, value: offset, to: mondayStart),
                let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)
            else {
                return .none
            }

            let hasWorkout = workouts.contains { workout in
                guard let endedAt = workout.endedAt else { return false }
                return endedAt >= dayStart && endedAt < dayEnd
            }

            if hasWorkout { return .green }
            if calendar.isDateInToday(dayStart) { return .yellow }
            return .none
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 0) {
                // Navigation Bar
                HStack {
                    Image("logoText")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 20)
                    
                    Spacer()
                    
                    Button {
                        router.navigate(to: .profile)
                    } label: {
                        HStack(spacing: 4) {
                            Text("Профиль")
                                .body17Regular()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .bold))
                        }
                        .foregroundColor(.appGray)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                
                Divider()
            }
            
            ScrollView {
                VStack(spacing: 0) {
                    WeekDayView(dayStatuses: weekStatuses)
                        .padding(.top, 16)
                    
                    VStack(spacing: 0) {
                        StatsCardView(
                            title: "Прогресс силовых",
                            subtitle: "Упражнений: \(distinctExercisesCount)"
                        ) {
                            router.navigate(to: .strengthProgress)
                        }

                        Divider()
                            .padding(.leading, 16)

                        StatsCardView(
                            title: "История тренировок",
                            subtitle: "Завершено тренировок: \(completedWorkoutsCount)"
                        ) {
                            router.navigate(to: .workoutHistory)
                        }
                    }
                    .cornerRadius(16)
                    .padding(.top, 20)
                    
                    if !isAIBannerHidden {
                        HomeBannerView {
                            withAnimation {
                                isAIBannerHidden = true
                            }
                        }
                        .padding(.top, 16)
                    }
                    
                    WorkoutTemplatesSection(
                        templates: templateStore.templates,
                        onCreateTap: {
                            router.navigate(to: .createTemplate)
                        },
                        onTemplateTap: { template in
                            startWorkout(.template(exercises: template.exercises))
                        }
                    )
                    .padding(.top, 24)

                    AppButton(title: "Быстрый старт", type: .secondary) {
                        startWorkout(.quickStart)
                    }
                    .padding(.top, 24)

                    if activeWorkout != nil {
                        activeWorkoutBanner
                            .padding(.top, 16)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .background(Color.clear)
        .toolbar(.hidden, for: .navigationBar)
        .task {
            autoFinishStaleWorkouts()
        }
        .alert("Уже есть активная тренировка", isPresented: $showActiveWorkoutAlert) {
            Button("Нет", role: .cancel) {
                pendingAction = nil
            }
            Button("Да") {
                deleteActiveAndProceed()
            }
            .keyboardShortcut(.defaultAction)
        } message: {
            Text("Хотите завершить текущую и создать новую? Все невыполненные упражнения не сохранятся")
        }
    }

    // MARK: - Active Workout Banner

    @ViewBuilder
    private var activeWorkoutBanner: some View {
        if let workout = activeWorkout {
            VStack(spacing: 12) {
                Text("Активная тренировка")
                    .body15Semibold()
                    .foregroundStyle(Color.appBlack)

                AppButton(title: "Открыть") {
                    router.navigate(to: .workoutSessionResume(workoutId: workout.id))
                }
            }
            .padding(16)
            .background(Color.yellow)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }

    // MARK: - Actions

    private func startWorkout(_ action: PendingStartAction) {
        if activeWorkout == nil {
            performStart(action)
        } else {
            pendingAction = action
            showActiveWorkoutAlert = true
        }
    }

    private func performStart(_ action: PendingStartAction) {
        switch action {
        case .quickStart:
            router.navigate(to: .exerciseSelection(mode: .workout, preselected: []))
        case .template(let exercises):
            // Кладём выбор упражнений под экран подтверждения — «Изменить» вернёт к нему
            router.navigate(to: .exerciseSelection(mode: .workout, preselected: exercises))
            router.navigate(to: .workoutConfirm(exercises: exercises))
        }
    }

    private func deleteActiveAndProceed() {
        if let workout = activeWorkout {
            modelContext.delete(workout)
            try? modelContext.save()
        }
        if let action = pendingAction {
            performStart(action)
        }
        pendingAction = nil
    }

    /// Тренировка длиннее 3 часов — автоматом завершаем (`endedAt = startedAt + 3h`).
    /// Если за это время не было ни одного подхода — удаляем целиком.
    private func autoFinishStaleWorkouts() {
        let threeHours: TimeInterval = 3 * 60 * 60
        let threshold = Date().addingTimeInterval(-threeHours)
        var didChange = false

        for workout in workouts where workout.endedAt == nil && workout.startedAt < threshold {
            let hasAnySets = workout.exercises.contains { !$0.sets.isEmpty }
            if hasAnySets {
                for ex in workout.exercises where ex.sets.isEmpty {
                    modelContext.delete(ex)
                }
                workout.endedAt = workout.startedAt.addingTimeInterval(threeHours)
            } else {
                modelContext.delete(workout)
            }
            didChange = true
        }

        if didChange {
            try? modelContext.save()
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthManager())
        .environmentObject(Router())
        .environmentObject(TemplateStore())
}
