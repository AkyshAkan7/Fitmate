//
//  Exercise.swift
//  Fitmate
//
//  Created by Akan Akysh on 22/02/26.
//

import Foundation

// MARK: - Muscle Group

enum MuscleGroup: String, CaseIterable, Hashable {
    case chest = "Грудь"
    case back = "Спина"
    case arms = "Руки"
    case legs = "Ноги"
    case shoulders = "Плечи"
}

// MARK: - Exercise Model

struct Exercise: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let subtitle: String
    let muscleGroup: MuscleGroup
}
