//
//  LanguageManager.swift
//  Fitmate
//
//  Created by Akan Akysh on 05/02/26.
//

import SwiftUI
import Combine

enum AppLanguage: String, CaseIterable {
    case russian = "ru"
    case english = "en"
    
    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .russian: return "Русский"
        case .english: return "English"
        }
    }
}

@MainActor
final class LanguageManager: ObservableObject {

    @AppStorage(StorageKeys.appLanguage) private var storedLanguage: String = "ru"

    @Published var currentLanguage: AppLanguage = .russian

    var bundle: Bundle {
        let languageCode = currentLanguage.rawValue
        guard let path = Bundle.main.path(forResource: languageCode, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return .main
        }
        return bundle
    }

    init() {
        currentLanguage = AppLanguage(rawValue: storedLanguage) ?? .russian
    }

    func setLanguage(_ language: AppLanguage) {
        currentLanguage = language
        storedLanguage = language.rawValue

        UserDefaults.standard.set([language.rawValue], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }

    func localizedString(_ key: String) -> String {
        return bundle.localizedString(forKey: key, value: nil, table: nil)
    }
}
