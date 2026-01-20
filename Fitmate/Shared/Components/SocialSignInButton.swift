import SwiftUI

enum SocialSignInType {
    case apple
    case google

    var title: String {
        switch self {
        case .apple: return "Войти через Apple"
        case .google: return "Войти через Google"
        }
    }

    var backgroundColor: Color {
        switch self {
        case .apple: return .black
        case .google: return .white
        }
    }

    var foregroundColor: Color {
        switch self {
        case .apple: return .white
        case .google: return .black
        }
    }
}

struct SocialSignInButton: View {
    let type: SocialSignInType
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                icon
                Text(type.title)
                    .font(.system(size: 16, weight: .medium))
            }
            .foregroundColor(type.foregroundColor)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(type.backgroundColor)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.black.opacity(type == .google ? 0.1 : 0), lineWidth: 1)
            )
        }
    }

    @ViewBuilder
    private var icon: some View {
        switch type {
        case .apple:
            Image(systemName: "apple.logo")
                .font(.system(size: 20))
        case .google:
            GoogleIcon()
        }
    }
}

struct GoogleIcon: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: 20, height: 20)

            // Simplified Google "G" icon
            Text("G")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.red, .yellow, .green, .blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        SocialSignInButton(type: .apple) {}
        SocialSignInButton(type: .google) {}
    }
    .padding()
}
