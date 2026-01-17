//
//  UsernameSetupView.swift
//  jimu
//
//  Created by Jimu Team on 17/1/2026.
//

import SwiftUI

struct UsernameSetupView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @FocusState private var isTextFieldFocused: Bool
    
    @State private var username: String = ""
    @State private var validationError: String?
    @State private var isChecking = false
    
    private var isValid: Bool {
        authViewModel.validateUsername(username) == nil && !isChecking
    }
    
    var body: some View {
        ZStack {
            // Background
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    // Progress indicator
                    HStack(spacing: 8) {
                        Capsule()
                            .fill(Color.green)
                            .frame(height: 4)
                        Capsule()
                            .fill(Color(.systemGray4))
                            .frame(height: 4)
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 16)
                    
                    Spacer().frame(height: 24)
                    
                    // Icon
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.green.opacity(0.2), .mint.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "at")
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundColor(.green)
                    }
                    
                    VStack(spacing: 8) {
                        Text("ユーザー名を決めよう")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("他のユーザーから見える名前です")
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 24)
                
                Spacer().frame(height: 48)
                
                // Username Input
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("@")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        TextField("username", text: $username)
                            .font(.system(size: 20, weight: .medium))
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .focused($isTextFieldFocused)
                            .onChange(of: username) { _, newValue in
                                // Real-time validation
                                validationError = authViewModel.validateUsername(newValue)
                            }
                        
                        // Validation indicator
                        if !username.isEmpty {
                            if isChecking {
                                ProgressView()
                                    .scaleEffect(0.8)
                            } else if isValid {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.system(size: 20))
                            } else {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                                    .font(.system(size: 20))
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Error message
                    if let error = validationError, !username.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .font(.system(size: 12))
                            Text(error)
                                .font(.system(size: 13))
                        }
                        .foregroundColor(.red)
                        .padding(.leading, 4)
                    }
                    
                    // Hint
                    Text("3文字以上、スペースは使用できません")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .padding(.leading, 4)
                }
                .padding(.horizontal, 32)
                
                Spacer()
                
                // Continue Button
                Button(action: {
                    authViewModel.newUsername = username
                    authViewModel.submitUsername()
                }) {
                    HStack {
                        if authViewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("次へ")
                                .font(.system(size: 17, weight: .semibold))
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        isValid ? Color.green : Color(.systemGray4)
                    )
                    .cornerRadius(14)
                }
                .disabled(!isValid || authViewModel.isLoading)
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isTextFieldFocused = true
            }
        }
    }
}

#Preview {
    UsernameSetupView()
        .environment(AuthViewModel())
}

