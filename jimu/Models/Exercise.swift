//
//  Exercise.swift
//  jimu
//
//  Created by Jimu Team on 14/1/2026.
//

import Foundation

/// 筋肉グループ
enum MuscleGroup: String, CaseIterable, Identifiable, Codable {
    case chest = "胸"
    case back = "背中"
    case legs = "脚"
    case shoulders = "肩"
    case arms = "腕"
    case abs = "腹筋"
    case cardio = "有酸素"
    
    var id: String { rawValue }
    
    /// SF Symbol アイコン名
    var iconName: String {
        switch self {
        case .chest: return "figure.strengthtraining.traditional"
        case .back: return "figure.rowing"
        case .legs: return "figure.run"
        case .shoulders: return "figure.boxing"
        case .arms: return "figure.wrestling"
        case .abs: return "figure.core.training"
        case .cardio: return "heart.circle.fill"
        }
    }
}

/// エクササイズ（種目）モデル
struct Exercise: Identifiable, Hashable, Codable {
    let id: UUID
    let nameJa: String
    let muscleGroup: MuscleGroup
    let gifUrl: String?
    
    init(
        id: UUID = UUID(),
        nameJa: String,
        muscleGroup: MuscleGroup,
        gifUrl: String? = nil
    ) {
        self.id = id
        self.nameJa = nameJa
        self.muscleGroup = muscleGroup
        self.gifUrl = gifUrl
    }
}
