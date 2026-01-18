//
//  UserSettingsManager.swift
//  jimu
//
//  Created by Jimu Team on 18/1/2026.
//

import Foundation
import SwiftUI

// MARK: - User Settings Manager
/// Observable singleton for managing user settings
/// Syncs with Supabase and provides reactive updates to the UI
@Observable
final class UserSettingsManager: @unchecked Sendable {
    
    // MARK: - Singleton
    static let shared = UserSettingsManager()
    
    // MARK: - Settings State
    private(set) var settings: DBUserSettings?
    private(set) var isLoading = false
    private(set) var error: Error?
    
    // MARK: - Convenience Accessors
    
    /// Current weight unit (defaults to kg)
    var weightUnit: WeightUnit {
        settings?.unitWeight ?? .kg
    }
    
    /// Current distance unit (defaults to km)
    var distanceUnit: DistanceUnit {
        settings?.unitDistance ?? .km
    }
    
    /// Current length unit (defaults to cm)
    var lengthUnit: LengthUnit {
        settings?.unitLength ?? .cm
    }
    
    /// Whether to auto-fill previous workout values
    var autoFillPreviousValues: Bool {
        settings?.autoFillPreviousValues ?? true
    }
    
    /// Default rest timer duration in seconds
    var defaultTimerSeconds: Int {
        settings?.defaultTimerSeconds ?? 60
    }
    
    /// Whether sound is enabled
    var soundEnabled: Bool {
        settings?.soundEnabled ?? true
    }
    
    /// Current theme preference
    var theme: ThemeOption {
        settings?.theme ?? .system
    }
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Load Settings
    
    /// Loads settings for the current user
    @MainActor
    func loadSettings(for userId: UUID) async {
        isLoading = true
        error = nil
        
        do {
            settings = try await ProfileService.shared.fetchUserSettings(userId: userId)
        } catch {
            self.error = error
            // Use defaults if fetch fails
            settings = DBUserSettings.defaultSettings(for: userId)
        }
        
        isLoading = false
    }
    
    // MARK: - Update Settings
    
    /// Updates a specific setting
    @MainActor
    func updateSettings(for userId: UUID, payload: DBUserSettings.UpdatePayload) async throws {
        isLoading = true
        error = nil
        
        do {
            settings = try await ProfileService.shared.updateUserSettings(
                userId: userId,
                payload: payload
            )
        } catch {
            self.error = error
            throw error
        }
        
        isLoading = false
    }
    
    // MARK: - Convenience Update Methods
    
    @MainActor
    func setWeightUnit(_ unit: WeightUnit, for userId: UUID) async throws {
        try await updateSettings(
            for: userId,
            payload: DBUserSettings.UpdatePayload(unitWeight: unit)
        )
    }
    
    @MainActor
    func setDistanceUnit(_ unit: DistanceUnit, for userId: UUID) async throws {
        try await updateSettings(
            for: userId,
            payload: DBUserSettings.UpdatePayload(unitDistance: unit)
        )
    }
    
    @MainActor
    func setAutoFillPreviousValues(_ enabled: Bool, for userId: UUID) async throws {
        try await updateSettings(
            for: userId,
            payload: DBUserSettings.UpdatePayload(autoFillPreviousValues: enabled)
        )
    }
    
    @MainActor
    func setDefaultTimer(_ seconds: Int, for userId: UUID) async throws {
        try await updateSettings(
            for: userId,
            payload: DBUserSettings.UpdatePayload(defaultTimerSeconds: seconds)
        )
    }
    
    @MainActor
    func setSoundEnabled(_ enabled: Bool, for userId: UUID) async throws {
        try await updateSettings(
            for: userId,
            payload: DBUserSettings.UpdatePayload(soundEnabled: enabled)
        )
    }
    
    @MainActor
    func setTheme(_ theme: ThemeOption, for userId: UUID) async throws {
        try await updateSettings(
            for: userId,
            payload: DBUserSettings.UpdatePayload(theme: theme)
        )
    }
    
    // MARK: - Clear (for logout)
    
    @MainActor
    func clear() {
        settings = nil
        error = nil
    }
}

// MARK: - Environment Key
private struct UserSettingsKey: EnvironmentKey {
    static let defaultValue = UserSettingsManager.shared
}

extension EnvironmentValues {
    var userSettings: UserSettingsManager {
        get { self[UserSettingsKey.self] }
        set { self[UserSettingsKey.self] = newValue }
    }
}

// MARK: - View Extension
extension View {
    /// Provides user settings to the view hierarchy
    func withUserSettings(_ manager: UserSettingsManager = .shared) -> some View {
        self.environment(\.userSettings, manager)
    }
}

