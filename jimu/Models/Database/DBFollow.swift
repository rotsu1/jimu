//
//  DBFollow.swift
//  jimu
//
//  Created by Jimu Team on 18/1/2026.
//

import Foundation

/// Database model for `follows` table
/// Manages the social graph (follower/following relationships)
struct DBFollow: Codable, Identifiable, Sendable {
    // Composite ID for Identifiable conformance
    var id: String { "\(followerId)-\(followingId)" }
    
    let followerId: UUID
    let followingId: UUID
    var status: FollowStatus
    
    // Timestamps
    let createdAt: Date
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case followerId = "follower_id"
        case followingId = "following_id"
        case status
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Insert Payload
extension DBFollow {
    struct InsertPayload: Codable, Sendable {
        let followerId: UUID
        let followingId: UUID
        var status: FollowStatus
        
        enum CodingKeys: String, CodingKey {
            case followerId = "follower_id"
            case followingId = "following_id"
            case status
        }
    }
}

