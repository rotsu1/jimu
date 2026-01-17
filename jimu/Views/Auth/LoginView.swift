//
//  LoginView.swift
//  jimu
//
//  Created by Jimu Team on 17/1/2026.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(red: 0.08, green: 0.08, blue: 0.12),
                    Color(red: 0.05, green: 0.12, blue: 0.10),
                    Color(red: 0.03, green: 0.08, blue: 0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Subtle pattern overlay
            GeometryReader { geometry in
                ZStack {
                    // Animated circles in background
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.green.opacity(0.15), Color.clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: 200
                            )
                        )
                        .frame(width: 400, height: 400)
                        .offset(x: -100, y: -200)
                    
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.mint.opacity(0.1), Color.clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: 150
                            )
                        )
                        .frame(width: 300, height: 300)
                        .offset(x: 150, y: 400)
                }
            }
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Logo Section
                VStack(spacing: 24) {
                    Image("Jimu-nobackground")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 180, height: 180)
                        .shadow(color: .green.opacity(0.3), radius: 20, x: 0, y: 10)
                    
                    VStack(spacing: 8) {
                        Text("Jimu")
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.white, .white.opacity(0.9)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        
                        Text("筋トレを記録しよう")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                Spacer()
                
                // Login Buttons Section
                VStack(spacing: 16) {
                    // Apple Sign In Button
                    Button(action: {
                        authViewModel.signInWithApple()
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "apple.logo")
                                .font(.system(size: 20, weight: .medium))
                            Text("Appleでサインイン")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.white)
                        .cornerRadius(14)
                    }
                    .disabled(authViewModel.isLoading)
                    
                    // Google Sign In Button
                    Button(action: {
                        authViewModel.signInWithGoogle()
                    }) {
                        HStack(spacing: 12) {
                            // Google icon (using SF Symbol as placeholder)
                            Image(systemName: "g.circle.fill")
                                .font(.system(size: 22, weight: .medium))
                                .foregroundColor(.red)
                            Text("Googleでサインイン")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color(.systemGray6))
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                    }
                    .disabled(authViewModel.isLoading)
                }
                .padding(.horizontal, 32)
                
                // Loading indicator
                if authViewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .green))
                        .padding(.top, 24)
                }
                
                Spacer()
                    .frame(height: 32)
                
                // Terms text
                VStack(spacing: 4) {
                    Text("続行することで、")
                        .foregroundColor(.gray)
                    HStack(spacing: 4) {
                        Button("利用規約") {
                            // Open terms
                        }
                        .foregroundColor(.green)
                        Text("と")
                            .foregroundColor(.gray)
                        Button("プライバシーポリシー") {
                            // Open privacy policy
                        }
                        .foregroundColor(.green)
                    }
                    Text("に同意したことになります")
                        .foregroundColor(.gray)
                }
                .font(.system(size: 12))
                .multilineTextAlignment(.center)
                .padding(.bottom, 32)
            }
        }
    }
}

#Preview {
    LoginView()
        .environment(AuthViewModel())
}

