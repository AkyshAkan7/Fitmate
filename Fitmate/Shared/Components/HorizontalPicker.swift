//
//  HorizontalPicker.swift
//  Fitmate
//
//  Created by Akan Akysh on 02/03/26.
//

import SwiftUI

struct HorizontalPicker<SelectionValue, Content>: View where SelectionValue: Hashable & Sendable, Content: View {
    @State private var scrollPosition: ScrollPosition = .init(idType: SelectionValue.self)

    private var items: [SelectionValue]
    private var content: (SelectionValue) -> Content
    @Binding private var selection: SelectionValue

    private let config: Config

    init(
        items: [SelectionValue],
        selection: Binding<SelectionValue>,
        config: Config = Config(),
        @ViewBuilder content: @escaping (SelectionValue) -> Content
    ) {
        self.items = items
        self.content = content
        self.config = config
        _selection = selection
    }

    struct Config {
        var numberOfDisplays: CGFloat = 5
        var spacing: CGFloat = 0
        var itemSize: CGSize = .init(width: 48, height: 48)
    }

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let margin = max((size.width - config.itemSize.width) / 2, 0)

            scrollViewContent
                .scrollTargetBehavior(.viewAligned(limitBehavior: .never))
                .contentMargins(.horizontal, margin)
                .scrollPosition($scrollPosition, anchor: .center)
                .onAppear {
                    scrollPosition.scrollTo(id: selection)
                }
                .onChange(of: scrollPosition) { _, newValue in
                    Task { @MainActor in
                        if let newSelection = newValue.viewID(type: SelectionValue.self) {
                            selection = newSelection
                        }
                    }
                }
                .sensoryFeedback(.impact(weight: .heavy), trigger: selection)
                .mask { maskView }
        }
    }

    private var scrollViewContent: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.element) { _, item in
                    itemContent(item)
                }
            }
            .scrollTargetLayout()
        }
    }

    private func itemContent(_ item: SelectionValue) -> some View {
        content(item)
            .frame(width: config.itemSize.width, height: config.itemSize.height)
            .visualEffect { content, proxy in
                let isSelected = item == selection
                return content
                    .opacity(isSelected ? 1.0 : 0.4)
            }
    }

    private var maskView: some View {
        let count = Int(config.numberOfDisplays)
        return LinearGradient(
            colors: [.clear] + Array(repeating: .black, count: count) + [.clear],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

#Preview {
    @Previewable @State var selection: Int = 25

    VStack(spacing: 20) {
        HorizontalPicker(
            items: Array(1...100),
            selection: $selection,
            config: HorizontalPicker.Config(
                numberOfDisplays: 5,
                itemSize: .init(width: 60, height: 60)
            )
        ) { item in
            Text("\(item)")
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(Color.appBlack)
        }
        .frame(height: 80)

        Text("Selected: \(selection)")
    }
    .padding()
}
