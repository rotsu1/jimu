//
//  Routine.swift
//  jimu
//
//  Created by Jimu Team on 15/1/2026.
//

import Foundation

struct Routine: Identifiable, Codable {
    let id: UUID
    var name: String
    var exercises: [RoutineExercise]
    
    init(id: UUID = UUID(), name: String, exercises: [RoutineExercise] = []) {
        self.id = id
        self.name = name
        self.exercises = exercises
    }
}

struct RoutineExercise: Identifiable, Codable {
    let id: UUID
    let exercise: Exercise // Store full exercise for display
    var sets: [RoutineSetTemplate]
    var restDuration: Int // 秒単位
    
    init(id: UUID = UUID(), exercise: Exercise, sets: [RoutineSetTemplate] = [], restDuration: Int = 60) {
        self.id = id
        self.exercise = exercise
        self.sets = sets
        self.restDuration = restDuration
    }
}

struct RoutineSetTemplate: Identifiable, Codable {
    let id: UUID
    var weight: Double
    var reps: Int
    
    init(id: UUID = UUID(), weight: Double, reps: Int) {
        self.id = id
        self.weight = weight
        self.reps = reps
    }
}
