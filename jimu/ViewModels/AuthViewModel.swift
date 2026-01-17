//
//  AuthViewModel.swift
//  jimu
//
//  Created by Jimu Team on 17/1/2026.
//

import SwiftUI
import Observation

/// 認証状態を管理するViewModel
@Observable
class AuthViewModel {
    
    enum AuthState: Equatable {
        case unauthenticated
        case usernameSetup
        case profileSetup
        case authenticated
    }
    
    var authState: AuthState = .unauthenticated
    var isLoading = false
    var errorMessage: String?
    
    // User data being created during signup
    var newUsername: String = ""
    var newName: String = ""
    var newBio: String = ""
    var newLocation: String = ""
    var newBirthDate: Date = Date()
    var profileImage: UIImage?
    
    // Simulated list of taken usernames for demo
    private let takenUsernames = ["jimu", "admin", "test", "user", "筋トレ太郎"]
    
    init() {
        // Check if user is already logged in
        checkAuthStatus()
    }
    
    func checkAuthStatus() {
        // For demo purposes, check UserDefaults for logged in state
        if UserDefaults.standard.bool(forKey: "isLoggedIn") {
            authState = .authenticated
        } else {
            authState = .unauthenticated
        }
    }
    
    // MARK: - Sign In Methods
    
    func signInWithGoogle() {
        isLoading = true
        errorMessage = nil
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.isLoading = false
            // For new users, go to username setup
            // For existing users, would go directly to authenticated
            self?.authState = .usernameSetup
        }
    }
    
    func signInWithApple() {
        isLoading = true
        errorMessage = nil
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.isLoading = false
            // For new users, go to username setup
            self?.authState = .usernameSetup
        }
    }
    
    // MARK: - Username Validation
    
    func isUsernameValid(_ username: String) -> Bool {
        // Username must be at least 3 characters
        guard username.count >= 3 else { return false }
        // Username must not contain spaces
        guard !username.contains(" ") else { return false }
        return true
    }
    
    func isUsernameTaken(_ username: String) -> Bool {
        return takenUsernames.contains(username.lowercased())
    }
    
    func validateUsername(_ username: String) -> String? {
        if username.isEmpty {
            return "ユーザー名を入力してください"
        }
        if username.count < 3 {
            return "ユーザー名は3文字以上で入力してください"
        }
        if username.contains(" ") {
            return "ユーザー名にスペースは使用できません"
        }
        if isUsernameTaken(username) {
            return "このユーザー名は既に使用されています"
        }
        return nil
    }
    
    func submitUsername() {
        guard validateUsername(newUsername) == nil else { return }
        
        isLoading = true
        
        // Simulate checking username availability
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.isLoading = false
            self?.authState = .profileSetup
        }
    }
    
    // MARK: - Profile Setup
    
    func completeProfileSetup() {
        isLoading = true
        
        // Simulate saving profile
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.isLoading = false
            // Save login state
            UserDefaults.standard.set(true, forKey: "isLoggedIn")
            UserDefaults.standard.set(self?.newUsername, forKey: "username")
            self?.authState = .authenticated
        }
    }
    
    func skipProfileSetup() {
        // Save login state with just username
        UserDefaults.standard.set(true, forKey: "isLoggedIn")
        UserDefaults.standard.set(newUsername, forKey: "username")
        authState = .authenticated
    }
    
    // MARK: - Sign Out
    
    func signOut() {
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        UserDefaults.standard.removeObject(forKey: "username")
        
        // Reset state
        newUsername = ""
        newName = ""
        newBio = ""
        newLocation = ""
        newBirthDate = Date()
        profileImage = nil
        
        authState = .unauthenticated
    }
}

