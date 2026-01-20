import SwiftUI

extension Color {
    
    init(hex: Int, opacity: Double = 1.0) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: opacity
        )
    }

    static let appGray = Color(hex: 0x222222, opacity: 0.52)
}
