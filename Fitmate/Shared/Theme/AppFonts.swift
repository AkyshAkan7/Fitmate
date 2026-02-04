//
//  AppFonts.swift
//  Fitmate
//
//  Created by Akan Akysh on 04/02/26.
//

import SwiftUI

extension Font {

    // MARK: - H1

    static let h1Bold = Font.system(size: 48, weight: .bold)

    // MARK: - Headline

    static let headline17Medium = Font.system(size: 17, weight: .medium)
    static let headline20Medium = Font.system(size: 20, weight: .medium)
    static let headline24Medium = Font.system(size: 24, weight: .medium)
    static let headline24Bold = Font.system(size: 24, weight: .bold)

    // MARK: - Body

    static let body11Regular = Font.system(size: 11, weight: .regular)
    static let body13Regular = Font.system(size: 13, weight: .regular)
    static let body13Medium = Font.system(size: 13, weight: .medium)
    static let body13Semibold = Font.system(size: 13, weight: .semibold)
    static let body15Regular = Font.system(size: 15, weight: .regular)
    static let body15Semibold = Font.system(size: 15, weight: .semibold)
    static let body17Regular = Font.system(size: 17, weight: .regular)
    static let body17Semibold = Font.system(size: 17, weight: .semibold)
}

// MARK: - Typography with Line Height

struct Typography: ViewModifier {
    let font: Font
    let lineHeight: CGFloat
    let fontSize: CGFloat

    func body(content: Content) -> some View {
        content
            .font(font)
            .lineSpacing(lineHeight - fontSize)
    }
}

extension View {

    // MARK: - H1

    func h1Bold() -> some View {
        self.font(.h1Bold)
    }

    // MARK: - Headline

    func headline17Medium() -> some View {
        modifier(Typography(font: .headline17Medium, lineHeight: 24, fontSize: 17))
    }

    func headline20Medium() -> some View {
        modifier(Typography(font: .headline20Medium, lineHeight: 26, fontSize: 20))
    }

    func headline24Medium() -> some View {
        modifier(Typography(font: .headline24Medium, lineHeight: 32, fontSize: 24))
    }

    func headline24Bold() -> some View {
        modifier(Typography(font: .headline24Bold, lineHeight: 32, fontSize: 24))
    }

    // MARK: - Body

    func body11Regular() -> some View {
        modifier(Typography(font: .body11Regular, lineHeight: 18, fontSize: 11))
    }

    func body13Regular() -> some View {
        modifier(Typography(font: .body13Regular, lineHeight: 20, fontSize: 13))
    }

    func body13Medium() -> some View {
        modifier(Typography(font: .body13Medium, lineHeight: 20, fontSize: 13))
    }

    func body13Semibold() -> some View {
        modifier(Typography(font: .body13Semibold, lineHeight: 20, fontSize: 13))
    }

    func body15Regular() -> some View {
        modifier(Typography(font: .body15Regular, lineHeight: 22, fontSize: 15))
    }

    func body15Semibold() -> some View {
        modifier(Typography(font: .body15Semibold, lineHeight: 22, fontSize: 15))
    }

    func body17Regular() -> some View {
        modifier(Typography(font: .body17Regular, lineHeight: 24, fontSize: 17))
    }

    func body17Semibold() -> some View {
        modifier(Typography(font: .body17Semibold, lineHeight: 24, fontSize: 17))
    }
}
