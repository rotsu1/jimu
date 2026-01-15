//
//  TimelineCompactView.swift
//  jimu
//
//  Created by Jimu Team on 14/1/2026.
//

import SwiftUI

/// コンパクトタイムライン表示（記録のみの場合）
struct TimelineCompactView: View {
    let item: MockData.TimelineItem
    
    var body: some View {
        HStack(spacing: 12) {
            // アバター
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.green.opacity(0.8), .mint.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 40, height: 40)
                .overlay(
                    Text(String(item.user.username.prefix(1)))
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text(item.user.username)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    if item.user.isPremium {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.green)
                            .font(.caption2)
                    }
                    
                    Text("・")
                        .foregroundColor(.secondary)
                    
                    Text(relativeTimeString(from: item.workout.startedAt))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // トレーニング要約
                Text(item.summaryText)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                HStack(spacing: 12) {
                    Label("\(item.workout.durationMinutes)分", systemImage: "clock")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Label("\(item.sets.count)セット", systemImage: "checkmark.circle")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // 詳細ボタン
            Button(action: {}) {
                Text("詳細")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.green)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.green.opacity(0.15))
                    .cornerRadius(16)
            }
        }
        .padding(16)
    }
    
    private func relativeTimeString(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

#Preview {
    VStack(spacing: 0) {
        TimelineCompactView(item: MockData.shared.timelineItems[4])
        Divider()
        TimelineCompactView(item: MockData.shared.timelineItems[5])
    }
    .preferredColorScheme(.dark)
}
