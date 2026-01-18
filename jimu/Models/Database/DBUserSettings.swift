//
//  DBUserSettings.swift
//  jimu
//
//  Created by Jimu Team on 18/1/2026.
//

import Foundation

/// Database model for `user_settings` table
/// Stores private user preferences and device configurations
struct DBUserSettings: Codable, Identifiable, Sendable {
    let id: UUID // Same as profile ID (1:1 relationship)
    
    // Security
    var faceIdEnabled: Bool
    
    // Notification Settings
    var dailyReminderEnabled: Bool
    var dailyReminderTime: Date?
    var newFollowerNotification: Bool
    var likesNotification: Bool
    var commentsNotification: Bool
    
    // Training Preferences
    var soundEnabled: Bool
    var defaultTimerSeconds: Int
    var autoFillPreviousValues: Bool
    
    // Units
    var unitWeight: WeightUnit
    var unitDistance: DistanceUnit
    var unitLength: LengthUnit
    
    // Theme
    var theme: ThemeOption
    
    // Timestamps
    let createdAt: Date
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case faceIdEnabled = "face_id_enabled"
        case dailyReminderEnabled = "daily_reminder_enabled"
        case dailyReminderTime = "daily_reminder_time"
        case newFollowerNotification = "new_follower_notification"
        case likesNotification = "likes_notification"
        case commentsNotification = "comments_notification"
        case soundEnabled = "sound_enabled"
        case defaultTimerSeconds = "default_timer_seconds"
        case autoFillPreviousValues = "auto_fill_previous_values"
        case unitWeight = "unit_weight"
        case unitDistance = "unit_distance"
        case unitLength = "unit_length"
        case theme
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Default Values
extension DBUserSettings {
    /// Creates default settings for a new user
    static func defaultSettings(for userId: UUID) -> DBUserSettings {
        let now = Date()
        return DBUserSettings(
            id: userId,
            faceIdEnabled: false,
            dailyReminderEnabled: false,
            dailyReminderTime: nil,
            newFollowerNotification: true,
            likesNotification: true,
            commentsNotification: true,
            soundEnabled: true,
            defaultTimerSeconds: 60,
            autoFillPreviousValues: true,
            unitWeight: .kg,
            unitDistance: .km,
            unitLength: .cm,
            theme: .system,
            createdAt: now,
            updatedAt: now
        )
    }
}

// MARK: - Update Payload
extension DBUserSettings {
    struct UpdatePayload: Codable, Sendable {
        var faceIdEnabled: Bool?
        var dailyReminderEnabled: Bool?
        var dailyReminderTime: Date?
        var newFollowerNotification: Bool?
        var likesNotification: Bool?
        var commentsNotification: Bool?
        var soundEnabled: Bool?
        var defaultTimerSeconds: Int?
        var autoFillPreviousValues: Bool?
        var unitWeight: WeightUnit?
        var unitDistance: DistanceUnit?
        var unitLength: LengthUnit?
        var theme: ThemeOption?
        
        enum CodingKeys: String, CodingKey {
            case faceIdEnabled = "face_id_enabled"
            case dailyReminderEnabled = "daily_reminder_enabled"
            case dailyReminderTime = "daily_reminder_time"
            case newFollowerNotification = "new_follower_notification"
            case likesNotification = "likes_notification"
            case commentsNotification = "comments_notification"
            case soundEnabled = "sound_enabled"
            case defaultTimerSeconds = "default_timer_seconds"
            case autoFillPreviousValues = "auto_fill_previous_values"
            case unitWeight = "unit_weight"
            case unitDistance = "unit_distance"
            case unitLength = "unit_length"
            case theme
        }
    }
}

