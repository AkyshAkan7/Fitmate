import SwiftUI

struct AuthView: View {
    @EnvironmentObject private var authManager: AuthManager

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            BackgroundIllustration()

            VStack(spacing: 0) {
                Spacer()

                // Logo
                LogoView()

                Spacer()

                // Sign in buttons
                VStack(spacing: 12) {
                    SocialSignInButton(type: .apple) {
                        authManager.signIn()
                    }

                    SocialSignInButton(type: .google) {
                        authManager.signIn()
                    }
                }
                .padding(.horizontal, 16)

                // Terms and privacy
                TermsView()
                    .padding(.top, 24)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
            }
        }
    }
}

// MARK: - Logo View
struct LogoView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image("logoIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)

            Image("logoText")
                .resizable()
                .scaledToFit()
                .frame(height: 24)

            Text("Помогу следить\nза прогрессом силовых")
                .body15Regular()
                .foregroundColor(.appGray)
                .multilineTextAlignment(.center)
        }
    }
}

// MARK: - Background Illustration
struct BackgroundIllustration: View {
    var body: some View {
        GeometryReader { geometry in
            Image("lineIllustration")
                .resizable()
                .scaledToFit()
                .frame(width: geometry.size.width)
                .position(x: geometry.size.width / 2, y: geometry.size.height * 0.28)
        }
    }
}

// MARK: - Terms View
struct TermsView: View {
    var body: some View {
        Text(termsText)
            .body11Regular()
            .multilineTextAlignment(.center)
    }

    private var termsText: AttributedString {
        var text = AttributedString("Продолжая вы принимаете ")
        text.foregroundColor = .appGray

        var privacy = AttributedString("Политика конфиденциальности")
        privacy.foregroundColor = .appGray
        privacy.underlineStyle = .single

        var and = AttributedString("\nи ")
        and.foregroundColor = .appGray

        var terms = AttributedString("Пользовательское соглашение")
        terms.foregroundColor = .appGray
        terms.underlineStyle = .single

        return text + privacy + and + terms
    }
}

#Preview {
    AuthView()
        .environmentObject(AuthManager())
}
