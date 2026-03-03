//
//  TemplateStore.swift
//  Fitmate
//
//  Created by Akan Akysh on 03/03/26.
//

import SwiftUI
import Combine

// TODO: - delete or change logic

final class TemplateStore: ObservableObject {
    @Published var templates: [WorkoutTemplate] = []

    func add(name: String, exercises: [Exercise]) {
        let template = WorkoutTemplate(name: name, exercises: exercises)
        templates.append(template)
    }

    func remove(at index: Int) {
        templates.remove(at: index)
    }
}
