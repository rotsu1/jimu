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

/// トレーニング器具
enum ExerciseTool: String, CaseIterable, Identifiable, Codable {
    case barbell = "バーベル"
    case dumbbell = "ダンベル"
    case machine = "マシン"
    case bodyweight = "自重"
    case cable = "ケーブル"
    case kettlebell = "ケトルベル"
    case band = "バンド"
    case smithMachine = "スミスマシン"
    case other = "その他"
    
    var id: String { rawValue }
    
    var iconName: String {
        switch self {
        case .barbell: return "dumbbell" // SF Symbols doesn't have a perfect barbell, using dumbbell or similar
        case .dumbbell: return "dumbbell.fill"
        case .machine: return "gearshape.2"
        case .bodyweight: return "figure.stand"
        case .cable: return "arrow.triangle.2.circlepath"
        case .kettlebell: return "scalemass.fill"
        case .band: return "scribble.variable"
        case .smithMachine: return "building.columns"
        case .other: return "questionmark.circle"
        }
    }
}

/// エクササイズ（種目）モデル
struct Exercise: Identifiable, Hashable, Codable {
    let id: UUID
    let nameJa: String
    var muscleGroups: [MuscleGroup]
    var tools: [ExerciseTool]
    let gifUrl: String?
    let customImageData: Data?
    
    // 互換性のための計算プロパティ
    var muscleGroup: MuscleGroup {
        return muscleGroups.first ?? .chest
    }
    
    init(
        id: UUID = UUID(),
        nameJa: String,
        muscleGroups: [MuscleGroup],
        tools: [ExerciseTool] = [],
        gifUrl: String? = nil,
        customImageData: Data? = nil
    ) {
        self.id = id
        self.nameJa = nameJa
        self.muscleGroups = muscleGroups
        self.tools = tools
        self.gifUrl = gifUrl
        self.customImageData = customImageData
    }
    
    // 旧イニシャライザの互換性維持
    init(
        id: UUID = UUID(),
        nameJa: String,
        muscleGroup: MuscleGroup,
        gifUrl: String? = nil
    ) {
        self.id = id
        self.nameJa = nameJa
        self.muscleGroups = [muscleGroup]
        self.tools = []
        self.gifUrl = gifUrl
        self.customImageData = nil
    }
}
