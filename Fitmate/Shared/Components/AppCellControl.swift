//
//  AppCellControl.swift
//  Fitmate
//
//  Created by Akan Akysh on 09/02/26.
//

import SwiftUI

enum AppCellControlStyle {
    case checkbox
    case radio
}

struct AppCellControl: View {
    private let staticIcon: Image?
    private let iconURL: URL?
    let title: String
    var subtitle: String? = nil
    var value: String? = nil
    var subvalue: String? = nil
    var isReverse: Bool = false
    var style: AppCellControlStyle = .checkbox
    @Binding var isSelected: Bool

    init(
        icon: Image,
        title: String,
        subtitle: String? = nil,
        value: String? = nil,
        subvalue: String? = nil,
        isReverse: Bool = false,
        style: AppCellControlStyle = .checkbox,
        isSelected: Binding<Bool>
    ) {
        self.staticIcon = icon
        self.iconURL = nil
        self.title = title
        self.subtitle = subtitle
        self.value = value
        self.subvalue = subvalue
        self.isReverse = isReverse
        self.style = style
        self._isSelected = isSelected
    }

    init(
        iconURL: URL?,
        title: String,
        subtitle: String? = nil,
        value: String? = nil,
        subvalue: String? = nil,
        isReverse: Bool = false,
        style: AppCellControlStyle = .checkbox,
        isSelected: Binding<Bool>
    ) {
        self.staticIcon = nil
        self.iconURL = iconURL
        self.title = title
        self.subtitle = subtitle
        self.value = value
        self.subvalue = subvalue
        self.isReverse = isReverse
        self.style = style
        self._isSelected = isSelected
    }

    var body: some View {
        Button {
            isSelected.toggle()
        } label: {
            HStack(spacing: 12) {
                iconView

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

                // Selection indicator
                selectionIndicator
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var iconView: some View {
        Group {
            if let staticIcon {
                staticIcon.resizable().scaledToFit()
            } else {
                CachedAsyncImage(
                    url: iconURL,
                    content: { image in image.resizable().scaledToFill() },
                    placeholder: { Color.lightGray }
                )
            }
        }
        .frame(width: 48, height: 48)
        .background(Color.lightGray)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    @ViewBuilder
    private var titleView: some View {
        Text(title)
            .body15Regular()
            .foregroundStyle(Color.appBlack)
    }

    @ViewBuilder
    private var subtitleView: some View {
        if let subtitle, !subtitle.isEmpty {
            Text(subtitle)
                .body13Regular()
                .foregroundStyle(Color.appGray)
        }
    }

    @ViewBuilder
    private var valueView: some View {
        if let value, !value.isEmpty {
            Text(value)
                .body15Regular()
                .foregroundStyle(Color.appBlack)
        }
    }

    @ViewBuilder
    private var subvalueView: some View {
        if let subvalue, !subvalue.isEmpty {
            Text(subvalue)
                .body13Regular()
                .foregroundStyle(Color.appGray)
        }
    }

    @ViewBuilder
    private var selectionIndicator: some View {
        switch style {
        case .checkbox:
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? Color.appBlack : Color.appGray.opacity(0.3), lineWidth: 1.5)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? Color.appBlack : Color.clear)
                )
                .frame(width: 20, height: 20)
                .overlay {
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Color.white)
                    }
                }
        case .radio:
            Circle()
                .stroke(isSelected ? Color.appBlack : Color.appGray.opacity(0.3), lineWidth: 2)
                .background(
                    Circle()
                        .fill(Color.clear)
                )
                .frame(width: 20, height: 20)
                .overlay {
                    if isSelected {
                        Circle()
                            .fill(Color.appBlack)
                            .frame(width: 10, height: 10)
                    }
                }
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var isSelected1 = false
        @State private var isSelected2 = true
        @State private var isSelected3 = false
        @State private var isSelected4 = true

        var body: some View {
            VStack(spacing: 12) {
                AppCellControl(
                    icon: Image(systemName: "figure.run"),
                    title: "Title",
                    subtitle: "Subtitle",
                    value: "Value",
                    subvalue: "Subvalue",
                    isSelected: $isSelected1
                )
                
                AppCellControl(
                    icon: Image(systemName: "figure.run"),
                    title: "Title",
                    subtitle: "Subtitle",
                    isSelected: $isSelected2
                )

                AppCellControl(
                    icon: Image(systemName: "dumbbell"),
                    title: "Title",
                    subtitle: "Subtitle",
                    value: "Value",
                    subvalue: "Subvalue",
                    isReverse: true,
                    style: .radio,
                    isSelected: $isSelected3
                )
                
                AppCellControl(
                    icon: Image(systemName: "dumbbell"),
                    title: "Title",
                    subtitle: "Subtitle",
                    value: "Value",
                    subvalue: "Subvalue",
                    isReverse: true,
                    style: .radio,
                    isSelected: $isSelected4
                )
            }
            .padding()
            .background(Color.lightGray)
        }
    }

    return PreviewWrapper()
}
