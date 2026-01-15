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
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // プロフィールヘッダー
                    ProfileHeaderView(user: user)
                    
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
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape")
                            .foregroundColor(.primary)
                    }
                }
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
        VStack(spacing: 0) {
            ForEach(workouts) { workout in
                VStack(spacing: 0) {
                    HStack(spacing: 12) {
                        // 日付
                        VStack(spacing: 2) {
                            Text(dayString(from: workout.startedAt))
                                .font(.title2)
                                .fontWeight(.bold)
                            Text(monthString(from: workout.startedAt))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(width: 44)
                        
                        // 内容
                        VStack(alignment: .leading, spacing: 4) {
                            let exercises = MockData.shared.exercises(for: workout.id)
                            let sets = MockData.shared.sets(for: workout.id)
                            
                            if !exercises.isEmpty {
                                Text(exercises.map { $0.nameJa }.joined(separator: ", "))
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .lineLimit(1)
                            }
                            
                            HStack(spacing: 8) {
                                Label("\(workout.durationMinutes)分", systemImage: "clock")
                                Label("\(sets.count)セット", systemImage: "checkmark.circle")
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    .padding()
                    
                    Divider()
                        .padding(.leading, 68)
                }
            }
        }
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .padding(.horizontal)
    }
    
    private func dayString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    private func monthString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M月"
        return formatter.string(from: date)
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
