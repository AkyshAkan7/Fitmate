//
//  FitmateApp.swift
//  Fitmate
//
//  Created by Akan Akysh on 13/01/26.
//

import SwiftUI
import SwiftData
import Pulse
import PulseProxy

@main
struct FitmateApp: App {
    @StateObject private var authManager = AuthManager()
    @StateObject private var languageManager = LanguageManager()
    @StateObject private var router = Router()

    private let modelContainer = AppSchema.makeContainer()

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
                .modelContainer(modelContainer)
                .preferredColorScheme(.light)
            #if DEBUG
                .pulseConsoleOnShake()
            #endif
        }
    }
}
