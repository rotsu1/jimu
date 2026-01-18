//
//  DatabaseEnums.swift
//  jimu
//
//  Created by Jimu Team on 18/1/2026.
//

import Foundation

// MARK: - Subscription Tier
/// Maps to `subscription_tier` enum in Supabase
enum SubscriptionTier: String, Codable, CaseIterable, Sendable {
    case free
    case monthly
    case yearly
    case lifetime
    
    var displayName: String {
        switch self {
        case .free: return "無料プラン"
        case .monthly: return "月額プラン"
        case .yearly: return "年間プラン"
        case .lifetime: return "永久プラン"
        }
    }
    
    var isPremium: Bool {
        self != .free
    }
}

// MARK: - Visibility Type
/// Maps to `visibility_type` enum in Supabase
enum VisibilityType: String, Codable, CaseIterable, Sendable {
    case `public`
    case `private`
    case followersOnly = "followers_only"
    
    var displayName: String {
        switch self {
        case .public: return "公開"
        case .private: return "非公開"
        case .followersOnly: return "フォロワーのみ"
        }
    }
    
    var iconName: String {
        switch self {
        case .public: return "globe"
        case .private: return "lock.fill"
        case .followersOnly: return "person.2.fill"
        }
    }
}

// MARK: - Weight Unit
/// Maps to `weight_unit` enum in Supabase
enum WeightUnit: String, Codable, CaseIterable, Sendable {
    case kg
    case lbs
    
    var displayName: String {
        rawValue.uppercased()
    }
    
    /// Conversion factor from kg to this unit
    var fromKgFactor: Double {
        switch self {
        case .kg: return 1.0
        case .lbs: return 2.20462
        }
    }
    
    /// Conversion factor from this unit to kg
    var toKgFactor: Double {
        switch self {
        case .kg: return 1.0
        case .lbs: return 0.453592
        }
    }
}

// MARK: - Distance Unit
/// Maps to `distance_unit` enum in Supabase
enum DistanceUnit: String, Codable, CaseIterable, Sendable {
    case km
    case miles
    
    var displayName: String {
        switch self {
        case .km: return "km"
        case .miles: return "miles"
        }
    }
    
    var fromKmFactor: Double {
        switch self {
        case .km: return 1.0
        case .miles: return 0.621371
        }
    }
    
    var toKmFactor: Double {
        switch self {
        case .km: return 1.0
        case .miles: return 1.60934
        }
    }
}

// MARK: - Length Unit
/// Maps to `length_unit` enum in Supabase
enum LengthUnit: String, Codable, CaseIterable, Sendable {
    case cm
    case inch
    
    var displayName: String {
        rawValue
    }
}

// MARK: - Theme Option
/// Maps to `theme_option` enum in Supabase
enum ThemeOption: String, Codable, CaseIterable, Sendable {
    case system
    case light
    case dark
    
    var displayName: String {
        switch self {
        case .system: return "システム"
        case .light: return "ライト"
        case .dark: return "ダーク"
        }
    }
}

// MARK: - Follow Status
/// Maps to `status` field in `follows` table
enum FollowStatus: String, Codable, CaseIterable, Sendable {
    case pending
    case accepted
}

