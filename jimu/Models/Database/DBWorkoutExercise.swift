//
//  DBWorkoutExercise.swift
//  jimu
//
//  Created by Jimu Team on 18/1/2026.
//

import Foundation

/// Database model for `workout_exercises` table
/// Represents an instance of an exercise performed within a specific workout
struct DBWorkoutExercise: Codable, Identifiable, Sendable {
    let id: UUID
    let workoutId: UUID
    let exerciseId: UUID
    var orderIndex: Int
    var restTimerSeconds: Int?
    var memo: String?
    
    // Timestamps
    let createdAt: Date
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case workoutId = "workout_id"
        case exerciseId = "exercise_id"
        case orderIndex = "order_index"
        case restTimerSeconds = "rest_timer_seconds"
        case memo
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Insert Payload
extension DBWorkoutExercise {
    /// DTO for creating a new workout exercise link
    struct InsertPayload: Codable, Sendable {
        let workoutId: UUID
        let exerciseId: UUID
        var orderIndex: Int
        var restTimerSeconds: Int?
        var memo: String?
        
        enum CodingKeys: String, CodingKey {
            case workoutId = "workout_id"
            case exerciseId = "exercise_id"
            case orderIndex = "order_index"
            case restTimerSeconds = "rest_timer_seconds"
            case memo
        }
    }
}

// MARK: - Response with Nested Sets
extension DBWorkoutExercise {
    /// Workout exercise with its sets (for deep fetch)
    struct WithSets: Codable, Identifiable, Sendable {
        let id: UUID
        let workoutId: UUID
        let exerciseId: UUID
        var orderIndex: Int
        var restTimerSeconds: Int?
        var memo: String?
        let createdAt: Date
        var updatedAt: Date
        
        // Nested sets
        var workoutSets: [DBWorkoutSet]
        
        // Optional: Include exercise details if joined
        var exercise: DBExercise?
        
        enum CodingKeys: String, CodingKey {
            case id
            case workoutId = "workout_id"
            case exerciseId = "exercise_id"
            case orderIndex = "order_index"
            case restTimerSeconds = "rest_timer_seconds"
            case memo
            case createdAt = "created_at"
            case updatedAt = "updated_at"
            case workoutSets = "workout_sets"
            case exercise = "exercises" // Supabase uses table name for joins
        }
    }
}

