//
//  APIClient.swift
//  Fitmate
//
//  Created by Akan Akysh on 27/04/26.
//

import Foundation

protocol APIClient: Sendable {
    func send<T: Decodable>(_ endpoint: Endpoint) async throws -> T
    func send(_ endpoint: Endpoint) async throws
}

final class DefaultAPIClient: APIClient {
    private let environment: APIEnvironment
    private let session: URLSession
    private let tokenStorage: TokenStorage
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init(
        environment: APIEnvironment = .current,
        session: URLSession = .shared,
        tokenStorage: TokenStorage
    ) {
        self.environment = environment
        self.session = session
        self.tokenStorage = tokenStorage

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
        self.encoder = encoder
    }

    func send<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        let data = try await performRequest(endpoint)
        do {
            return try decoder.decode(T.self, from: data)
        } catch let error as DecodingError {
            throw APIError.decoding(error)
        }
    }

    func send(_ endpoint: Endpoint) async throws {
        _ = try await performRequest(endpoint)
    }

    private func performRequest(_ endpoint: Endpoint) async throws -> Data {
        let request = try buildRequest(for: endpoint)

        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse else {
                throw APIError.unknown(URLError(.badServerResponse))
            }

            switch http.statusCode {
            case 200..<300:
                return data
            case 401:
                tokenStorage.clear()
                throw APIError.unauthorized
            default:
                let message = try? decoder.decode(ServerErrorDTO.self, from: data).message
                throw APIError.server(statusCode: http.statusCode, message: message)
            }
        } catch let error as APIError {
            throw error
        } catch let error as URLError {
            throw APIError.network(error)
        } catch {
            throw APIError.unknown(error)
        }
    }

    private func buildRequest(for endpoint: Endpoint) throws -> URLRequest {
        let url = environment.baseURL.appending(path: endpoint.path)

        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = endpoint.query

        guard let finalURL = components?.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: finalURL)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        endpoint.headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        let token = tokenStorage.read()
        if endpoint.requiresAuth {
            guard let token else {
                throw APIError.unauthorized
            }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else if let token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body = endpoint.body {
            request.httpBody = try encoder.encode(body)
        }

        return request
    }
}

private struct ServerErrorDTO: Decodable {
    let message: String?
}
