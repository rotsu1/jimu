//
//  DBWorkoutSet.swift
//  jimu
//
//  Created by Jimu Team on 18/1/2026.
//

import Foundation

/// Database model for `workout_sets` table
/// Represents the atomic data of the workout (Weight x Reps)
struct DBWorkoutSet: Codable, Identifiable, Sendable {
    let id: UUID
    let workoutExerciseId: UUID
    var weight: Double // Stored in kg (normalized)
    var reps: Int
    var isCompleted: Bool
    var orderIndex: Int
    
    // Timestamps
    let createdAt: Date
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case workoutExerciseId = "workout_exercise_id"
        case weight
        case reps
        case isCompleted = "is_completed"
        case orderIndex = "order_index"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Insert Payload
extension DBWorkoutSet {
    /// DTO for creating a new workout set
    struct InsertPayload: Codable, Sendable {
        let workoutExerciseId: UUID
        var weight: Double
        var reps: Int
        var isCompleted: Bool
        var orderIndex: Int
        
        enum CodingKeys: String, CodingKey {
            case workoutExerciseId = "workout_exercise_id"
            case weight
            case reps
            case isCompleted = "is_completed"
            case orderIndex = "order_index"
        }
    }
}

// MARK: - Batch Insert (for multiple sets at once)
extension DBWorkoutSet {
    /// Create insert payloads from app model sets
    static func createInsertPayloads(
        from sets: [WorkoutSet],
        workoutExerciseId: UUID,
        userSettings: DBUserSettings? = nil
    ) -> [InsertPayload] {
        sets.enumerated().map { index, set in
            // Convert weight to kg if user is using lbs
            var weightInKg = set.weight
            if let settings = userSettings, settings.unitWeight == .lbs {
                weightInKg = set.weight * WeightUnit.lbs.toKgFactor
            }
            
            return InsertPayload(
                workoutExerciseId: workoutExerciseId,
                weight: weightInKg,
                reps: set.reps,
                isCompleted: set.isCompleted,
                orderIndex: index
            )
        }
    }
}

// MARK: - Conversion to App Model
extension DBWorkoutSet {
    /// Convert to app model with optional unit conversion
    func toAppModel(
        workoutId: UUID,
        exerciseId: UUID,
        displayUnit: WeightUnit = .kg
    ) -> WorkoutSet {
        // Convert weight from kg to display unit
        let displayWeight = weight * displayUnit.fromKgFactor
        
        return WorkoutSet(
            id: id,
            workoutId: workoutId,
            exerciseId: exerciseId,
            weight: displayWeight,
            reps: reps,
            setNumber: orderIndex + 1,
            isCompleted: isCompleted
        )
    }
}

