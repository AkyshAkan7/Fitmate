//
//  ConsoleNetworkLogger.swift
//  Fitmate
//
//  Created by Akan Akysh on 05/08/26.
//

import Foundation

final class ConsoleNetworkLogger {

    private static let queue = DispatchQueue(label: "com.fitmate.network-logger", qos: .utility)

    private enum Symbol {
        static let request = "🚀"
        static let response = "📥"
        static let error = "❌"
        static let success = "✅"
        static let warning = "⚠️"
        static let url = "🌐"
        static let method = "📡"
        static let headers = "📋"
        static let body = "📦"
        static let divider = "━"
    }

    static func log(request: URLRequest) {
        var output = ""

        output += "\n┌\(String(repeating: Symbol.divider, count: 45))┐\n"
        output += "│            \(Symbol.request) NETWORK REQUEST \(Symbol.request)            │\n"
        output += "├\(String(repeating: Symbol.divider, count: 45))┤\n"

        output += "│ \(Symbol.url) URL: \(request.url?.absoluteString ?? "")\n"
        output += "│ \(Symbol.method) Method: \(request.httpMethod ?? "")\n"

        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            output += "│ \(Symbol.headers) Headers:\n"
            for (key, value) in headers {
                output += "│   \(key): \(value)\n"
            }
        }

        if let body = request.httpBody,
           let jsonString = String(data: body, encoding: .utf8),
           let prettyPrintedBody = prettyPrintJSON(jsonString) {
            output += "│ \(Symbol.body) Body:\n"
            prettyPrintedBody.components(separatedBy: .newlines).forEach { line in
                output += "│   \(line)\n"
            }
        }

        output += "└\(String(repeating: Symbol.divider, count: 45))┘\n"

        queue.async {
            print(output)
        }
    }

    static func log(response: HTTPURLResponse?, data: Data?, error: Error?) {
        var output = ""

        output += "\n┌\(String(repeating: Symbol.divider, count: 45))┐\n"
        output += "│           \(Symbol.response) NETWORK RESPONSE \(Symbol.response)           │\n"
        output += "├\(String(repeating: Symbol.divider, count: 45))┤\n"

        let statusCode = response?.statusCode ?? 0
        output += "│ \(Symbol.url) URL: \(response?.url?.absoluteString ?? "nil")\n"

        let statusEmoji = (200...299).contains(statusCode) ? Symbol.success : Symbol.warning
        output += "│ \(statusEmoji) Status: \(statusCode)\n"

        if let responseData = data,
           let jsonString = String(data: responseData, encoding: .utf8),
           let prettyPrintedJSON = prettyPrintJSON(jsonString) {
            output += "│ \(Symbol.body) Response:\n"
            prettyPrintedJSON.components(separatedBy: .newlines).forEach { line in
                output += "│   \(line)\n"
            }
        }

        if let error {
            output += "│ \(Symbol.error) Error: \(error.localizedDescription)\n"
        }

        output += "└\(String(repeating: Symbol.divider, count: 45))┘\n"

        queue.async {
            print(output)
        }
    }

    private static func prettyPrintJSON(_ jsonString: String) -> String? {
        guard let data = jsonString.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data),
              let prettyData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
              let prettyString = String(data: prettyData, encoding: .utf8) else {
            return nil
        }
        return prettyString
    }
}
