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
    var location: String
    var birthDate: Date
    var isPrivate: Bool
    var isPremium: Bool
    var avatarUrl: String?
    
    init(
        id: UUID = UUID(),
        username: String,
        bio: String = "",
        location: String = "",
        birthDate: Date = Date(),
        isPrivate: Bool = false,
        isPremium: Bool = false,
        avatarUrl: String? = nil
    ) {
        self.id = id
        self.username = username
        self.bio = bio
        self.location = location
        self.birthDate = birthDate
        self.isPrivate = isPrivate
        self.isPremium = isPremium
        self.avatarUrl = avatarUrl
    }
}
