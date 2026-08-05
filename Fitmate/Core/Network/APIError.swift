//
//  APIError.swift
//  Fitmate
//
//  Created by Akan Akysh on 27/04/26.
//

import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case unauthorized
    case network(URLError)
    case decoding(DecodingError)
    case server(statusCode: Int, message: String?)
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            String(localized: "Неверный URL запроса")
        case .unauthorized:
            String(localized: "Требуется авторизация")
        case .network(let error):
            String(localized: "Ошибка сети: \(error.localizedDescription)")
        case .decoding:
            String(localized: "Не удалось разобрать ответ сервера")
        case .server(let code, let message):
            message ?? String(localized: "Ошибка сервера (\(code))")
        case .unknown(let error):
            error.localizedDescription
        }
    }
}
