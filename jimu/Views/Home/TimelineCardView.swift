//
//  TimelineCardView.swift
//  jimu
//
//  Created by Jimu Team on 14/1/2026.
//

import SwiftUI

/// タイムラインカード（画像やコメント付きの投稿）
struct TimelineCardView: View {
    let item: MockData.TimelineItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // ユーザーヘッダー
            HStack(spacing: 12) {
                // アバター
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.green, .mint],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)
                    .overlay(
                        Text(String(item.user.username.prefix(1)))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(item.user.username)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        if item.user.isPremium {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                        }
                    }
                    
                    Text(relativeTimeString(from: item.workout.startedAt))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // メニューボタン
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.secondary)
                }
            }
            
            // コメント
            if !item.workout.note.isEmpty {
                Text(item.workout.note)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            // 画像プレースホルダー（Kingfisher代用）
            if item.hasImages {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [.gray.opacity(0.3), .gray.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 200)
                    .overlay(
                        VStack(spacing: 8) {
                            Image(systemName: "photo.fill")
                                .font(.largeTitle)
                                .foregroundColor(.secondary)
                            Text("ワークアウト写真")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    )
            }
            
            // トレーニング要約
            HStack(spacing: 16) {
                Label("\(item.workout.durationMinutes)分", systemImage: "clock.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Label("\(item.exercises.count)種目", systemImage: "list.bullet")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Label("\(item.sets.count)セット", systemImage: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // トレーニング内容サマリー
            VStack(alignment: .leading, spacing: 6) {
                ForEach(groupedSets.prefix(3), id: \.exercise.id) { group in
                    HStack(spacing: 8) {
                        Image(systemName: group.exercise.muscleGroup.iconName)
                            .foregroundColor(.green)
                            .font(.caption)
                            .frame(width: 20)
                        
                        Text(group.exercise.nameJa)
                            .font(.caption)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Text(group.bestSet.formattedString)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                if groupedSets.count > 3 {
                    Text("他\(groupedSets.count - 3)種目")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.leading, 28)
                }
            }
            .padding(12)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            // アクションボタン
            HStack(spacing: 0) {
                ActionButton(icon: "heart", count: Int.random(in: 0...50))
                ActionButton(icon: "bubble.right", count: Int.random(in: 0...10))
                ActionButton(icon: "arrow.2.squarepath", count: Int.random(in: 0...5))
                ActionButton(icon: "square.and.arrow.up", count: nil)
            }
        }
        .padding(16)
    }
    
    private var groupedSets: [(exercise: Exercise, sets: [WorkoutSet], bestSet: WorkoutSet)] {
        var result: [(exercise: Exercise, sets: [WorkoutSet], bestSet: WorkoutSet)] = []
        
        for exercise in item.exercises {
            let sets = item.sets.filter { $0.exerciseId == exercise.id }
            if let bestSet = sets.max(by: { $0.weight < $1.weight }) {
                result.append((exercise: exercise, sets: sets, bestSet: bestSet))
            }
        }
        
        return result
    }
    
    private func relativeTimeString(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

/// アクションボタン
struct ActionButton: View {
    let icon: String
    let count: Int?
    
    var body: some View {
        Button(action: {}) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.subheadline)
                
                if let count = count, count > 0 {
                    Text("\(count)")
                        .font(.caption)
                }
            }
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    TimelineCardView(item: MockData.shared.timelineItems[0])
        .preferredColorScheme(.dark)
}
