//
//  TransferTask.swift
//  SCP Client for macOS
//
//  Modèle pour suivre les transferts
//

import Foundation

enum TransferType {
    case upload
    case download
}

enum TransferStatus {
    case pending
    case inProgress
    case completed
    case failed
    case cancelled
}

class TransferTask: Identifiable, ObservableObject {
    let id = UUID()
    let type: TransferType
    let sourcePath: String
    let destinationPath: String
    let totalSize: UInt64

    @Published var status: TransferStatus = .pending
    @Published var transferredBytes: UInt64 = 0
    @Published var error: String?
    @Published var startTime: Date?
    @Published var endTime: Date?

    var progress: Double {
        guard totalSize > 0 else { return 0 }
        return Double(transferredBytes) / Double(totalSize)
    }

    var progressPercentage: String {
        String(format: "%.1f%%", progress * 100)
    }

    var transferSpeed: String? {
        guard let start = startTime, status == .inProgress else { return nil }
        let elapsed = Date().timeIntervalSince(start)
        guard elapsed > 0 else { return nil }

        let bytesPerSecond = Double(transferredBytes) / elapsed
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytesPerSecond)) + "/s"
    }

    var estimatedTimeRemaining: String? {
        guard let start = startTime,
              status == .inProgress,
              transferredBytes > 0 else { return nil }

        let elapsed = Date().timeIntervalSince(start)
        let bytesRemaining = totalSize - transferredBytes
        let bytesPerSecond = Double(transferredBytes) / elapsed

        guard bytesPerSecond > 0 else { return nil }

        let secondsRemaining = Double(bytesRemaining) / bytesPerSecond

        if secondsRemaining < 60 {
            return String(format: "%.0fs", secondsRemaining)
        } else if secondsRemaining < 3600 {
            return String(format: "%.0fm", secondsRemaining / 60)
        } else {
            return String(format: "%.1fh", secondsRemaining / 3600)
        }
    }

    init(type: TransferType, sourcePath: String, destinationPath: String, totalSize: UInt64) {
        self.type = type
        self.sourcePath = sourcePath
        self.destinationPath = destinationPath
        self.totalSize = totalSize
    }

    func updateProgress(transferred: UInt64, total: UInt64) {
        DispatchQueue.main.async {
            self.transferredBytes = transferred
            if self.status == .pending {
                self.status = .inProgress
                self.startTime = Date()
            }
        }
    }

    func complete() {
        DispatchQueue.main.async {
            self.status = .completed
            self.endTime = Date()
            self.transferredBytes = self.totalSize
        }
    }

    func fail(error: String) {
        DispatchQueue.main.async {
            self.status = .failed
            self.error = error
            self.endTime = Date()
        }
    }

    func cancel() {
        DispatchQueue.main.async {
            self.status = .cancelled
            self.endTime = Date()
        }
    }
}
