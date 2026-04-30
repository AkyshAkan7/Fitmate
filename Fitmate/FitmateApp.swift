//
//  FitmateApp.swift
//  Fitmate
//
//  Created by Akan Akysh on 13/01/26.
//

import SwiftUI
import Pulse
import PulseProxy

@main
struct FitmateApp: App {
    @StateObject private var authManager = AuthManager()
    @StateObject private var languageManager = LanguageManager()
    @StateObject private var router = Router()
    @StateObject private var templateStore = TemplateStore()
    @StateObject private var customExerciseStore = CustomExerciseStore()

    init() {
        #if DEBUG
        // Свизлит URLSession и пишет все запросы (включая URLSession.shared в APIClient)
        NetworkLogger.enableProxy()
        RemoteLogger.shared.isAutomaticConnectionEnabled = true
        #endif
    }

    var body: some Scene {
        WindowGroup {
            MainAppView()
                .environmentObject(authManager)
                .environmentObject(languageManager)
                .environmentObject(router)
                .environmentObject(templateStore)
                .environmentObject(customExerciseStore)
                .preferredColorScheme(.light)
            #if DEBUG
                .pulseConsoleOnShake()
            #endif
        }
    }
}
