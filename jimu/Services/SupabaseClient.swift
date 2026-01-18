//
//  SupabaseClient.swift
//  jimu
//
//  Created by Jimu Team on 18/1/2026.
//

import Foundation
import Supabase

/// Singleton Supabase client configuration
/// Access via `SupabaseClient.shared`
final class SupabaseManager: @unchecked Sendable {
    
    // MARK: - Singleton
    static let shared = SupabaseManager()
    
    // MARK: - Client
    let client: SupabaseClient
    
    // MARK: - Configuration
    /// Replace with your actual Supabase project URL and anon key
    /// These should ideally come from environment variables or a config file
    private static let supabaseURL = URL(string: "https://YOUR_PROJECT_ID.supabase.co")!
    private static let supabaseAnonKey = "YOUR_ANON_KEY"
    
    // MARK: - Initialization
    private init() {
        client = SupabaseClient(
            supabaseURL: Self.supabaseURL,
            supabaseKey: Self.supabaseAnonKey,
            options: SupabaseClientOptions(
                db: .init(
                    encoder: Self.encoder,
                    decoder: Self.decoder
                ),
                auth: .init(
                    storage: KeychainAuthStorage()
                )
            )
        )
    }
    
    // MARK: - JSON Encoder/Decoder with snake_case conversion
    
    static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()
    
    static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
}

// MARK: - Keychain Auth Storage
/// Secure storage for auth tokens using Keychain
final class KeychainAuthStorage: AuthLocalStorage, @unchecked Sendable {
    private let service = "co.jimu.auth"
    
    func store(key: String, value: Data) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: value
        ]
        
        // Delete existing item first
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.unableToStore
        }
    }
    
    func retrieve(key: String) throws -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        switch status {
        case errSecSuccess:
            return result as? Data
        case errSecItemNotFound:
            return nil
        default:
            throw KeychainError.unableToRetrieve
        }
    }
    
    func remove(key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unableToRemove
        }
    }
    
    enum KeychainError: Error {
        case unableToStore
        case unableToRetrieve
        case unableToRemove
    }
}
// MARK: - Convenience Accessors
extension SupabaseManager {
    /// Creates a query builder for the specified table
    /// This is the primary method for database operations
    func from(_ table: String) -> PostgrestQueryBuilder {
        client.from(table)
    }
    
    /// Auth client for authentication
    var auth: AuthClient {
        client.auth
    }
    
    /// Storage client for file uploads
    var storage: SupabaseStorageClient {
        client.storage
    }
    
    /// Current authenticated user ID
    var currentUserId: UUID? {
        get async {
            do {
                return try await client.auth.session.user.id
            } catch {
                return nil
            }
        }
    }
}


