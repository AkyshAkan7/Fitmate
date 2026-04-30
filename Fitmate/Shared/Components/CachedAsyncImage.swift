//
//  CachedAsyncImage.swift
//  Fitmate
//
//  Created by Akan Akysh on 29/04/26.
//

import SwiftUI

/// Лёгкая обёртка над `AsyncImage` с in-memory кэшем (`NSCache`).
/// Картинка по конкретному URL грузится из сети только один раз за сессию приложения.
struct CachedAsyncImage<Placeholder: View, Content: View>: View {
    private let url: URL?
    private let content: (Image) -> Content
    private let placeholder: () -> Placeholder

    @State private var loadedImage: UIImage?

    init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
    }

    var body: some View {
        Group {
            if let loadedImage {
                content(Image(uiImage: loadedImage))
            } else {
                placeholder()
            }
        }
        .task(id: url) { await load() }
    }

    private func load() async {
        guard let url else {
            loadedImage = nil
            return
        }

        if let cached = ImageCache.shared.image(for: url) {
            loadedImage = cached
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else { return }
            ImageCache.shared.store(image, for: url)
            // Проверяем что URL не сменился пока грузили
            if url == self.url {
                loadedImage = image
            }
        } catch {
            // Тихо проваливаемся в placeholder — лог уйдёт через Pulse
        }
    }
}

// MARK: - Cache

private final class ImageCache {
    static let shared = ImageCache()

    private let cache = NSCache<NSURL, UIImage>()

    private init() {
        cache.countLimit = 200
        cache.totalCostLimit = 64 * 1024 * 1024 // 64 MB
    }

    func image(for url: URL) -> UIImage? {
        cache.object(forKey: url as NSURL)
    }

    func store(_ image: UIImage, for url: URL) {
        let cost = Int(image.size.width * image.size.height * 4)
        cache.setObject(image, forKey: url as NSURL, cost: cost)
    }
}
