//
//  WorkoutRecorderViewModel.swift
//  jimu
//
//  Created by Jimu Team on 14/1/2026.
//

import Foundation
import SwiftUI

/// ワークアウト記録画面のViewModel
@Observable
final class WorkoutRecorderViewModel {
    // MARK: - Workout State
    var isWorkoutActive = false
    var showCompletionAnimation = false
    var currentWorkout: Workout?
    
    // MARK: - Timer
    var elapsedSeconds: Int = 0
    private var timer: Timer?
    
    // MARK: - Exercise & Sets
    var selectedExercises: [Exercise] = []
    var workoutSets: [UUID: [WorkoutSet]] = [:] // exerciseId -> sets
    
    // MARK: - Sheet State
    var showExercisePicker = false
    
    // MARK: - Computed Properties
    
    var formattedElapsedTime: String {
        let hours = elapsedSeconds / 3600
        let minutes = (elapsedSeconds % 3600) / 60
        let seconds = elapsedSeconds % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    var totalSetsCount: Int {
        workoutSets.values.reduce(0) { $0 + $1.count }
    }
    
    var completedSetsCount: Int {
        workoutSets.values.reduce(0) { count, sets in
            count + sets.filter { $0.isCompleted }.count
        }
    }
    
    // MARK: - Workout Control
    
    func startWorkout() {
        isWorkoutActive = true
        elapsedSeconds = 0
        selectedExercises = []
        workoutSets = [:]
        
        currentWorkout = Workout(
            userId: MockData.shared.currentUser.id,
            startedAt: Date(),
            status: .ongoing
        )
        
        startTimer()
    }
    
    func finishWorkout() {
        stopTimer()
        isWorkoutActive = false
        showCompletionAnimation = true
        
        currentWorkout?.endedAt = Date()
        currentWorkout?.status = .completed
        
        // アニメーション後にリセット
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.showCompletionAnimation = false
            self?.currentWorkout = nil
        }
    }
    
    func cancelWorkout() {
        stopTimer()
        isWorkoutActive = false
        elapsedSeconds = 0
        selectedExercises = []
        workoutSets = [:]
        currentWorkout = nil
    }
    
    // MARK: - Timer
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.elapsedSeconds += 1
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - Exercise Management
    
    func addExercise(_ exercise: Exercise) {
        guard !selectedExercises.contains(where: { $0.id == exercise.id }) else { return }
        selectedExercises.append(exercise)
        
        // 初期セットを追加
        addSet(for: exercise.id)
    }
    
    func removeExercise(_ exercise: Exercise) {
        selectedExercises.removeAll { $0.id == exercise.id }
        workoutSets.removeValue(forKey: exercise.id)
    }
    
    // MARK: - Set Management
    
    func addSet(for exerciseId: UUID) {
        guard let workoutId = currentWorkout?.id else { return }
        
        var sets = workoutSets[exerciseId] ?? []
        let setNumber = sets.count + 1
        
        // 前回のセットの値をコピー（あれば）
        let previousSet = sets.last
        
        let newSet = WorkoutSet(
            workoutId: workoutId,
            exerciseId: exerciseId,
            weight: previousSet?.weight ?? 0,
            reps: previousSet?.reps ?? 10,
            setNumber: setNumber,
            isCompleted: false
        )
        
        sets.append(newSet)
        workoutSets[exerciseId] = sets
    }
    
    func removeSet(for exerciseId: UUID, at index: Int) {
        guard var sets = workoutSets[exerciseId], index < sets.count else { return }
        sets.remove(at: index)
        
        // セット番号を再割り当て
        for i in 0..<sets.count {
            sets[i].setNumber = i + 1
        }
        
        workoutSets[exerciseId] = sets
    }
    
    func updateSet(for exerciseId: UUID, at index: Int, weight: Double? = nil, reps: Int? = nil, isCompleted: Bool? = nil) {
        guard var sets = workoutSets[exerciseId], index < sets.count else { return }
        
        if let weight = weight {
            sets[index].weight = weight
        }
        if let reps = reps {
            sets[index].reps = reps
        }
        if let isCompleted = isCompleted {
            sets[index].isCompleted = isCompleted
        }
        
        workoutSets[exerciseId] = sets
    }
    
    func sets(for exerciseId: UUID) -> [WorkoutSet] {
        workoutSets[exerciseId] ?? []
    }
}
