//
//  Endpoint.swift
//  Fitmate
//
//  Created by Akan Akysh on 27/04/26.
//

import Foundation

protocol Endpoint {
    var path: String { get }
    var method: HTTPMethod { get }
    var query: [URLQueryItem]? { get }
    var body: (any Encodable)? { get }
    var headers: [String: String]? { get }
    var requiresAuth: Bool { get }
}

extension Endpoint {
    var query: [URLQueryItem]? { nil }
    var body: (any Encodable)? { nil }
    var headers: [String: String]? { nil }
    var requiresAuth: Bool { false }
}
