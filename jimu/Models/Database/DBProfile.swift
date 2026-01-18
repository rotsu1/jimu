//
//  DBProfile.swift
//  jimu
//
//  Created by Jimu Team on 18/1/2026.
//

import Foundation

/// Database model for `profiles` table
/// Maps directly to Supabase schema with proper `CodingKeys` for snake_case conversion
struct DBProfile: Codable, Identifiable, Sendable {
    let id: UUID
    var username: String
    var displayName: String?
    var bio: String?
    var avatarUrl: String?
    var subscriptionPlan: SubscriptionTier
    var isPrivateAccount: Bool
    
    // Denormalized metrics (cached counters)
    var totalWorkouts: Int
    var currentStreak: Int
    var totalCaloriesBurned: Int
    
    // Timestamps
    let createdAt: Date
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case displayName = "display_name"
        case bio
        case avatarUrl = "avatar_url"
        case subscriptionPlan = "subscription_plan"
        case isPrivateAccount = "is_private_account"
        case totalWorkouts = "total_workouts"
        case currentStreak = "current_streak"
        case totalCaloriesBurned = "total_calories_burned"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Insert/Update DTOs
extension DBProfile {
    /// DTO for updating profile (excludes read-only fields)
    struct UpdatePayload: Codable, Sendable {
        var username: String?
        var displayName: String?
        var bio: String?
        var avatarUrl: String?
        var isPrivateAccount: Bool?
        
        enum CodingKeys: String, CodingKey {
            case username
            case displayName = "display_name"
            case bio
            case avatarUrl = "avatar_url"
            case isPrivateAccount = "is_private_account"
        }
    }
}

// MARK: - Conversion to/from App Model
extension DBProfile {
    /// Convert database model to app model
    func toAppModel() -> Profile {
        Profile(
            id: id,
            username: username,
            bio: bio ?? "",
            location: "", // Not in DB schema yet
            birthDate: Date(), // Not in DB schema yet
            isPrivate: isPrivateAccount,
            isPremium: subscriptionPlan.isPremium,
            avatarUrl: avatarUrl
        )
    }
}

