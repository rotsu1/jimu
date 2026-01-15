//
//  WorkoutSet.swift
//  jimu
//
//  Created by Jimu Team on 14/1/2026.
//

import Foundation

/// ワークアウトセット（1セット分の記録）モデル
struct WorkoutSet: Identifiable, Hashable {
    let id: UUID
    let workoutId: UUID
    let exerciseId: UUID
    var weight: Double
    var reps: Int
    var setNumber: Int
    var isCompleted: Bool
    
    init(
        id: UUID = UUID(),
        workoutId: UUID,
        exerciseId: UUID,
        weight: Double = 0,
        reps: Int = 0,
        setNumber: Int = 1,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.workoutId = workoutId
        self.exerciseId = exerciseId
        self.weight = weight
        self.reps = reps
        self.setNumber = setNumber
        self.isCompleted = isCompleted
    }
    
    /// フォーマットされた表示文字列（例: "60kg x 10回"）
    var formattedString: String {
        if weight > 0 {
            return "\(weight.formatted())kg × \(reps)回"
        } else {
            return "\(reps)回"
        }
    }
}
