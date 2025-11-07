//
//  ConnectionService.swift
//  SCP Client for macOS
//
//  Service pour gérer les connexions SSH/SCP
//

import Foundation
import Combine
import SCPClientBridge

class ConnectionService: ObservableObject {
    private let bridge = SCPSessionBridge()

    @Published var isConnected = false
    @Published var currentConnection: Connection?
    @Published var currentDirectory = "/"
    @Published var remoteFiles: [RemoteFile] = []
    @Published var transferTasks: [TransferTask] = []
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()

    // Connexion avec password
    func connect(to connection: Connection, password: String) async throws {
        do {
            try bridge.connect(
                toHost: connection.host,
                port: connection.port,
                username: connection.username,
                password: password
            )
            
            await MainActor.run {
                self.isConnected = true
                self.currentConnection = connection
                self.errorMessage = nil
            }
            try await loadDirectory("/")
        } catch {
            throw NSError(domain: "ConnectionError", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "Failed to connect: \(error.localizedDescription)"])
        }
    }

    // Connexion avec clé privée
    func connectWithKey(to connection: Connection, passphrase: String? = nil) async throws {
        guard let keyPath = connection.privateKeyPath else {
            throw NSError(domain: "ConnectionError", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "No private key path specified"])
        }

        do {
            try bridge.connect(
                toHost: connection.host,
                port: connection.port,
                username: connection.username,
                privateKeyPath: keyPath,
                passphrase: passphrase
            )
            
            await MainActor.run {
                self.isConnected = true
                self.currentConnection = connection
                self.errorMessage = nil
            }
            try await loadDirectory("/")
        } catch {
            throw NSError(domain: "ConnectionError", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "Failed to connect with key: \(error.localizedDescription)"])
        }
    }

    func disconnect() {
        bridge.disconnect()
        isConnected = false
        currentConnection = nil
        currentDirectory = "/"
        remoteFiles = []
    }

    // Charger le contenu d'un répertoire
    func loadDirectory(_ path: String) async throws {
        guard isConnected else {
            throw NSError(domain: "ConnectionError", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "Not connected"])
        }

        guard let files = try? bridge.listDirectory(atPath: path) else {
            throw NSError(domain: "ConnectionError", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "Failed to list directory"])
        }

        let remoteFiles = files.map { RemoteFile(from: $0) }

        await MainActor.run {
            self.currentDirectory = path
            self.remoteFiles = remoteFiles.sorted { file1, file2 in
                // Dossiers d'abord, puis tri alphabétique
                if file1.isDirectory != file2.isDirectory {
                    return file1.isDirectory
                }
                return file1.name.localizedCaseInsensitiveCompare(file2.name) == .orderedAscending
            }
        }
    }

    func changeDirectory(to path: String) async throws {
        try await loadDirectory(path)
    }

    func navigateUp() async throws {
        let parentPath = (currentDirectory as NSString).deletingLastPathComponent
        if parentPath.isEmpty {
            try await changeDirectory(to: "/")
        } else {
            try await changeDirectory(to: parentPath)
        }
    }

    // Upload fichier
    func uploadFile(from localPath: String, to remotePath: String) async throws {
        guard isConnected else {
            throw NSError(domain: "ConnectionError", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "Not connected"])
        }

        // Obtenir la taille du fichier
        let attributes = try FileManager.default.attributesOfItem(atPath: localPath)
        let fileSize = attributes[.size] as? UInt64 ?? 0

        let task = TransferTask(
            type: .upload,
            sourcePath: localPath,
            destinationPath: remotePath,
            totalSize: fileSize
        )

        await MainActor.run {
            self.transferTasks.append(task)
        }

        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try self.bridge.uploadFile(
                        from: localPath,
                        to: remotePath,
                        progress: { transferred, total in
                            task.updateProgress(transferred: transferred, total: total)
                        }
                    )
                    task.complete()
                    continuation.resume()
                } catch {
                    let errorMsg = error.localizedDescription
                    task.fail(error: errorMsg)
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    // Download fichier
    func downloadFile(from remotePath: String, to localPath: String, size: UInt64) async throws {
        guard isConnected else {
            throw NSError(domain: "ConnectionError", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "Not connected"])
        }

        let task = TransferTask(
            type: .download,
            sourcePath: remotePath,
            destinationPath: localPath,
            totalSize: size
        )

        await MainActor.run {
            self.transferTasks.append(task)
        }

        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try self.bridge.downloadFile(
                        from: remotePath,
                        to: localPath,
                        progress: { transferred, total in
                            task.updateProgress(transferred: transferred, total: total)
                        }
                    )
                    task.complete()
                    continuation.resume()
                } catch {
                    let errorMsg = error.localizedDescription
                    task.fail(error: errorMsg)
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    // Créer un dossier
    func createDirectory(at path: String) async throws {
        do {
            try bridge.createDirectory(atPath: path)
        } catch {
            throw NSError(domain: "ConnectionError", code: -1,
                                  userInfo: [NSLocalizedDescriptionKey: "Failed to create directory"])
        }

        try await loadDirectory(currentDirectory)
    }

    // Supprimer un fichier
    func deleteFile(at path: String) async throws {
        do {
            try bridge.deleteFile(atPath: path)
        } catch {
            throw NSError(domain: "ConnectionError", code: -1,
                                  userInfo: [NSLocalizedDescriptionKey: "Failed to delete file"])
        }

        try await loadDirectory(currentDirectory)
    }

    // Supprimer un dossier
    func deleteDirectory(at path: String) async throws {
        do {
            try bridge.deleteDirectory(atPath: path)
        } catch {
            throw NSError(domain: "ConnectionError", code: -1,
                                  userInfo: [NSLocalizedDescriptionKey: "Failed to delete directory"])
        }

        try await loadDirectory(currentDirectory)
    }
    
    // Exécuter une commande SSH sur le serveur distant
    func executeCommand(_ command: String) async throws -> String {
        guard isConnected else {
            throw NSError(domain: "ConnectionError", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "Not connected"])
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let output = self.bridge.executeCommandSimple(command)
                continuation.resume(returning: output)
            }
        }
    }
}
