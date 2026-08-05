//
//  CachedAsyncImage.swift
//  Fitmate
//
//  Created by Akan Akysh on 29/04/26.
//

import SwiftUI

/// AsyncImage с двухуровневым кэшем: NSCache в памяти + URLCache на диске.
/// Кэшированная картинка показывается мгновенно, при этом раз за сессию
/// уходит ревалидация на сервер — обновлённые картинки подтягиваются сами.
struct CachedAsyncImage<Placeholder: View, Content: View>: View {
    private let url: URL?
    private let content: (Image) -> Content
    private let placeholder: () -> Placeholder

    @State private var loadedImage: UIImage?
    @State private var isLoading = false

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
                    .overlay {
                        if isLoading {
                            ProgressView()
                        }
                    }
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
            await revalidateIfNeeded(url)
            return
        }

        isLoading = true
        await fetch(url, policy: .useProtocolCachePolicy)
        isLoading = false
    }

    /// Раз за сессию проверяет у сервера, не обновилась ли картинка (ETag/Last-Modified).
    private func revalidateIfNeeded(_ url: URL) async {
        guard ImageCache.shared.shouldRevalidate(url) else { return }
        await fetch(url, policy: .reloadRevalidatingCacheData)
    }

    private func fetch(_ url: URL, policy: URLRequest.CachePolicy) async {
        var request = URLRequest(url: url)
        request.cachePolicy = policy

        do {
            let (data, _) = try await ImageCache.session.data(for: request)
            guard let raw = UIImage(data: data) else { return }
            // Декодируем заранее в фоне — без лагов при первом показе в списке
            let image = await raw.byPreparingForDisplay() ?? raw
            ImageCache.shared.store(image, for: url)
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

    /// Отдельная сессия с дисковым кэшем — картинки живут между запусками.
    static let session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = URLCache(
            memoryCapacity: 16 * 1024 * 1024,
            diskCapacity: 128 * 1024 * 1024
        )
        return URLSession(configuration: configuration)
    }()

    private let cache = NSCache<NSURL, UIImage>()
    private var revalidated = Set<URL>()

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

    func shouldRevalidate(_ url: URL) -> Bool {
        guard !revalidated.contains(url) else { return false }
        revalidated.insert(url)
        return true
    }
}
