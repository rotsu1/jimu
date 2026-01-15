//
//  Workout.swift
//  jimu
//
//  Created by Jimu Team on 14/1/2026.
//

import Foundation

/// ワークアウトの状態
enum WorkoutStatus: String, CaseIterable {
    case ongoing = "進行中"
    case completed = "完了"
}

/// ワークアウト（トレーニングセッション）モデル
struct Workout: Identifiable, Hashable {
    let id: UUID
    let userId: UUID
    var startedAt: Date
    var endedAt: Date?
    var note: String
    var status: WorkoutStatus
    
    init(
        id: UUID = UUID(),
        userId: UUID,
        startedAt: Date = Date(),
        endedAt: Date? = nil,
        note: String = "",
        status: WorkoutStatus = .ongoing
    ) {
        self.id = id
        self.userId = userId
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.note = note
        self.status = status
    }
    
    /// トレーニング時間（分）
    var durationMinutes: Int {
        let end = endedAt ?? Date()
        return Int(end.timeIntervalSince(startedAt) / 60)
    }
    
    /// フォーマットされた日付文字列
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M月d日(E)"
        return formatter.string(from: startedAt)
    }
    
    /// フォーマットされた時間文字列
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: startedAt)
    }
}
