//
//  ProfileHeaderView.swift
//  jimu
//
//  Created by Jimu Team on 14/1/2026.
//

import SwiftUI

/// プロフィールヘッダー
struct ProfileHeaderView: View {
    @Binding var user: Profile
    @State private var showEditProfile = false
    
    var body: some View {
        VStack(spacing: 16) {
            // アバター
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.green, .mint, .teal],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                
                Text(String(user.username.prefix(1)))
                    .font(.system(size: 44, weight: .bold))
                    .foregroundColor(.white)
                
                // プレミアムバッジ
                if user.isPremium {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                        .background(
                            Circle()
                                .fill(Color(.systemBackground))
                                .frame(width: 28, height: 28)
                        )
                        .offset(x: 36, y: 36)
                }
            }
            
            // ユーザー名
            HStack(spacing: 6) {
                Text(user.username)
                    .font(.title2)
                    .fontWeight(.bold)
                
                if user.isPremium {
                    Text("PRO")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            LinearGradient(
                                colors: [.green, .mint],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(4)
                }
            }
            
            // 自己紹介
            if !user.bio.isEmpty {
                Text(user.bio)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            // 編集ボタン
            Button(action: {
                showEditProfile = true
            }) {
                Text("プロフィールを編集")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(Color(.systemGray5))
                    .cornerRadius(20)
            }
        }
        .padding(.vertical, 8)
        .fullScreenCover(isPresented: $showEditProfile) {
            EditProfileView(user: $user)
        }
    }
}

#Preview {
    ProfileHeaderView(user: .constant(MockData.shared.currentUser))
        .preferredColorScheme(.dark)
}
