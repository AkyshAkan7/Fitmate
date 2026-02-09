//
//  AppCellControl.swift
//  Fitmate
//
//  Created by Akan Akysh on 09/02/26.
//

import SwiftUI

struct AppCellControl: View {
    let icon: Image
    let title: String
    var subtitle: String? = nil
    var value: String? = nil
    var subvalue: String? = nil
    var isReverse: Bool = false
    @Binding var isSelected: Bool

    var body: some View {
        Button {
            isSelected.toggle()
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

                // Checkbox
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
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
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
    struct PreviewWrapper: View {
        @State private var isSelected1 = false
        @State private var isSelected2 = false
        @State private var isSelected3 = true

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
                    isSelected: $isSelected3
                )
            }
            .padding()
            .background(Color.lightGray)
        }
    }

    return PreviewWrapper()
}
