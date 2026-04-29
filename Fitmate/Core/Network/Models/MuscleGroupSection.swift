//
//  MuscleGroupSection.swift
//  Fitmate
//
//  Created by Akan Akysh on 29/04/26.
//

import Foundation

struct MuscleGroupSection: Identifiable, Hashable {
    let id: String
    let name: String
    let nameRu: String
    let exercises: [CatalogExercise]
}

struct CatalogExercise: Identifiable, Hashable {
    let id: String
    let name: String
    let nameRu: String
    let subtitle: String
    let subtitleRu: String
    let imageLink: String?
}
