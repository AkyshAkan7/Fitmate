//
//  HorizontalPicker.swift
//  Fitmate
//
//  Created by Akan Akysh on 02/03/26.
//

import SwiftUI

struct HorizontalPickerConfig {
    var visibleCount: Int = 5
    var selectedFontSize: CGFloat = 42
    var normalFontSize: CGFloat = 32
    var alphaFactor: Double = 0.3
}

struct HorizontalPicker<Item: Hashable>: View {
    let items: [Item]
    @Binding var selection: Item
    var config: HorizontalPickerConfig = HorizontalPickerConfig()
    let itemLabel: (Item) -> String

    @GestureState private var translation: CGFloat = 0

    private var currentIndex: Int {
        items.firstIndex(of: selection) ?? 0
    }

    var body: some View {
        GeometryReader { geometry in
            let itemWidth = geometry.size.width / CGFloat(config.visibleCount)

            ZStack {
                HStack(spacing: 0) {
                    ForEach(Array(items.enumerated()), id: \.element) { index, item in
                        itemView(
                            item: item,
                            index: index,
                            itemWidth: itemWidth,
                            geometry: geometry
                        )
                    }
                }
                .frame(width: geometry.size.width, alignment: .leading)
                .offset(x: calculateOffset(itemWidth: itemWidth, geometry: geometry))
                .animation(.easeOut(duration: 0.15), value: currentIndex)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .contentShape(Rectangle())
            .gesture(
                DragGesture()
                    .updating($translation) { value, state, _ in
                        state = value.translation.width
                    }
                    .onEnded { value in
                        let offset = value.translation.width / itemWidth
                        let newIndex = (CGFloat(currentIndex) - offset).rounded()
                        let clampedIndex = min(max(Int(newIndex), 0), items.count - 1)
                        selection = items[clampedIndex]
                    }
            )
            .mask {
                LinearGradient(
                    stops: [
                        .init(color: .clear, location: 0),
                        .init(color: .black, location: 0.2),
                        .init(color: .black, location: 0.8),
                        .init(color: .clear, location: 1)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            }
        }
    }

    private func calculateOffset(itemWidth: CGFloat, geometry: GeometryProxy) -> CGFloat {
        let baseOffset = -CGFloat(currentIndex + 1) * itemWidth
        let centerOffset = (geometry.size.width / 2) + (itemWidth / 2)
        return baseOffset + translation + centerOffset
    }

    @ViewBuilder
    private func itemView(item: Item, index: Int, itemWidth: CGFloat, geometry: GeometryProxy) -> some View {
        let maxRange = floor(CGFloat(config.visibleCount) / 2.0)
        let offset = translation / itemWidth
        let currentPosition = CGFloat(currentIndex) - offset
        let positionGap = CGFloat(index) - currentPosition
        let distancePercent = min(abs(positionGap / maxRange), 1.0)

        let isCenter = abs(positionGap) < 0.5
        let alpha = 1.0 - (Double(distancePercent) * (1.0 - config.alphaFactor))

        Text(itemLabel(item))
            .font(.system(
                size: isCenter ? config.selectedFontSize : config.normalFontSize,
                weight: isCenter ? .semibold : .medium
            ))
            .foregroundStyle(Color.appBlack.opacity(alpha))
            .frame(width: itemWidth, height: geometry.size.height)
    }
}

#Preview {
    @Previewable @State var selection: Int = 10

    VStack {
        HorizontalPicker(
            items: Array(1...100),
            selection: $selection,
            config: HorizontalPickerConfig(visibleCount: 5)
        ) { item in
            "\(item)"
        }
        .frame(height: 70)

        Text("Selected: \(selection)")
    }
}
