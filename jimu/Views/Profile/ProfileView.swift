//
//  ProfileView.swift
//  jimu
//
//  Created by Jimu Team on 14/1/2026.
//

import SwiftUI

/// マイページ
struct ProfileView: View {
    @State private var user = MockData.shared.currentUser
    @State private var contributionData = MockData.shared.contributionData(for: MockData.shared.currentUser.id)
    @State private var workouts = MockData.shared.workouts(for: MockData.shared.currentUser.id)
    
    /// 自分のワークアウト履歴（タイムライン形式）
    private var myTimelineItems: [MockData.TimelineItem] {
        MockData.shared.timelineItems.filter { $0.user.id == MockData.shared.currentUser.id }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // プロフィールヘッダー
                    ProfileHeaderView(user: $user)
                    
                    // 統計カード
                    statsSection
                    
                    // 草カレンダー
                    VStack(alignment: .leading, spacing: 12) {
                        Text("トレーニング記録")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ContributionGraphView(contributions: contributionData)
                            .padding(.horizontal)
                    }
                    
                    // ワークアウト履歴
                    VStack(alignment: .leading, spacing: 12) {
                        Text("履歴")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        workoutHistory
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("マイページ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView().toolbar(.hidden, for: .tabBar)) {
                        Image(systemName: "gearshape")
                            .foregroundColor(.primary)
                    }
                }
            }
            .navigationDestination(for: MockData.TimelineItem.self) { item in
                WorkoutDetailView(item: item)
            }
        }
    }
    
    // MARK: - Stats Section
    
    private var statsSection: some View {
        HStack(spacing: 12) {
            StatCard(
                title: "今月",
                value: "\(workoutsThisMonth)",
                unit: "回",
                icon: "calendar",
                color: .green
            )
            
            StatCard(
                title: "連続",
                value: "\(currentStreak)",
                unit: "日",
                icon: "flame.fill",
                color: .orange
            )
            
            StatCard(
                title: "合計",
                value: "\(totalWorkouts)",
                unit: "回",
                icon: "trophy.fill",
                color: .yellow
            )
        }
        .padding(.horizontal)
    }
    
    private var workoutsThisMonth: Int {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        return workouts.filter { $0.startedAt >= startOfMonth }.count
    }
    
    private var currentStreak: Int {
        // 簡易的な連続日数計算（ダミー）
        return Int.random(in: 3...14)
    }
    
    private var totalWorkouts: Int {
        contributionData.count
    }
    
    // MARK: - Workout History
    
    private var workoutHistory: some View {
        LazyVStack(spacing: 0) {
            ForEach(myTimelineItems) { item in
                NavigationLink(value: item) {
                    TimelineCardView(item: item)
                }
                .buttonStyle(PlainButtonStyle())
                
                Divider()
                    .background(Color.gray.opacity(0.3))
            }
        }
    }
}

/// 統計カード
struct StatCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)
                Text(unit)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

#Preview {
    ProfileView()
        .preferredColorScheme(.dark)
}
