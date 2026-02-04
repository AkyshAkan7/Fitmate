//
//  AuthManager.swift
//  Fitmate
//
//  Created by Akan Akysh on 04/02/26.
//

import SwiftUI
import Combine

@MainActor
final class AuthManager: ObservableObject {
    @Published var isAuthenticated = false

    func signIn() {
        // TODO: Implement actual sign in logic
        isAuthenticated = true
    }

    func signOut() {
        isAuthenticated = false
    }
}
