//
//  ConnectionService.swift
//  SCP Client for macOS
//
//  Service pour gérer les connexions SSH/SCP
//

import Foundation
import Combine

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
        var error: NSError?

        let success = bridge.connect(
            toHost: connection.host,
            port: connection.port,
            username: connection.username,
            password: password,
            error: &error
        )

        if success {
            await MainActor.run {
                self.isConnected = true
                self.currentConnection = connection
                self.errorMessage = nil
            }
            try await loadDirectory("/")
        } else {
            throw error ?? NSError(domain: "ConnectionError", code: -1,
                                  userInfo: [NSLocalizedDescriptionKey: "Connection failed"])
        }
    }

    // Connexion avec clé privée
    func connectWithKey(to connection: Connection, passphrase: String? = nil) async throws {
        guard let keyPath = connection.privateKeyPath else {
            throw NSError(domain: "ConnectionError", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "No private key path specified"])
        }

        var error: NSError?

        let success = bridge.connect(
            toHost: connection.host,
            port: connection.port,
            username: connection.username,
            privateKeyPath: keyPath,
            passphrase: passphrase,
            error: &error
        )

        if success {
            await MainActor.run {
                self.isConnected = true
                self.currentConnection = connection
                self.errorMessage = nil
            }
            try await loadDirectory("/")
        } else {
            throw error ?? NSError(domain: "ConnectionError", code: -1,
                                  userInfo: [NSLocalizedDescriptionKey: "Connection failed"])
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

        var error: NSError?
        guard let files = bridge.listDirectory(atPath: path, error: &error) else {
            throw error ?? NSError(domain: "ConnectionError", code: -1,
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
                var error: NSError?

                let success = self.bridge.uploadFile(
                    from: localPath,
                    to: remotePath,
                    progress: { transferred, total in
                        task.updateProgress(transferred: transferred, total: total)
                    },
                    error: &error
                )

                if success {
                    task.complete()
                    continuation.resume()
                } else {
                    let errorMsg = error?.localizedDescription ?? "Upload failed"
                    task.fail(error: errorMsg)
                    continuation.resume(throwing: error ?? NSError(
                        domain: "TransferError",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: errorMsg]
                    ))
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
                var error: NSError?

                let success = self.bridge.downloadFile(
                    from: remotePath,
                    to: localPath,
                    progress: { transferred, total in
                        task.updateProgress(transferred: transferred, total: total)
                    },
                    error: &error
                )

                if success {
                    task.complete()
                    continuation.resume()
                } else {
                    let errorMsg = error?.localizedDescription ?? "Download failed"
                    task.fail(error: errorMsg)
                    continuation.resume(throwing: error ?? NSError(
                        domain: "TransferError",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: errorMsg]
                    ))
                }
            }
        }
    }

    // Créer un dossier
    func createDirectory(at path: String) async throws {
        var error: NSError?
        let success = bridge.createDirectory(atPath: path, error: &error)

        if !success {
            throw error ?? NSError(domain: "ConnectionError", code: -1,
                                  userInfo: [NSLocalizedDescriptionKey: "Failed to create directory"])
        }

        try await loadDirectory(currentDirectory)
    }

    // Supprimer un fichier
    func deleteFile(at path: String) async throws {
        var error: NSError?
        let success = bridge.deleteFile(atPath: path, error: &error)

        if !success {
            throw error ?? NSError(domain: "ConnectionError", code: -1,
                                  userInfo: [NSLocalizedDescriptionKey: "Failed to delete file"])
        }

        try await loadDirectory(currentDirectory)
    }

    // Supprimer un dossier
    func deleteDirectory(at path: String) async throws {
        var error: NSError?
        let success = bridge.deleteDirectory(atPath: path, error: &error)

        if !success {
            throw error ?? NSError(domain: "ConnectionError", code: -1,
                                  userInfo: [NSLocalizedDescriptionKey: "Failed to delete directory"])
        }

        try await loadDirectory(currentDirectory)
    }
}
