//
//  ProfileView.swift
//  Fitmate
//
//  Created by Akan Akysh on 04/02/26.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var authManager: AuthManager
    @EnvironmentObject private var languageManager: LanguageManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Navigation Bar
            navigationBar

            // Content
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 24) {
                        subscriptionSection
                        languageSelector
                        Spacer()
                        actionButtons
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .frame(minHeight: geometry.size.height)
                }
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - Navigation Bar

    private var navigationBar: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 16) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(Color.primary)
                }

                Text("Профиль")
                    .headline24Semibold()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            Divider()
        }
    }

    // MARK: - Subscription Section

    private var subscriptionSection: some View {
        SubscriptionCardView(
            planName: "3 месяца",
            nextBillingDate: "24.12.2026"
        )
    }

    // MARK: - Language Selector

    private var languageSelector: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Язык интерфейса")
                .body17Semibold()

            AppChipGroup(
                items: AppLanguage.allCases,
                selected: Binding(
                    get: { languageManager.currentLanguage },
                    set: { languageManager.setLanguage($0) }
                ),
                titleFor: { $0.displayName }
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 8) {
            AppButton(title: "Выйти из аккаунта", type: .secondary) {
                authManager.signOut()
            }

            AppButton(title: "Удалить аккаунт", type: .destructive) {
                // TODO: Delete account
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView()
            .environmentObject(AuthManager())
            .environmentObject(LanguageManager())
    }
}
