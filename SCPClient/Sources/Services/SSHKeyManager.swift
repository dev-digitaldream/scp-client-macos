//
//  SSHKeyManager.swift
//  SCP Client for macOS
//
//  Gestionnaire automatique des clés SSH
//

import Foundation

class SSHKeyManager {
    
    // MARK: - Properties
    
    private let knownHostsPath: String
    private var acceptedKeysCache: Set<String> = []
    private let userDefaults = UserDefaults.standard
    private let cacheKey = "SSHAcceptedKeys"
    
    // MARK: - Initialization
    
    init() {
        let homeDir = FileManager.default.homeDirectoryForCurrentUser.path
        self.knownHostsPath = "\(homeDir)/.ssh/known_hosts"
        loadAcceptedKeysFromCache()
    }
    
    // MARK: - Public Methods
    
    /// Prépare une connexion en gérant automatiquement les clés SSH
    func prepareConnection(for host: String) throws {
        print("🔑 Préparation de la connexion pour \(host)")
        
        // 1. Vérifier si nous avons déjà accepté cette clé
        if hasAcceptedKey(for: host) {
            print("✅ Clé déjà acceptée pour \(host)")
            return
        }
        
        // 2. Nettoyer l'ancienne clé si elle existe
        try cleanKnownHosts(for: host)
        
        // 3. Marquer comme prêt pour acceptation automatique
        print("🔄 Nettoyage des clés pour \(host) - prêt pour nouvelle clé")
    }
    
    /// Accepte automatiquement une clé SSH pour un hôte
    func acceptKey(for host: String) {
        print("✅ Acceptation automatique de la clé pour \(host)")
        acceptedKeysCache.insert(host)
        saveAcceptedKeysToCache()
    }
    
    /// Vérifie si une clé a déjà été acceptée pour un hôte
    func hasAcceptedKey(for host: String) -> Bool {
        return acceptedKeysCache.contains(host)
    }
    
    /// Retourne le nombre de clés acceptées
    var acceptedKeysCount: Int {
        return acceptedKeysCache.count
    }
    
    /// Nettoie toutes les clés (pour debugging ou réinitialisation)
    func resetAllKeys() throws {
        print("🗑️ Réinitialisation de toutes les clés SSH")
        acceptedKeysCache.removeAll()
        saveAcceptedKeysToCache()
        
        // Nettoyer le fichier known_hosts
        if FileManager.default.fileExists(atPath: knownHostsPath) {
            try FileManager.default.removeItem(atPath: knownHostsPath)
            print("✅ Fichier known_hosts nettoyé")
        }
    }
    
    /// Valide une connexion SSH avec gestion automatique des clés
    func validateSSHConnection(host: String, port: Int, username: String, command: String = "echo 'SSH connection test'") throws -> String {
        print("🔐 Validation de la connexion SSH pour \(username)@\(host):\(port)")
        
        // Préparer la connexion
        try prepareConnection(for: host)
        
        // Exécuter une commande test avec gestion automatique des clés
        let process = Process()
        let pipe = Pipe()
        let inputPipe = Pipe()
        
        process.executableURL = URL(fileURLWithPath: "/usr/bin/ssh")
        process.arguments = [
            "-o", "StrictHostKeyChecking=ask",
            "-o", "UserKnownHostsFile=\(knownHostsPath)",
            "-o", "ConnectTimeout=10",
            "-o", "BatchMode=no",
            "-p", "\(port)",
            "\(username)@\(host)",
            command
        ]
        process.standardOutput = pipe
        process.standardError = pipe
        process.standardInput = inputPipe
        
        // Envoyer automatiquement "yes" pour accepter la clé
        DispatchQueue.global().async {
            if let data = "yes\n".data(using: .utf8) {
                inputPipe.fileHandleForWriting.write(data)
                inputPipe.fileHandleForWriting.closeFile()
            }
        }
        
        try process.run()
        process.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""
        
        // Si la connexion réussit, accepter la clé
        if process.terminationStatus == 0 {
            acceptKey(for: host)
            print("✅ Connexion SSH validée pour \(host)")
        } else {
            print("❌ Échec de la connexion SSH pour \(host): \(output)")
        }
        
        return output
    }
    
    // MARK: - Private Methods
    
    /// Charge les clés acceptées depuis le cache
    private func loadAcceptedKeysFromCache() {
        if let cachedKeys = userDefaults.stringArray(forKey: cacheKey) {
            acceptedKeysCache = Set(cachedKeys)
            print("📋 Chargé \(acceptedKeysCache.count) clés depuis le cache")
        }
    }
    
    /// Sauvegarde les clés acceptées dans le cache
    private func saveAcceptedKeysToCache() {
        userDefaults.set(Array(acceptedKeysCache), forKey: cacheKey)
        print("💾 Sauvegardé \(acceptedKeysCache.count) clés dans le cache")
    }
    
    /// Nettoie les clés known_hosts pour un hôte spécifique
    private func cleanKnownHosts(for host: String) throws {
        let process = Process()
        let pipe = Pipe()
        
        process.executableURL = URL(fileURLWithPath: "/usr/bin/ssh-keygen")
        process.arguments = [
            "-R", host,
            "-f", knownHostsPath
        ]
        process.standardOutput = pipe
        process.standardError = pipe
        
        try process.run()
        process.waitUntilExit()
        
        // Ignorer les erreurs si l'hôte n'existe pas dans known_hosts
        if process.terminationStatus != 0 {
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""
            if !output.contains("not found") {
                print("⚠️ Warning: Échec du nettoyage known_hosts: \(output)")
            }
        }
    }
}
