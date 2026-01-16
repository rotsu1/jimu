//
//  ContributionGraphView.swift
//  jimu
//
//  Created by Jimu Team on 14/1/2026.
//

import SwiftUI

/// GitHub風の「草」カレンダー
struct ContributionGraphView: View {
    let contributions: [Date: Int]
    
    private let columns = 52 // 52週間
    private let rows = 7 // 7日間（1週間）
    private let cellSize: CGFloat = 10
    private let cellSpacing: CGFloat = 3
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 4) {
                // 曜日ラベル（固定）
                VStack(spacing: 0) {
                    // 月ラベル分の空白
                    Text("")
                        .font(.caption2)
                        .frame(height: 16)
                    
                    dayLabels
                }
                
                // 月ラベルとグリッドを一緒にスクロール
                ScrollView(.horizontal, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 8) {
                        // 月ラベル
                        monthLabelsContent
                        
                        // グリッド
                        HStack(spacing: cellSpacing) {
                            ForEach(0..<columns, id: \.self) { week in
                                VStack(spacing: cellSpacing) {
                                    ForEach(0..<rows, id: \.self) { day in
                                        let date = dateFor(week: week, day: day)
                                        let intensity = contributions[date] ?? 0
                                        
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(colorFor(intensity: intensity))
                                            .frame(width: cellSize, height: cellSize)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            // 凡例
            legend
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var monthLabelsContent: some View {
        HStack(spacing: 0) {
            ForEach(monthPositions, id: \.month) { position in
                Text(position.name)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .frame(width: CGFloat(position.width) * (cellSize + cellSpacing), alignment: .leading)
            }
        }
    }
    
    private var monthPositions: [(month: Int, name: String, width: Int)] {
        let calendar = Calendar.current
        let now = Date()
        var positions: [(month: Int, name: String, width: Int)] = []
        var currentMonth = -1
        var weekCount = 0
        
        for week in 0..<columns {
            let date = dateFor(week: week, day: 0)
            let month = calendar.component(.month, from: date)
            
            if month != currentMonth {
                if currentMonth != -1 {
                    positions[positions.count - 1].width = weekCount
                }
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "ja_JP")
                formatter.dateFormat = "M月"
                positions.append((month: month, name: formatter.string(from: date), width: 0))
                currentMonth = month
                weekCount = 1
            } else {
                weekCount += 1
            }
        }
        
        if !positions.isEmpty {
            positions[positions.count - 1].width = weekCount
        }
        
        return positions
    }
    
    private var dayLabels: some View {
        VStack(spacing: cellSpacing) {
            ForEach(["日", "月", "火", "水", "木", "金", "土"], id: \.self) { day in
                Text(day)
                    .font(.system(size: 8))
                    .foregroundColor(.secondary)
                    .frame(width: 16, height: cellSize)
            }
        }
    }
    
    private var legend: some View {
        HStack(spacing: 16) {
            Spacer()
            
            Text("Less")
                .font(.caption2)
                .foregroundColor(.secondary)
            
            HStack(spacing: 2) {
                ForEach(0...4, id: \.self) { intensity in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(colorFor(intensity: intensity))
                        .frame(width: cellSize, height: cellSize)
                }
            }
            
            Text("More")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
    
    private func dateFor(week: Int, day: Int) -> Date {
        let calendar = Calendar.current
        let now = Date()
        let startOfToday = calendar.startOfDay(for: now)
        
        // 現在の曜日を取得（日曜=1）
        let currentWeekday = calendar.component(.weekday, from: startOfToday)
        
        // 今週の日曜日を計算
        let daysFromSunday = currentWeekday - 1
        guard let startOfThisWeek = calendar.date(byAdding: .day, value: -daysFromSunday, to: startOfToday) else {
            return startOfToday
        }
        
        // 52週間前から計算
        let weeksAgo = columns - 1 - week
        guard let targetWeekStart = calendar.date(byAdding: .weekOfYear, value: -weeksAgo, to: startOfThisWeek) else {
            return startOfToday
        }
        
        // 曜日を追加
        guard let targetDate = calendar.date(byAdding: .day, value: day, to: targetWeekStart) else {
            return startOfToday
        }
        
        return calendar.startOfDay(for: targetDate)
    }
    
    private func colorFor(intensity: Int) -> Color {
        switch intensity {
        case 0:
            return Color(.systemGray5)
        case 1:
            return Color.green.opacity(0.25)
        case 2:
            return Color.green.opacity(0.5)
        case 3:
            return Color.green.opacity(0.75)
        default:
            return Color.green
        }
    }
}

#Preview {
    ContributionGraphView(
        contributions: MockData.shared.contributionData(for: MockData.shared.currentUser.id)
    )
    .padding()
    .preferredColorScheme(.dark)
}
