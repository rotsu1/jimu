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
    var isWorkoutExpanded = false // ワークアウト画面が展開されているか（全画面表示か）
    var showCompletionAnimation = false
    var currentWorkout: Workout?
    
    // MARK: - Timer
    var elapsedSeconds: Int = 0
    private var timer: Timer?
    
    // MARK: - Rest Timer
    var restTimerSeconds: Int = 0
    var isRestTimerActive: Bool = false
    private var defaultRestTimerDuration: Int = 60 // デフォルト60秒
    private var restTimer: Timer?
    var showRestTimerPicker: Bool = false
    var activeExerciseIdForRestTimer: UUID?
    
    // Exercise ID -> Rest Duration (Seconds)
    var exerciseRestDurations: [UUID: Int] = [:]
    
    // UI binding for picker
    var restTimerDuration: Int {
        get {
            if let exerciseId = activeExerciseIdForRestTimer, let duration = exerciseRestDurations[exerciseId] {
                return duration
            }
            return defaultRestTimerDuration
        }
        set {
            if let exerciseId = activeExerciseIdForRestTimer {
                exerciseRestDurations[exerciseId] = newValue
            } else {
                defaultRestTimerDuration = newValue
            }
        }
    }
    
    // MARK: - Exercise & Sets
    var selectedExercises: [Exercise] = []
    var workoutSets: [UUID: [WorkoutSet]] = [:] // exerciseId -> sets
    
    // MARK: - Routines
    var savedRoutines: [Routine] = []
    
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
        startWorkoutInternal()
    }
    
    func startWorkout(from routine: Routine) {
        startWorkoutInternal()
        
        // Load routine data
        for routineExercise in routine.exercises {
            addExercise(routineExercise.exercise)
            
            // Set rest duration
            exerciseRestDurations[routineExercise.exercise.id] = routineExercise.restDuration
            
            // Override the default initial set with routine sets
            // Remove the default set first (addExercise adds one)
            // Actually, addExercise adds one set. We should clear it and add routine sets.
            if var sets = workoutSets[routineExercise.exercise.id] {
                sets.removeAll()
                
                for (index, templateSet) in routineExercise.sets.enumerated() {
                    let newSet = WorkoutSet(
                        workoutId: currentWorkout!.id,
                        exerciseId: routineExercise.exercise.id,
                        weight: templateSet.weight,
                        reps: templateSet.reps,
                        setNumber: index + 1,
                        isCompleted: false
                    )
                    sets.append(newSet)
                }
                workoutSets[routineExercise.exercise.id] = sets
            }
        }
    }
    
    private func startWorkoutInternal() {
        isWorkoutActive = true
        isWorkoutExpanded = true // 開始時は展開する
        elapsedSeconds = 0
        selectedExercises = []
        workoutSets = [:]
        exerciseRestDurations = [:] // Reset rest durations
        
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
        isWorkoutExpanded = true // 完了画面は全画面で表示
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
        isWorkoutExpanded = false
        elapsedSeconds = 0
        selectedExercises = []
        workoutSets = [:]
        exerciseRestDurations = [:]
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
    
    // MARK: - Rest Timer Logic
    
    func startRestTimer() {
        startRestTimer(duration: defaultRestTimerDuration)
    }
    
    func startRestTimer(duration: Int) {
        // 既存のタイマーがあれば停止
        stopRestTimer()
        
        restTimerSeconds = duration
        isRestTimerActive = true
        
        restTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.restTimerSeconds > 0 {
                self.restTimerSeconds -= 1
            } else {
                self.stopRestTimer()
                // TODO: タイマー終了時の通知やサウンド
            }
        }
    }
    
    func stopRestTimer() {
        restTimer?.invalidate()
        restTimer = nil
        isRestTimerActive = false
    }
    
    var formattedRestTime: String {
        let minutes = restTimerSeconds / 60
        let seconds = restTimerSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var formattedRestDuration: String {
        // Use active exercise duration if available
        let duration = restTimerDuration
        
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
        guard !selectedExercises.contains(where: { $0.id == exercise.id }) else { return }
        selectedExercises.append(exercise)
        
        // Set default rest duration for new exercise if not already set
        if exerciseRestDurations[exercise.id] == nil {
            exerciseRestDurations[exercise.id] = defaultRestTimerDuration
        }
        
        // 初期セットを追加
        addSet(for: exercise.id)
    }
    
    func removeExercise(_ exercise: Exercise) {
        selectedExercises.removeAll { $0.id == exercise.id }
        workoutSets.removeValue(forKey: exercise.id)
        exerciseRestDurations.removeValue(forKey: exercise.id)
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
            // セット完了時に休憩タイマーを開始（完了になった場合のみ）
            // かつ、タイマー時間が設定されている場合（0秒以外）
            if isCompleted {
                let duration = exerciseRestDurations[exerciseId] ?? defaultRestTimerDuration
                if duration > 0 {
                    startRestTimer(duration: duration)
                }
            }
        }
        
        workoutSets[exerciseId] = sets
    }
    
    func sets(for exerciseId: UUID) -> [WorkoutSet] {
        workoutSets[exerciseId] ?? []
    }
}
