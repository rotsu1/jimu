//
//  DBExercise.swift
//  jimu
//
//  Created by Jimu Team on 18/1/2026.
//

import Foundation

/// Database model for `exercises` table
/// Represents a library of performable movements
struct DBExercise: Codable, Identifiable, Sendable {
    let id: UUID
    var name: String
    var nameJa: String?
    var imageUrl: String?
    var targetMuscles: [String] // Array of muscle group identifiers
    var equipmentUsed: [String] // Array of equipment identifiers
    var suggestedRestSeconds: Int
    
    // Ownership: NULL = system exercise, UUID = custom exercise by user
    let createdBy: UUID?
    
    // Timestamps
    let createdAt: Date
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case nameJa = "name_ja"
        case imageUrl = "image_url"
        case targetMuscles = "target_muscles"
        case equipmentUsed = "equipment_used"
        case suggestedRestSeconds = "suggested_rest_seconds"
        case createdBy = "created_by"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Insert Payload
extension DBExercise {
    /// DTO for creating a new exercise
    struct InsertPayload: Codable, Sendable {
        let name: String
        var nameJa: String?
        var imageUrl: String?
        var targetMuscles: [String]
        var equipmentUsed: [String]
        var suggestedRestSeconds: Int
        var createdBy: UUID?
        
        enum CodingKeys: String, CodingKey {
            case name
            case nameJa = "name_ja"
            case imageUrl = "image_url"
            case targetMuscles = "target_muscles"
            case equipmentUsed = "equipment_used"
            case suggestedRestSeconds = "suggested_rest_seconds"
            case createdBy = "created_by"
        }
    }
}

// MARK: - Conversion to/from App Model
extension DBExercise {
    /// Convert database model to app model
    func toAppModel() -> Exercise {
        // Convert string arrays to enums
        let muscleGroups = targetMuscles.compactMap { MuscleGroup(rawValue: $0) }
        let tools = equipmentUsed.compactMap { ExerciseTool(rawValue: $0) }
        
        return Exercise(
            id: id,
            nameJa: nameJa ?? name,
            muscleGroups: muscleGroups.isEmpty ? [.chest] : muscleGroups,
            tools: tools,
            gifUrl: imageUrl
        )
    }
}

extension Exercise {
    /// Convert app model to database insert payload
    func toDBInsertPayload(createdBy userId: UUID? = nil) -> DBExercise.InsertPayload {
        DBExercise.InsertPayload(
            name: nameJa, // Use Japanese name as primary for now
            nameJa: nameJa,
            imageUrl: gifUrl,
            targetMuscles: muscleGroups.map { $0.rawValue },
            equipmentUsed: tools.map { $0.rawValue },
            suggestedRestSeconds: 60,
            createdBy: userId
        )
    }
}

