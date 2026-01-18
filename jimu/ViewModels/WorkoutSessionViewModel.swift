//
//  WorkoutSessionViewModel.swift
//  jimu
//
//  Created by Jimu Team on 18/1/2026.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Session Exercise (UI State)
/// Represents an exercise in the active workout session
struct SessionExercise: Identifiable, Equatable {
    let id: UUID
    let exercise: Exercise
    var sets: [SessionSet]
    var restTimerSeconds: Int
    var memo: String?
    
    init(
        id: UUID = UUID(),
        exercise: Exercise,
        sets: [SessionSet] = [],
        restTimerSeconds: Int = 60,
        memo: String? = nil
    ) {
        self.id = id
        self.exercise = exercise
        self.sets = sets
        self.restTimerSeconds = restTimerSeconds
        self.memo = memo
    }
}

// MARK: - Session Set (UI State)
/// Represents a set in the active workout session
struct SessionSet: Identifiable, Equatable {
    let id: UUID // Temporary local ID
    var weight: Double // In user's display unit
    var reps: Int
    var isCompleted: Bool
    
    init(
        id: UUID = UUID(),
        weight: Double = 0,
        reps: Int = 10,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.weight = weight
        self.reps = reps
        self.isCompleted = isCompleted
    }
}

// MARK: - Workout Session State
enum WorkoutSessionState: Equatable {
    case idle
    case active
    case completing
    case saving
    case saved(DBWorkout)
    case error(String)
    
    static func == (lhs: WorkoutSessionState, rhs: WorkoutSessionState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.active, .active), (.completing, .completing), (.saving, .saving):
            return true
        case (.saved(let a), .saved(let b)):
            return a.id == b.id
        case (.error(let a), .error(let b)):
            return a == b
        default:
            return false
        }
    }
}

// MARK: - Workout Session ViewModel
/// ViewModel for managing the active workout session
/// Integrates with Supabase via WorkoutService
@Observable
final class WorkoutSessionViewModel {
    
    // MARK: - Session State
    private(set) var state: WorkoutSessionState = .idle
    private(set) var exercises: [SessionExercise] = []
    
    // MARK: - Timer
    private(set) var elapsedSeconds: Int = 0
    private var timerCancellable: AnyCancellable?
    private var startedAt: Date?
    
    // MARK: - Rest Timer
    private(set) var restTimerSeconds: Int = 0
    private(set) var isRestTimerActive = false
    private var restTimerCancellable: AnyCancellable?
    
    // MARK: - Completion Data
    var completionName: String = ""
    var completionComment: String = ""
    var completionVisibility: VisibilityType = .public
    var completionImages: [UIImage] = []
    
    // MARK: - User Context
    private var userId: UUID?
    private let workoutService = WorkoutService.shared
    private let userSettingsManager = UserSettingsManager.shared
    
    // MARK: - Computed Properties
    
    var isActive: Bool {
        state == .active || state == .completing
    }
    
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
    
    var formattedRestTime: String {
        let minutes = restTimerSeconds / 60
        let seconds = restTimerSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var totalSetsCount: Int {
        exercises.reduce(0) { $0 + $1.sets.count }
    }
    
    var completedSetsCount: Int {
        exercises.reduce(0) { total, exercise in
            total + exercise.sets.filter { $0.isCompleted }.count
        }
    }
    
    var hasIncompleteSets: Bool {
        exercises.contains { exercise in
            exercise.sets.contains { !$0.isCompleted }
        }
    }
    
    var defaultWorkoutName: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 {
            return "Morning Workout"
        } else if hour < 18 {
            return "Afternoon Workout"
        } else {
            return "Evening Workout"
        }
    }
    
    // MARK: - Initialization
    
    init() {}
    
    // MARK: - Session Control
    
    /// Starts a new workout session
    func startWorkout(userId: UUID) {
        guard state == .idle else { return }
        
        self.userId = userId
        self.startedAt = Date()
        self.elapsedSeconds = 0
        self.exercises = []
        self.state = .active
        
        startTimer()
    }
    
    /// Starts a workout from a routine template
    func startWorkout(userId: UUID, from routine: Routine) {
        startWorkout(userId: userId)
        
        // Load exercises from routine
        for routineExercise in routine.exercises {
            var sessionSets: [SessionSet] = []
            for templateSet in routineExercise.sets {
                sessionSets.append(SessionSet(
                    weight: templateSet.weight,
                    reps: templateSet.reps,
                    isCompleted: false
                ))
            }
            
            let sessionExercise = SessionExercise(
                exercise: routineExercise.exercise,
                sets: sessionSets,
                restTimerSeconds: routineExercise.restDuration
            )
            exercises.append(sessionExercise)
        }
    }
    
    /// Prepares for workout completion
    func prepareForCompletion() -> Bool {
        guard state == .active else { return false }
        
        // Validate: at least one exercise
        guard !exercises.isEmpty else {
            state = .error("種目が追加されていません")
            return false
        }
        
        // Validate: all sets completed
        if hasIncompleteSets {
            state = .error("完了していないセットがあります")
            return false
        }
        
        stopTimer()
        state = .completing
        completionName = ""
        completionComment = ""
        completionVisibility = .public
        completionImages = []
        
        return true
    }
    
    /// Saves the workout to the database
    func saveWorkout() async throws -> DBWorkout {
        guard let userId = userId, let startedAt = startedAt else {
            throw WorkoutServiceError.notAuthenticated
        }
        
        state = .saving
        
        // Convert to session model
        let sessionData = WorkoutSessionModel(
            userId: userId,
            name: completionName.isEmpty ? defaultWorkoutName : completionName,
            comment: completionComment.isEmpty ? nil : completionComment,
            imageUrl: nil, // TODO: Upload images and get URL
            visibility: completionVisibility,
            startedAt: startedAt,
            endedAt: Date(),
            durationSeconds: elapsedSeconds,
            exercises: exercises.enumerated().map { index, exercise in
                WorkoutSessionModel.SessionExerciseData(
                    exerciseId: exercise.exercise.id,
                    orderIndex: index,
                    restTimerSeconds: exercise.restTimerSeconds,
                    memo: exercise.memo,
                    sets: exercise.sets.enumerated().map { setIndex, set in
                        WorkoutSessionModel.SessionSetData(
                            weight: set.weight,
                            reps: set.reps,
                            isCompleted: set.isCompleted,
                            orderIndex: setIndex
                        )
                    }
                )
            }
        )
        
        do {
            let savedWorkout = try await workoutService.saveWorkout(session: sessionData)
            await MainActor.run {
                self.state = .saved(savedWorkout)
            }
            return savedWorkout
        } catch {
            await MainActor.run {
                self.state = .error(error.localizedDescription)
            }
            throw error
        }
    }
    
    /// Cancels the current workout
    func cancelWorkout() {
        stopTimer()
        stopRestTimer()
        
        state = .idle
        exercises = []
        elapsedSeconds = 0
        startedAt = nil
    }
    
    /// Resets after save (for congrats screen dismiss)
    func reset() {
        state = .idle
        exercises = []
        elapsedSeconds = 0
        startedAt = nil
        completionName = ""
        completionComment = ""
        completionImages = []
    }
    
    /// Go back from completion to active
    func resumeEditing() {
        state = .active
        startTimer()
    }
    
    // MARK: - Timer Management
    
    private func startTimer() {
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.elapsedSeconds += 1
            }
    }
    
    private func stopTimer() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }
    
    // MARK: - Rest Timer
    
    func startRestTimer(duration: Int) {
        stopRestTimer()
        restTimerSeconds = duration
        isRestTimerActive = true
        
        restTimerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.restTimerSeconds > 0 {
                    self.restTimerSeconds -= 1
                } else {
                    self.stopRestTimer()
                    // TODO: Play notification sound
                }
            }
    }
    
    func stopRestTimer() {
        restTimerCancellable?.cancel()
        restTimerCancellable = nil
        isRestTimerActive = false
    }
    
    // MARK: - Exercise Management
    
    /// Adds an exercise to the session
    func addExercise(_ exercise: Exercise) async {
        let defaultRest = userSettingsManager.defaultTimerSeconds
        var sessionExercise = SessionExercise(
            exercise: exercise,
            sets: [],
            restTimerSeconds: defaultRest
        )
        
        // Auto-fill previous values if enabled
        if userSettingsManager.autoFillPreviousValues, let userId = userId {
            if let previousSets = try? await workoutService.fetchLastPerformedData(
                exerciseId: exercise.id,
                userId: userId
            ) {
                let weightUnit = userSettingsManager.weightUnit
                sessionExercise.sets = previousSets.map { dbSet in
                    SessionSet(
                        weight: dbSet.weight.toWeightUnit(weightUnit),
                        reps: dbSet.reps,
                        isCompleted: false
                    )
                }
            }
        }
        
        // Add at least one set
        if sessionExercise.sets.isEmpty {
            sessionExercise.sets.append(SessionSet())
        }
        
        await MainActor.run {
            self.exercises.append(sessionExercise)
        }
    }
    
    /// Removes an exercise from the session
    func removeExercise(at index: Int) {
        guard exercises.indices.contains(index) else { return }
        exercises.remove(at: index)
    }
    
    /// Removes an exercise by ID
    func removeExercise(id: UUID) {
        exercises.removeAll { $0.id == id }
    }
    
    /// Reorders exercises (for drag and drop)
    func moveExercise(from source: IndexSet, to destination: Int) {
        exercises.move(fromOffsets: source, toOffset: destination)
    }
    
    // MARK: - Set Management
    
    /// Adds a set to an exercise
    func addSet(to exerciseId: UUID) {
        guard let exerciseIndex = exercises.firstIndex(where: { $0.id == exerciseId }) else {
            return
        }
        
        // Copy from previous set if exists
        let previousSet = exercises[exerciseIndex].sets.last
        let newSet = SessionSet(
            weight: previousSet?.weight ?? 0,
            reps: previousSet?.reps ?? 10,
            isCompleted: false
        )
        
        exercises[exerciseIndex].sets.append(newSet)
    }
    
    /// Removes a set from an exercise
    func removeSet(from exerciseId: UUID, at setIndex: Int) {
        guard let exerciseIndex = exercises.firstIndex(where: { $0.id == exerciseId }) else {
            return
        }
        guard exercises[exerciseIndex].sets.indices.contains(setIndex) else { return }
        
        exercises[exerciseIndex].sets.remove(at: setIndex)
    }
    
    /// Updates a set's values
    func updateSet(
        exerciseId: UUID,
        setIndex: Int,
        weight: Double? = nil,
        reps: Int? = nil,
        isCompleted: Bool? = nil
    ) {
        guard let exerciseIndex = exercises.firstIndex(where: { $0.id == exerciseId }) else {
            return
        }
        guard exercises[exerciseIndex].sets.indices.contains(setIndex) else { return }
        
        if let weight = weight {
            exercises[exerciseIndex].sets[setIndex].weight = weight
        }
        if let reps = reps {
            exercises[exerciseIndex].sets[setIndex].reps = reps
        }
        if let isCompleted = isCompleted {
            let wasCompleted = exercises[exerciseIndex].sets[setIndex].isCompleted
            exercises[exerciseIndex].sets[setIndex].isCompleted = isCompleted
            
            // Start rest timer when completing a set
            if isCompleted && !wasCompleted {
                let duration = exercises[exerciseIndex].restTimerSeconds
                if duration > 0 {
                    startRestTimer(duration: duration)
                }
            }
        }
    }
    
    /// Reorders sets within an exercise
    func moveSets(exerciseId: UUID, from source: IndexSet, to destination: Int) {
        guard let exerciseIndex = exercises.firstIndex(where: { $0.id == exerciseId }) else {
            return
        }
        exercises[exerciseIndex].sets.move(fromOffsets: source, toOffset: destination)
    }
    
    // MARK: - Rest Timer per Exercise
    
    func setRestDuration(for exerciseId: UUID, seconds: Int) {
        guard let exerciseIndex = exercises.firstIndex(where: { $0.id == exerciseId }) else {
            return
        }
        exercises[exerciseIndex].restTimerSeconds = seconds
    }
    
    func getRestDuration(for exerciseId: UUID) -> Int {
        guard let exercise = exercises.first(where: { $0.id == exerciseId }) else {
            return userSettingsManager.defaultTimerSeconds
        }
        return exercise.restTimerSeconds
    }
}

