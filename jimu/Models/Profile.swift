//
//  Profile.swift
//  jimu
//
//  Created by Jimu Team on 14/1/2026.
//

import Foundation

/// ユーザープロフィールモデル
struct Profile: Identifiable, Hashable {
    let id: UUID
    var username: String
    var bio: String
    var isPrivate: Bool
    var isPremium: Bool
    var avatarUrl: String?
    
    init(
        id: UUID = UUID(),
        username: String,
        bio: String = "",
        isPrivate: Bool = false,
        isPremium: Bool = false,
        avatarUrl: String? = nil
    ) {
        self.id = id
        self.username = username
        self.bio = bio
        self.isPrivate = isPrivate
        self.isPremium = isPremium
        self.avatarUrl = avatarUrl
    }
}
