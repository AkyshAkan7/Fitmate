//
//  HomeView.swift
//  Fitmate
//
//  Created by Akan Akysh on 04/02/26.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @EnvironmentObject private var authManager: AuthManager
    @EnvironmentObject private var router: Router
    @EnvironmentObject private var templateStore: TemplateStore
    @AppStorage(StorageKeys.isAIBannerHidden) private var isAIBannerHidden = false

    @Query private var workouts: [WorkoutLocal]

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
                            router.navigate(to: .workoutConfirm(exercises: template.exercises))
                        }
                    )
                    .padding(.top, 24)
                    
                    AppButton(title: "Быстрый старт", type: .secondary) {
                        router.navigate(to: .exerciseSelection(mode: .workout))
                    }
                    .padding(.top, 24)
                }
            }
            .padding(.horizontal, 16)
        }
        .background(Color.clear)
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthManager())
        .environmentObject(Router())
        .environmentObject(TemplateStore())
}
