//
//  ContentView.swift
//  Fitmate
//
//  Created by Akan Akysh on 13/01/26.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var authManager: AuthManager
    @EnvironmentObject private var languageManager: LanguageManager
    
    var body: some View {
        ZStack {
            if authManager.isAuthenticated {
                HomeView().transition(.push(from: .bottom))
            } else {
                AuthView().transition(.push(from: .top))
            }
        }
        .animation(.default, value: authManager.isAuthenticated)
        .environment(\.locale, Locale(identifier: languageManager.currentLanguage.id))
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthManager())
}
