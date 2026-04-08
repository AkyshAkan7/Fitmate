//
//  AddSetView.swift
//  Fitmate
//
//  Created by Akan Akysh on 02/03/26.
//

import SwiftUI

struct AddSetView: View {
    @Environment(\.dismiss) private var dismiss

    let setNumber: Int
    let isEditing: Bool
    var onSave: ((Double, Int) -> Void)?

    @State private var selectedWeight: Double
    @State private var selectedReps: Int
    @State private var weightUnit: WeightUnit = .kg
    @Namespace private var unitAnimation

    private let weights: [Double] = stride(from: 0, through: 300, by: 0.5).map { $0 }
    private let reps: [Int] = Array(1...100)

    init(
        setNumber: Int,
        initialWeight: Double = 25,
        initialReps: Int = 10,
        isEditing: Bool = false,
        onSave: ((Double, Int) -> Void)? = nil
    ) {
        self.setNumber = setNumber
        self.isEditing = isEditing
        self.onSave = onSave
        _selectedWeight = State(initialValue: initialWeight)
        _selectedReps = State(initialValue: initialReps)
    }

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.top, 16)

            Divider()
                .padding(.top, 12)

            weightPicker
                .padding(.top, 20)

            Divider()
                .padding(.top, 20)
                .padding(.horizontal, 16)

            repsPicker
                .padding(.top, 20)

            Spacer()

            AppButton(title: isEditing ? "Сохранить" : "Добавить") {
                onSave?(selectedWeight, selectedReps)
                dismiss()
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(.white)
        .presentationBackground(.white)
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Text("\(setNumber) подход")
                .headline24Semibold()
                .foregroundStyle(Color.appBlack)

            Spacer()

            unitToggle
        }
        .padding(.horizontal, 16)
    }

    private var unitToggle: some View {
        HStack(spacing: 0) {
            ForEach(WeightUnit.allCases, id: \.self) { unit in
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        weightUnit = unit
                    }
                } label: {
                    Text(unit.rawValue)
                        .body15Semibold()
                        .foregroundStyle(weightUnit == unit ? Color.appBlack : Color.appGray)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background {
                            if weightUnit == unit {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white)
                                    .matchedGeometryEffect(id: "unitSelector", in: unitAnimation)
                            }
                        }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(Color.lightGray)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .sensoryFeedback(.impact(weight: .heavy), trigger: weightUnit)
    }

    // MARK: - Weight Picker

    private var weightPicker: some View {
        VStack(spacing: 8) {
            Text("Вес")
                .body17Semibold()
                .foregroundStyle(Color.appBlack)

            HorizontalPicker(
                items: weights,
                selection: $selectedWeight,
                config: HorizontalPicker.Config(
                    numberOfDisplays: 3,
                    itemSize: .init(width: 100, height: 100)
                )
            ) { weight in
                Text(weight.formatted)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(Color.appBlack)
            }
            .frame(height: 70)
        }
    }

    // MARK: - Reps Picker

    private var repsPicker: some View {
        VStack(spacing: 8) {
            Text("Повторений")
                .body17Semibold()
                .foregroundStyle(Color.appBlack)

            HorizontalPicker(
                items: reps,
                selection: $selectedReps,
                config: HorizontalPicker.Config(
                    numberOfDisplays: 3,
                    itemSize: .init(width: 60, height: 60)
                )
            ) { rep in
                Text("\(rep)")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(Color.appBlack)
            }
            .frame(height: 70)
        }
    }

}

// MARK: - Weight Unit

enum WeightUnit: String, CaseIterable {
    case lb = "LB"
    case kg = "KG"
}

#Preview {
    AddSetView(setNumber: 1)
}
