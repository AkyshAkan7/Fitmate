//
//  ContentView.swift
//  Fitmate
//
//  Created by Akan Akysh on 13/01/26.
//

import SwiftUI

struct MainAppView: View {
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var router: Router
    
    var body: some View {
        NavigationStack(path: $router.path) {
            HomeView()
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .profile:
                        ProfileView()
                    case .exerciseSelection(let mode, let preselected):
                        ExerciseSelectionView(mode: mode, preselected: preselected)
                    case .workoutConfirm(let exercises):
                        WorkoutConfirmView(exercises: exercises)
                    case .workoutSession(let exercises):
                        WorkoutSessionView(exercises: exercises)
                    case .workoutSessionResume(let workoutId):
                        WorkoutSessionView(workoutId: workoutId)
                    case .workoutComplete:
                        WorkoutCompleteView()
                    case .createTemplate:
                        CreateWorkoutTemplateView()
                    case .confirmTemplate(let templateName, let exercises):
                        ConfirmWorkoutTemplateView(templateName: templateName, exercises: exercises)
                    case .createCustomExercise:
                        CreateCustomExerciseView()
                    case .replaceExercise:
                        ExerciseSelectionView(mode: .replace)
                    case .strengthProgress:
                        StrengthProgressView()
                    case .exerciseProgress(let name, let subtitle):
                        ExerciseProgressView(exerciseName: name, exerciseSubtitle: subtitle)
                    case .workoutHistory:
                        WorkoutHistoryView()
                    }
                }
        }
        .environment(\.locale, Locale(identifier: languageManager.currentLanguage.id))
    }
}

#Preview {
    MainAppView()
        .environmentObject(AuthManager())
        .environmentObject(LanguageManager())
        .environmentObject(Router())
        .environmentObject(CustomExerciseStore())
        .environmentObject(TemplateStore())
}
