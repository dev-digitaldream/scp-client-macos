//
//  Connection.swift
//  SCP Client for macOS
//
//  Modèles de données pour les connexions
//

import Foundation

struct Connection: Identifiable, Codable {
    let id: UUID
    var name: String
    var host: String
    var port: Int
    var username: String
    var authType: AuthType
    var privateKeyPath: String?
    var createdAt: Date
    var lastUsed: Date?

    enum AuthType: String, Codable {
        case password
        case privateKey
    }

    init(id: UUID = UUID(),
         name: String,
         host: String,
         port: Int = 22,
         username: String,
         authType: AuthType = .password,
         privateKeyPath: String? = nil) {
        self.id = id
        self.name = name
        self.host = host
        self.port = port
        self.username = username
        self.authType = authType
        self.privateKeyPath = privateKeyPath
        self.createdAt = Date()
        self.lastUsed = nil
    }

    mutating func updateLastUsed() {
        self.lastUsed = Date()
    }
}

// Extension pour les favoris
extension Connection {
    static let examples: [Connection] = [
        Connection(name: "Dev Server", host: "dev.example.com", username: "developer"),
        Connection(name: "Production", host: "prod.example.com", username: "admin"),
        Connection(name: "Backup Server", host: "backup.example.com", port: 2222, username: "backup")
    ]
}
