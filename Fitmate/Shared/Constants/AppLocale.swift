//
//  AppLocale.swift
//  Fitmate
//
//  Created by Akan Akysh on 05/08/26.
//

import Foundation

enum AppLocale {
    static var isRussian: Bool {
        Bundle.main.preferredLocalizations.first?.hasPrefix("ru") ?? true
    }

    static var languageCode: String {
        isRussian ? "ru" : "en"
    }
}
