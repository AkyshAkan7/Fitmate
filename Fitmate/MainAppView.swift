//
//  ContentView.swift
//  Fitmate
//
//  Created by Akan Akysh on 13/01/26.
//

import SwiftUI

struct MainAppView: View {
    @EnvironmentObject private var authManager: AuthManager
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var router: Router
    
    var body: some View {
        ZStack {
            if authManager.isAuthenticated {
                NavigationStack(path: $router.path) {
                    HomeView()
                        .navigationDestination(for: Route.self) { route in
                            switch route {
                            case .profile:
                                ProfileView()
                            case .exerciseSelection(let mode):
                                ExerciseSelectionView(mode: mode)
                            case .workoutConfirm(let exercises):
                                WorkoutConfirmView(exercises: exercises)
                            case .workoutSession(let exercises):
                                WorkoutSessionView(exercises: exercises)
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
                            }
                        }
                }
                .transition(.push(from: .bottom))
            } else {
                AuthView().transition(.push(from: .top))
            }
        }
        .animation(.default, value: authManager.isAuthenticated)
        .environment(\.locale, Locale(identifier: languageManager.currentLanguage.id))
    }
}

#Preview {
    MainAppView()
        .environmentObject(AuthManager())
        .environmentObject(LanguageManager())
        .environmentObject(Router())
        .environmentObject(CustomExerciseStore())
}
