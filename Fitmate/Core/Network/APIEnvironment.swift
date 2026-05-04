//
//  APIEnvironment.swift
//  Fitmate
//
//  Created by Akan Akysh on 27/04/26.
//

import Foundation

enum APIEnvironment {
    case development
    case production

    var baseURL: URL {
        switch self {
        case .development:
            URL(string: "https://fitmate-develop.share-prompt.org")!
        case .production:
            URL(string: "https://fitmate-develop.share-prompt.org")!
        }
    }

    static let current: APIEnvironment = {
        #if DEBUG
        .development
        #else
        .production
        #endif
    }()
}
