//
//  RoutineCreatorViewModel.swift
//  jimu
//
//  Created by Jimu Team on 15/1/2026.
//

import Foundation
import SwiftUI

@Observable
class RoutineCreatorViewModel {
    var routineName: String = ""
    var selectedExercises: [RoutineExercise] = []
    
    var showExercisePicker = false
    var showRestTimerPicker = false
    var activeExerciseIdForRestTimer: UUID?
    
    // Binding helper for rest timer picker
    var activeRestDuration: Int {
        get {
            guard let id = activeExerciseIdForRestTimer,
                  let exercise = selectedExercises.first(where: { $0.id == id }) else {
                return 60
            }
            return exercise.restDuration
        }
        set {
            if let id = activeExerciseIdForRestTimer,
               let index = selectedExercises.firstIndex(where: { $0.id == id }) {
                selectedExercises[index].restDuration = newValue
            }
        }
    }
    
    func formattedRestDuration(for exercise: RoutineExercise) -> String {
        let duration = exercise.restDuration
        if duration == 0 {
            return "なし"
        }
        let minutes = duration / 60
        let seconds = duration % 60
        if minutes > 0 {
            if seconds > 0 {
                return "\(minutes)分\(seconds)秒"
            } else {
                return "\(minutes)分"
            }
        } else {
            return "\(seconds)秒"
        }
    }
    
    // MARK: - Exercise Management
    
    func addExercise(_ exercise: Exercise) {
        // Allow duplicates? Usually routines don't have duplicate exercises, but let's prevent for now to match recorder
        guard !selectedExercises.contains(where: { $0.exercise.id == exercise.id }) else { return }
        
        let newRoutineExercise = RoutineExercise(
            exercise: exercise,
            sets: [RoutineSetTemplate(weight: 20, reps: 10)], // Default set
            restDuration: 60 // Default rest
        )
        selectedExercises.append(newRoutineExercise)
    }
    
    func removeExercise(_ exercise: RoutineExercise) {
        selectedExercises.removeAll { $0.id == exercise.id }
    }
    
    // MARK: - Set Management
    
    func addSet(for routineExerciseId: UUID) {
        guard let index = selectedExercises.firstIndex(where: { $0.id == routineExerciseId }) else { return }
        
        // Copy previous set values
        let previousSet = selectedExercises[index].sets.last
        let newSet = RoutineSetTemplate(
            weight: previousSet?.weight ?? 20,
            reps: previousSet?.reps ?? 10
        )
        
        selectedExercises[index].sets.append(newSet)
    }
    
    func removeSet(for routineExerciseId: UUID, at setIndex: Int) {
        guard let exerciseIndex = selectedExercises.firstIndex(where: { $0.id == routineExerciseId }) else { return }
        guard setIndex < selectedExercises[exerciseIndex].sets.count else { return }
        
        selectedExercises[exerciseIndex].sets.remove(at: setIndex)
    }
    
    func updateSet(for routineExerciseId: UUID, at setIndex: Int, weight: Double? = nil, reps: Int? = nil) {
        guard let exerciseIndex = selectedExercises.firstIndex(where: { $0.id == routineExerciseId }) else { return }
        guard setIndex < selectedExercises[exerciseIndex].sets.count else { return }
        
        if let weight = weight {
            selectedExercises[exerciseIndex].sets[setIndex].weight = weight
        }
        if let reps = reps {
            selectedExercises[exerciseIndex].sets[setIndex].reps = reps
        }
    }
    
    // MARK: - Save
    
    func createRoutine() -> Routine? {
        guard !routineName.isEmpty else { return nil }
        guard !selectedExercises.isEmpty else { return nil }
        
        return Routine(name: routineName, exercises: selectedExercises)
    }
}
