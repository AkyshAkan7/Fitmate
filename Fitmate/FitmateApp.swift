//
//  FitmateApp.swift
//  Fitmate
//
//  Created by Akan Akysh on 13/01/26.
//

import SwiftUI
import SwiftData

@main
struct FitmateApp: App {
    @StateObject private var authManager = AuthManager()
    @StateObject private var languageManager = LanguageManager()
    @StateObject private var router = Router()

    private let modelContainer = AppSchema.makeContainer()

    var body: some Scene {
        WindowGroup {
            MainAppView()
                .environmentObject(authManager)
                .environmentObject(languageManager)
                .environmentObject(router)
                .modelContainer(modelContainer)
                .preferredColorScheme(.light)
        }
    }
}
