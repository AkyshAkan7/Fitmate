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
import GoogleSignIn

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

        // serverClientID must stay the Web OAuth client (same one Android uses)
        // so the SDK returns a serverAuthCode our backend can exchange via
        // GET /auth/callback, exactly like the Android flow.
        if let clientID = Bundle.main.object(forInfoDictionaryKey: "GIDClientID") as? String {
            let serverClientID = Bundle.main.object(forInfoDictionaryKey: "GIDServerClientID") as? String
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID, serverClientID: serverClientID)
        }
    }

    var body: some Scene {
        WindowGroup {
            MainAppView()
                .environmentObject(authManager)
                .environmentObject(languageManager)
                .environmentObject(router)
                .modelContainer(modelContainer)
                .preferredColorScheme(.light)
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
            #if DEBUG
                .pulseConsoleOnShake()
            #endif
        }
    }
}
