//
//  DBWorkout.swift
//  jimu
//
//  Created by Jimu Team on 18/1/2026.
//

import Foundation

/// Database model for `workouts` table
/// Represents a single training session
struct DBWorkout: Codable, Identifiable, Sendable {
    let id: UUID
    let userId: UUID
    var name: String?
    var comment: String?
    var imageUrl: String?
    var visibility: VisibilityType
    var startedAt: Date
    var endedAt: Date?
    var durationSeconds: Int?
    
    // Timestamps
    let createdAt: Date
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case comment
        case imageUrl = "image_url"
        case visibility
        case startedAt = "started_at"
        case endedAt = "ended_at"
        case durationSeconds = "duration_seconds"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Insert Payload
extension DBWorkout {
    /// DTO for creating a new workout
    struct InsertPayload: Codable, Sendable {
        let userId: UUID
        var name: String?
        var comment: String?
        var imageUrl: String?
        var visibility: VisibilityType
        var startedAt: Date
        var endedAt: Date?
        var durationSeconds: Int?
        
        enum CodingKeys: String, CodingKey {
            case userId = "user_id"
            case name
            case comment
            case imageUrl = "image_url"
            case visibility
            case startedAt = "started_at"
            case endedAt = "ended_at"
            case durationSeconds = "duration_seconds"
        }
    }
}

// MARK: - Response with Nested Data
extension DBWorkout {
    /// Full workout response including exercises and sets (for deep fetch)
    struct WithExercises: Codable, Identifiable, Sendable {
        let id: UUID
        let userId: UUID
        var name: String?
        var comment: String?
        var imageUrl: String?
        var visibility: VisibilityType
        var startedAt: Date
        var endedAt: Date?
        var durationSeconds: Int?
        let createdAt: Date
        var updatedAt: Date
        
        // Nested workout exercises
        var workoutExercises: [DBWorkoutExercise.WithSets]
        
        enum CodingKeys: String, CodingKey {
            case id
            case userId = "user_id"
            case name
            case comment
            case imageUrl = "image_url"
            case visibility
            case startedAt = "started_at"
            case endedAt = "ended_at"
            case durationSeconds = "duration_seconds"
            case createdAt = "created_at"
            case updatedAt = "updated_at"
            case workoutExercises = "workout_exercises"
        }
    }
}

// MARK: - Conversion
extension DBWorkout {
    func toAppModel() -> Workout {
        Workout(
            id: id,
            userId: userId,
            startedAt: startedAt,
            endedAt: endedAt,
            name: name,
            note: comment ?? "",
            status: endedAt != nil ? .completed : .ongoing
        )
    }
}

