//
//  AppCell.swift
//  Fitmate
//
//  Created by Akan Akysh on 09/02/26.
//

import SwiftUI

enum AppCellTrailingIcon {
    case chevron
    case drag

    var name: String {
        switch self {
        case .chevron: return "chevronRight"
        case .drag: return "drag"
        }
    }
}

struct AppCell: View {
    let icon: Image
    let title: String
    var subtitle: String? = nil
    var value: String? = nil
    var subvalue: String? = nil
    var isReverse: Bool = false
    var trailingIcon: AppCellTrailingIcon? = .chevron
    var action: (() -> Void)? = nil

    var body: some View {
        Button {
            action?()
        } label: {
            HStack(spacing: 12) {
                // Icon
                icon
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)
                    .background(Color.lightGray)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                // Title & Subtitle
                VStack(alignment: .leading, spacing: 2) {
                    if isReverse {
                        subtitleView
                        titleView
                    } else {
                        titleView
                        subtitleView
                    }
                }

                Spacer()

                // Value & Subvalue
                if value != nil || subvalue != nil {
                    VStack(alignment: .trailing, spacing: 2) {
                        if isReverse {
                            subvalueView
                            valueView
                        } else {
                            valueView
                            subvalueView
                        }
                    }
                }

                // Trailing Icon
                if trailingIcon != nil {
                    trailingIconView
                        .frame(width: 24, height: 24)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var trailingIconView: some View {
        if let trailingIcon {
            Image(trailingIcon.name)
                .renderingMode(.template)
                .foregroundStyle(Color.appGray)
        }
    }

    @ViewBuilder
    private var titleView: some View {
        Text(title)
            .body15Regular()
            .foregroundStyle(Color.appBlack)
    }

    @ViewBuilder
    private var subtitleView: some View {
        if let subtitle {
            Text(subtitle)
                .body13Regular()
                .foregroundStyle(Color.appGray)
        }
    }

    @ViewBuilder
    private var valueView: some View {
        if let value {
            Text(value)
                .body15Regular()
                .foregroundStyle(Color.appBlack)
        }
    }

    @ViewBuilder
    private var subvalueView: some View {
        if let subvalue {
            Text(subvalue)
                .body13Regular()
                .foregroundStyle(Color.appGray)
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        AppCell(
            icon: Image(systemName: "figure.run"),
            title: "Title",
            subtitle: "Subtitle",
            value: "Value",
            subvalue: "Subvalue"
        )

        AppCell(
            icon: Image(systemName: "dumbbell"),
            title: "Title",
            subtitle: "Subtitle",
            value: "Value",
            subvalue: "Subvalue",
            isReverse: true
        )

        AppCell(
            icon: Image(systemName: "flame"),
            title: "Title",
            subtitle: "Subtitle",
            trailingIcon: .drag
        )
    }
    .padding()
    .background(Color.lightGray)
}
