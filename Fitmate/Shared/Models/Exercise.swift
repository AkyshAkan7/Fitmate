//
//  Exercise.swift
//  Fitmate
//
//  Created by Akan Akysh on 22/02/26.
//

import Foundation

// MARK: - Muscle Group

struct MuscleGroup: Identifiable, Hashable {
    let id: String
    let name: String
    let nameRu: String

    /// Локальный сентинел для таба «Мои» (не приходит с сервера).
    static let custom = MuscleGroup(id: "__custom__", name: "My", nameRu: "Мои")

    /// Что показывать на чипах. Пока — русское имя.
    /// При локализации заменим на выбор по `Locale.current`.
    var displayName: String { nameRu }

    #if DEBUG
    static let previewChest = MuscleGroup(id: "preview-chest", name: "Chest", nameRu: "Грудь")
    static let previewBack = MuscleGroup(id: "preview-back", name: "Back", nameRu: "Спина")
    #endif
}

// MARK: - Exercise Model

struct Exercise: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let subtitle: String
    let muscleGroup: MuscleGroup
    let imageURL: URL?

    init(name: String, subtitle: String, muscleGroup: MuscleGroup, imageURL: URL? = nil) {
        self.name = name
        self.subtitle = subtitle
        self.muscleGroup = muscleGroup
        self.imageURL = imageURL
    }
}
