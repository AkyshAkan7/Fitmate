//
//  FitmateApp.swift
//  Fitmate
//
//  Created by Akan Akysh on 13/01/26.
//

import SwiftUI

@main
struct FitmateApp: App {
    @StateObject private var authManager = AuthManager()
    @StateObject private var languageManager = LanguageManager()
    @StateObject private var router = Router()

    var body: some Scene {
        WindowGroup {
            MainAppView()
                .environmentObject(authManager)
                .environmentObject(languageManager)
                .environmentObject(router)
                .preferredColorScheme(.light)
        }
    }
}
