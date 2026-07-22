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
    @EnvironmentObject private var router: Router
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    var body: some View {
        VStack(spacing: 0) {
            // Navigation Bar
            navigationBar

            // Content
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 24) {
                        if authManager.isAuthenticated {
                            accountCard
                            Spacer()
                            actionButtons
                        } else {
                            signUpCard
                            Spacer()
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .frame(minHeight: geometry.size.height)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
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

    // MARK: - Sign Up Card

    private var signUpCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Image("zap")
                .resizable()
                .scaledToFit()
                .frame(width: 28, height: 28)

            Text("Не потеряйте свой прогресс")
                .body17Semibold()
                .foregroundStyle(Color.appBlack)
                .padding(.top, 24)

            Text("Зарегистрируйтесь, чтобы сохранить прогресс тренировок и не потерять свои результаты.")
                .body13Regular()
                .foregroundStyle(Color.appGray)
                .padding(.top, 8)

            SocialSignInButton(type: .apple) {
                authManager.signIn()
            }
            .padding(.top, 16)

            TermsView(
                alignment: .leading,
                onPrivacyTap: { router.navigate(to: .privacyPolicy) },
                onTermsTap: { router.navigate(to: .termsOfUse) }
            )
            .padding(.top, 12)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color.lightGray)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    // MARK: - Account Card

    private var accountCard: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Аккаунт")
                    .body13Regular()
                    .foregroundStyle(Color.appGray)
                Text("testing")
                    .body15Regular()
                    .foregroundStyle(Color.appBlack)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)

            Divider()
                .padding(.horizontal, 16)

            Button {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    openURL(url)
                }
            } label: {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Язык приложения")
                            .body13Regular()
                            .foregroundStyle(Color.appGray)
                        Text(languageManager.currentLanguage.displayName)
                            .body15Regular()
                            .foregroundStyle(Color.appBlack)
                    }

                    Spacer()

                    Image("chevronRight")
                }
                .padding(16)
            }
        }
        .background(Color.lightGray)
        .clipShape(RoundedRectangle(cornerRadius: 24))
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
