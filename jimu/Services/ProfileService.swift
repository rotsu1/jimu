//
//  ProfileService.swift
//  jimu
//
//  Created by Jimu Team on 18/1/2026.
//

import Foundation
import Supabase

// MARK: - Contribution Data
/// Represents workout frequency data for the contribution grid
struct ContributionData: Sendable {
    /// Date string (YYYY-MM-DD) to workout count
    let workoutsByDate: [String: Int]
    
    /// Total workouts in the period
    let totalWorkouts: Int
    
    /// Current streak (consecutive days with workouts)
    let currentStreak: Int
    
    /// Longest streak in the period
    let longestStreak: Int
    
    /// Convert to the format expected by ContributionGraphView
    func toDateIntDict() -> [Date: Int] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "UTC")
        
        var result: [Date: Int] = [:]
        for (dateString, count) in workoutsByDate {
            if let date = formatter.date(from: dateString) {
                let calendar = Calendar.current
                let startOfDay = calendar.startOfDay(for: date)
                result[startOfDay] = count
            }
        }
        return result
    }
}

// MARK: - Profile Service Errors
enum ProfileServiceError: LocalizedError, Sendable {
    case notAuthenticated
    case profileNotFound
    case fetchFailed(String)
    case updateFailed(String)
    case followFailed(String)
    case privacyRestricted
    
    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "ユーザーが認証されていません"
        case .profileNotFound:
            return "プロフィールが見つかりません"
        case .fetchFailed(let message):
            return "データの取得に失敗しました: \(message)"
        case .updateFailed(let message):
            return "更新に失敗しました: \(message)"
        case .followFailed(let message):
            return "フォロー操作に失敗しました: \(message)"
        case .privacyRestricted:
            return "このユーザーのプロフィールは非公開です"
        }
    }
}

// MARK: - Profile Service
/// Service layer for profile and social features
final class ProfileService: @unchecked Sendable {
    
    // MARK: - Singleton
    static let shared = ProfileService()
    
    private let supabase = SupabaseManager.shared
    
    private init() {}
    
    // MARK: - Profile Operations
    
    /// Fetches a user's profile
    func fetchProfile(userId: UUID) async throws -> DBProfile {
        do {
            let profile: DBProfile = try await supabase.from("profiles")
                .select()
                .eq("id", value: userId.uuidString)
                .single()
                .execute()
                .value
            
            return profile
        } catch {
            throw ProfileServiceError.fetchFailed(error.localizedDescription)
        }
    }
    
    /// Updates the current user's profile
    func updateProfile(userId: UUID, payload: DBProfile.UpdatePayload) async throws -> DBProfile {
        do {
            let profile: DBProfile = try await supabase.from("profiles")
                .update(payload)
                .eq("id", value: userId.uuidString)
                .select()
                .single()
                .execute()
                .value
            
            return profile
        } catch {
            throw ProfileServiceError.updateFailed(error.localizedDescription)
        }
    }
    
    /// Fetches user settings
    func fetchUserSettings(userId: UUID) async throws -> DBUserSettings {
        do {
            let settings: DBUserSettings = try await supabase.from("user_settings")
                .select()
                .eq("id", value: userId.uuidString)
                .single()
                .execute()
                .value
            
            return settings
        } catch {
            throw ProfileServiceError.fetchFailed(error.localizedDescription)
        }
    }
    
    /// Updates user settings
    func updateUserSettings(userId: UUID, payload: DBUserSettings.UpdatePayload) async throws -> DBUserSettings {
        do {
            let settings: DBUserSettings = try await supabase.from("user_settings")
                .update(payload)
                .eq("id", value: userId.uuidString)
                .select()
                .single()
                .execute()
                .value
            
            return settings
        } catch {
            throw ProfileServiceError.updateFailed(error.localizedDescription)
        }
    }
    
    // MARK: - Contribution Grid (Heatmap) Query
    
    /// Fetches workout frequency grouped by date for the contribution grid
    /// Uses a raw query to aggregate workout counts per day
    ///
    /// - Parameters:
    ///   - userId: The user whose contributions to fetch
    ///   - days: Number of days to look back (default 365)
    /// - Returns: ContributionData with workout counts by date
    func fetchContributionData(
        userId: UUID,
        days: Int = 365
    ) async throws -> ContributionData {
        let calendar = Calendar.current
        let endDate = Date()
        guard let startDate = calendar.date(byAdding: .day, value: -days, to: endDate) else {
            throw ProfileServiceError.fetchFailed("Date calculation error")
        }
        
        let formatter = ISO8601DateFormatter()
        let startDateStr = formatter.string(from: startDate)
        
        do {
            // Fetch all workouts in the date range
            // We'll aggregate client-side since Supabase doesn't support GROUP BY in the API easily
            let workouts: [WorkoutDateOnly] = try await supabase.from("workouts")
                .select("started_at")
                .eq("user_id", value: userId.uuidString)
                .gte("started_at", value: startDateStr)
                .order("started_at", ascending: true)
                .execute()
                .value
            
            // Aggregate by date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            dateFormatter.timeZone = TimeZone.current
            
            var workoutsByDate: [String: Int] = [:]
            for workout in workouts {
                let dateKey = dateFormatter.string(from: workout.startedAt)
                workoutsByDate[dateKey, default: 0] += 1
            }
            
            // Calculate streaks
            let (currentStreak, longestStreak) = calculateStreaks(
                workoutsByDate: workoutsByDate,
                endDate: endDate
            )
            
            return ContributionData(
                workoutsByDate: workoutsByDate,
                totalWorkouts: workouts.count,
                currentStreak: currentStreak,
                longestStreak: longestStreak
            )
        } catch {
            throw ProfileServiceError.fetchFailed(error.localizedDescription)
        }
    }
    
    /// Helper struct for date-only workout fetch
    private struct WorkoutDateOnly: Codable, Sendable {
        let startedAt: Date
        
        enum CodingKeys: String, CodingKey {
            case startedAt = "started_at"
        }
    }
    
    /// Calculates current and longest workout streaks
    private func calculateStreaks(
        workoutsByDate: [String: Int],
        endDate: Date
    ) -> (current: Int, longest: Int) {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        var currentStreak = 0
        var longestStreak = 0
        var tempStreak = 0
        var checkDate = calendar.startOfDay(for: endDate)
        
        // Check if today has a workout
        let todayKey = dateFormatter.string(from: checkDate)
        let hadWorkoutToday = (workoutsByDate[todayKey] ?? 0) > 0
        
        // If no workout today, start checking from yesterday for current streak
        if !hadWorkoutToday {
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
        }
        
        // Calculate current streak (consecutive days going backwards)
        while true {
            let dateKey = dateFormatter.string(from: checkDate)
            if (workoutsByDate[dateKey] ?? 0) > 0 {
                currentStreak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
            } else {
                break
            }
        }
        
        // Calculate longest streak
        let sortedDates = workoutsByDate.keys.sorted()
        for dateKey in sortedDates {
            if (workoutsByDate[dateKey] ?? 0) > 0 {
                tempStreak += 1
                longestStreak = max(longestStreak, tempStreak)
            } else {
                tempStreak = 0
            }
        }
        
        // Recalculate longest streak properly by checking consecutive days
        longestStreak = 0
        tempStreak = 0
        var previousDate: Date?
        
        let workoutDates = sortedDates.compactMap { dateFormatter.date(from: $0) }.sorted()
        
        for date in workoutDates {
            if let prev = previousDate {
                let dayDiff = calendar.dateComponents([.day], from: prev, to: date).day ?? 0
                if dayDiff == 1 {
                    tempStreak += 1
                } else {
                    tempStreak = 1
                }
            } else {
                tempStreak = 1
            }
            longestStreak = max(longestStreak, tempStreak)
            previousDate = date
        }
        
        return (currentStreak, longestStreak)
    }
    
    // MARK: - Privacy Check
    
    /// Checks if a profile is viewable by the current user
    func canViewProfile(
        targetUserId: UUID,
        currentUserId: UUID?
    ) async throws -> Bool {
        // Fetch target profile
        let profile = try await fetchProfile(userId: targetUserId)
        
        // Public accounts are always viewable
        if !profile.isPrivateAccount {
            return true
        }
        
        // Own profile is always viewable
        if currentUserId == targetUserId {
            return true
        }
        
        // Check if current user follows the target
        guard let currentId = currentUserId else {
            return false
        }
        
        let followStatus = try await getFollowStatus(
            followerId: currentId,
            followingId: targetUserId
        )
        
        return followStatus == .accepted
    }
    
    /// Checks if a user's workouts are viewable
    func canViewWorkouts(
        targetUserId: UUID,
        currentUserId: UUID?
    ) async throws -> Bool {
        return try await canViewProfile(
            targetUserId: targetUserId,
            currentUserId: currentUserId
        )
    }
    
    // MARK: - Follow Operations
    
    /// Gets the follow status between two users
    func getFollowStatus(
        followerId: UUID,
        followingId: UUID
    ) async throws -> FollowStatus? {
        do {
            let follows: [DBFollow] = try await supabase.from("follows")
                .select()
                .eq("follower_id", value: followerId.uuidString)
                .eq("following_id", value: followingId.uuidString)
                .execute()
                .value
            
            return follows.first?.status
        } catch {
            throw ProfileServiceError.fetchFailed(error.localizedDescription)
        }
    }
    
    /// Sends a follow request
    func followUser(
        followerId: UUID,
        followingId: UUID
    ) async throws {
        // Check if target is private
        let targetProfile = try await fetchProfile(userId: followingId)
        let status: FollowStatus = targetProfile.isPrivateAccount ? .pending : .accepted
        
        let payload = DBFollow.InsertPayload(
            followerId: followerId,
            followingId: followingId,
            status: status
        )
        
        do {
            try await supabase.from("follows")
                .insert(payload)
                .execute()
        } catch {
            throw ProfileServiceError.followFailed(error.localizedDescription)
        }
    }
    
    /// Unfollows a user
    func unfollowUser(
        followerId: UUID,
        followingId: UUID
    ) async throws {
        do {
            try await supabase.from("follows")
                .delete()
                .eq("follower_id", value: followerId.uuidString)
                .eq("following_id", value: followingId.uuidString)
                .execute()
        } catch {
            throw ProfileServiceError.followFailed(error.localizedDescription)
        }
    }
    
    /// Accepts a follow request (for private accounts)
    func acceptFollowRequest(
        followerId: UUID,
        followingId: UUID
    ) async throws {
        do {
            try await supabase.from("follows")
                .update(["status": FollowStatus.accepted.rawValue])
                .eq("follower_id", value: followerId.uuidString)
                .eq("following_id", value: followingId.uuidString)
                .execute()
        } catch {
            throw ProfileServiceError.followFailed(error.localizedDescription)
        }
    }
    
    /// Fetches followers of a user
    func fetchFollowers(
        userId: UUID,
        status: FollowStatus? = .accepted
    ) async throws -> [DBProfile] {
        do {
            // First get follower IDs
            var query = supabase.from("follows")
                .select("follower_id")
                .eq("following_id", value: userId.uuidString)
            
            if let status = status {
                query = query.eq("status", value: status.rawValue)
            }
            
            let follows: [FollowerIdOnly] = try await query.execute().value
            let followerIds = follows.map { $0.followerId.uuidString }
            
            guard !followerIds.isEmpty else {
                return []
            }
            
            // Fetch profiles
            let profiles: [DBProfile] = try await supabase.from("profiles")
                .select()
                .in("id", values: followerIds)
                .execute()
                .value
            
            return profiles
        } catch {
            throw ProfileServiceError.fetchFailed(error.localizedDescription)
        }
    }
    
    /// Fetches users that a user follows
    func fetchFollowing(
        userId: UUID,
        status: FollowStatus? = .accepted
    ) async throws -> [DBProfile] {
        do {
            var query = supabase.from("follows")
                .select("following_id")
                .eq("follower_id", value: userId.uuidString)
            
            if let status = status {
                query = query.eq("status", value: status.rawValue)
            }
            
            let follows: [FollowingIdOnly] = try await query.execute().value
            let followingIds = follows.map { $0.followingId.uuidString }
            
            guard !followingIds.isEmpty else {
                return []
            }
            
            let profiles: [DBProfile] = try await supabase.from("profiles")
                .select()
                .in("id", values: followingIds)
                .execute()
                .value
            
            return profiles
        } catch {
            throw ProfileServiceError.fetchFailed(error.localizedDescription)
        }
    }
    
    private struct FollowerIdOnly: Codable, Sendable {
        let followerId: UUID
        
        enum CodingKeys: String, CodingKey {
            case followerId = "follower_id"
        }
    }
    
    private struct FollowingIdOnly: Codable, Sendable {
        let followingId: UUID
        
        enum CodingKeys: String, CodingKey {
            case followingId = "following_id"
        }
    }
    
    // MARK: - Profile Stats
    
    /// Fetches computed profile statistics
    func fetchProfileStats(userId: UUID) async throws -> ProfileStats {
        // Fetch contribution data for streak info
        let contributions = try await fetchContributionData(userId: userId, days: 365)
        
        // Fetch total volume (sum of weight * reps for all completed sets)
        let profile = try await fetchProfile(userId: userId)
        
        return ProfileStats(
            totalWorkouts: profile.totalWorkouts,
            currentStreak: contributions.currentStreak,
            longestStreak: contributions.longestStreak,
            totalCaloriesBurned: profile.totalCaloriesBurned
        )
    }
}

// MARK: - Profile Stats Model
struct ProfileStats: Sendable {
    let totalWorkouts: Int
    let currentStreak: Int
    let longestStreak: Int
    let totalCaloriesBurned: Int
}
