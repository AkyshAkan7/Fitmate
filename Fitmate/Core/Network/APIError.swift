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
            "Неверный URL запроса"
        case .unauthorized:
            "Требуется авторизация"
        case .network(let error):
            "Ошибка сети: \(error.localizedDescription)"
        case .decoding:
            "Не удалось разобрать ответ сервера"
        case .server(let code, let message):
            message ?? "Ошибка сервера (\(code))"
        case .unknown(let error):
            error.localizedDescription
        }
    }
}
