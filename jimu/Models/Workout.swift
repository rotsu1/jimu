//
//  Workout.swift
//  jimu
//
//  Created by Jimu Team on 14/1/2026.
//

import Foundation

/// ワークアウトの状態
enum WorkoutStatus: String, CaseIterable, Codable {
    case ongoing = "進行中"
    case completed = "完了"
}

/// ワークアウト（トレーニングセッション）モデル
/// This is the app-level model for UI consumption
struct Workout: Identifiable, Hashable, Codable {
    let id: UUID
    let userId: UUID
    var startedAt: Date
    var endedAt: Date?
    var name: String?
    var note: String
    var status: WorkoutStatus
    var visibility: VisibilityType?
    var durationSeconds: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case startedAt = "started_at"
        case endedAt = "ended_at"
        case name
        case note = "comment"
        case status
        case visibility
        case durationSeconds = "duration_seconds"
    }
    
    init(
        id: UUID = UUID(),
        userId: UUID,
        startedAt: Date = Date(),
        endedAt: Date? = nil,
        name: String? = nil,
        note: String = "",
        status: WorkoutStatus = .ongoing,
        visibility: VisibilityType? = .public,
        durationSeconds: Int? = nil
    ) {
        self.id = id
        self.userId = userId
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.name = name
        self.note = note
        self.status = status
        self.visibility = visibility
        self.durationSeconds = durationSeconds
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
