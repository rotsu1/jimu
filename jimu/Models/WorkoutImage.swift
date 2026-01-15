//
//  WorkoutImage.swift
//  jimu
//
//  Created by Jimu Team on 14/1/2026.
//

import Foundation

/// ワークアウト画像モデル
struct WorkoutImage: Identifiable, Hashable {
    let id: UUID
    let workoutId: UUID
    let imageUrl: String
    
    init(
        id: UUID = UUID(),
        workoutId: UUID,
        imageUrl: String
    ) {
        self.id = id
        self.workoutId = workoutId
        self.imageUrl = imageUrl
    }
}
