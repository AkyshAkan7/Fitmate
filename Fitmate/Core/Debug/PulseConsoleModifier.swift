//
//  PulseConsoleModifier.swift
//  Fitmate
//
//  Created by Akan Akysh on 29/04/26.
//

#if DEBUG
import SwiftUI
import PulseUI

extension View {
    /// Открывает PulseUI ConsoleView по shake-жесту. Только в DEBUG.
    func pulseConsoleOnShake() -> some View {
        modifier(PulseConsoleOnShake())
    }
}

private struct PulseConsoleOnShake: ViewModifier {
    @State private var isPresented = false

    func body(content: Content) -> some View {
        content
            .onShake { isPresented = true }
            .sheet(isPresented: $isPresented) {
                NavigationStack {
                    ConsoleView()
                }
            }
    }
}

// MARK: - Shake Detection

private extension View {
    func onShake(perform action: @escaping () -> Void) -> some View {
        modifier(ShakeDetector(action: action))
    }
}

private struct ShakeDetector: ViewModifier {
    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .background(ShakeReceiver(action: action))
    }
}

private struct ShakeReceiver: UIViewControllerRepresentable {
    let action: () -> Void

    func makeUIViewController(context: Context) -> UIViewController {
        ShakeViewController(action: action)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

private final class ShakeViewController: UIViewController {
    let action: () -> Void

    init(action: @escaping () -> Void) {
        self.action = action
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override var canBecomeFirstResponder: Bool { true }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        becomeFirstResponder()
    }

    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            action()
        }
    }
}
#endif
