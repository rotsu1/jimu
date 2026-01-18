//
//  Profile.swift
//  jimu
//
//  Created by Jimu Team on 14/1/2026.
//

import Foundation

/// ユーザープロフィールモデル
/// This is the app-level model for UI consumption
struct Profile: Identifiable, Hashable, Codable {
    let id: UUID
    var username: String
    var displayName: String?
    var bio: String
    var location: String
    var birthDate: Date
    var isPrivate: Bool
    var isPremium: Bool
    var avatarUrl: String?
    var subscriptionPlan: SubscriptionTier?
    
    // Denormalized stats
    var totalWorkouts: Int?
    var currentStreak: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case displayName = "display_name"
        case bio
        case location
        case birthDate = "birth_date"
        case isPrivate = "is_private_account"
        case isPremium
        case avatarUrl = "avatar_url"
        case subscriptionPlan = "subscription_plan"
        case totalWorkouts = "total_workouts"
        case currentStreak = "current_streak"
    }
    
    init(
        id: UUID = UUID(),
        username: String,
        displayName: String? = nil,
        bio: String = "",
        location: String = "",
        birthDate: Date = Date(),
        isPrivate: Bool = false,
        isPremium: Bool = false,
        avatarUrl: String? = nil,
        subscriptionPlan: SubscriptionTier? = nil,
        totalWorkouts: Int? = nil,
        currentStreak: Int? = nil
    ) {
        self.id = id
        self.username = username
        self.displayName = displayName
        self.bio = bio
        self.location = location
        self.birthDate = birthDate
        self.isPrivate = isPrivate
        self.isPremium = isPremium
        self.avatarUrl = avatarUrl
        self.subscriptionPlan = subscriptionPlan
        self.totalWorkouts = totalWorkouts
        self.currentStreak = currentStreak
    }
}
