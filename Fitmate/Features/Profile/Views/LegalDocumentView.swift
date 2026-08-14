//
//  LegalDocumentView.swift
//  Fitmate
//
//  Created by Akan Akysh on 14/08/26.
//

import SwiftUI
import WebKit

enum LegalDocument {
    case privacyPolicy
    case termsOfUse

    var url: URL {
        switch self {
        case .privacyPolicy: APIEnvironment.current.baseURL.appending(path: "privacy")
        case .termsOfUse: APIEnvironment.current.baseURL.appending(path: "terms")
        }
    }
}

struct LegalDocumentView: View {
    let document: LegalDocument

    @Environment(\.dismiss) private var dismiss
    @State private var isLoading = true
    @State private var didFail = false
    @State private var reloadTrigger = 0

    var body: some View {
        VStack(spacing: 0) {
            navigationBar

            ZStack {
                WebView(
                    url: document.url,
                    reloadTrigger: reloadTrigger,
                    isLoading: $isLoading,
                    didFail: $didFail
                )
                .opacity(didFail ? 0 : 1)
                .ignoresSafeArea(edges: .bottom)

                if isLoading && !didFail {
                    ProgressView()
                }

                if didFail {
                    failureState
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var navigationBar: some View {
        VStack(spacing: 0) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(Color.primary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            Divider()
        }
    }

    private var failureState: some View {
        VStack(spacing: 12) {
            Text("Не удалось загрузить документ")
                .body15Regular()
                .foregroundStyle(Color.appGray)
                .multilineTextAlignment(.center)

            Button("Повторить") {
                didFail = false
                isLoading = true
                reloadTrigger += 1
            }
            .body15Semibold()
            .foregroundStyle(.blue)
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - Web View

private struct WebView: UIViewRepresentable {
    let url: URL
    let reloadTrigger: Int
    @Binding var isLoading: Bool
    @Binding var didFail: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.userContentController.addUserScript(
            WKUserScript(
                source: Self.compactLayoutCSS,
                injectionTime: .atDocumentEnd,
                forMainFrameOnly: true
            )
        )

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.pageZoom = 0.8
        webView.isOpaque = false
        webView.backgroundColor = .white
        webView.scrollView.backgroundColor = .white
        webView.load(URLRequest(url: url))
        return webView
    }

    private static let compactLayoutCSS = """
    var style = document.createElement('style');
    style.textContent = 'main { padding-bottom: 16px !important; } .updated { margin-top: 32px !important; }';
    document.head.appendChild(style);
    """

    func updateUIView(_ webView: WKWebView, context: Context) {
        guard context.coordinator.lastReloadTrigger != reloadTrigger else { return }
        context.coordinator.lastReloadTrigger = reloadTrigger
        webView.load(URLRequest(url: url))
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        private let parent: WebView
        var lastReloadTrigger = 0

        init(_ parent: WebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
            parent.didFail = true
        }

        func webView(
            _ webView: WKWebView,
            didFailProvisionalNavigation navigation: WKNavigation!,
            withError error: Error
        ) {
            parent.isLoading = false
            parent.didFail = true
        }
    }
}

#Preview {
    LegalDocumentView(document: .privacyPolicy)
}
