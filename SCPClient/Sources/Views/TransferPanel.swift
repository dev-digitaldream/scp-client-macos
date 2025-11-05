//
//  TransferPanel.swift
//  SCP Client for macOS
//
//  Panneau de suivi des transferts
//

import SwiftUI

struct TransferPanel: View {
    @EnvironmentObject var connectionService: ConnectionService

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "arrow.up.arrow.down.circle")
                Text("Transferts")
                    .font(.headline)

                Spacer()

                Text("\(activeTransfersCount) en cours")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Button(action: clearCompleted) {
                    Image(systemName: "trash")
                }
                .buttonStyle(.borderless)
                .help("Effacer les transferts terminés")
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(NSColor.controlBackgroundColor))

            Divider()

            // Liste des transferts
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(connectionService.transferTasks) { task in
                        TransferRow(task: task)
                        Divider()
                    }
                }
            }
        }
    }

    private var activeTransfersCount: Int {
        connectionService.transferTasks.filter {
            $0.status == .inProgress || $0.status == .pending
        }.count
    }

    private func clearCompleted() {
        connectionService.transferTasks.removeAll {
            $0.status == .completed || $0.status == .failed || $0.status == .cancelled
        }
    }
}

struct TransferRow: View {
    @ObservedObject var task: TransferTask

    var body: some View {
        HStack(spacing: 12) {
            // Icône
            Image(systemName: iconName)
                .foregroundColor(iconColor)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                // Nom du fichier
                Text((task.sourcePath as NSString).lastPathComponent)
                    .font(.body)
                    .lineLimit(1)

                // Chemin
                Text(task.type == .upload ? "→ \(task.destinationPath)" : "← \(task.sourcePath)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)

                // Barre de progression
                if task.status == .inProgress || task.status == .pending {
                    ProgressView(value: task.progress)
                        .progressViewStyle(.linear)
                }

                // Informations
                HStack(spacing: 12) {
                    Text(task.progressPercentage)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    if let speed = task.transferSpeed {
                        Text(speed)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    if let eta = task.estimatedTimeRemaining {
                        Text("Reste: \(eta)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    if task.status == .failed, let error = task.error {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }

            Spacer()

            // Statut
            statusBadge
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    private var iconName: String {
        switch task.type {
        case .upload:
            return "arrow.up.circle.fill"
        case .download:
            return "arrow.down.circle.fill"
        }
    }

    private var iconColor: Color {
        switch task.status {
        case .pending:
            return .gray
        case .inProgress:
            return .blue
        case .completed:
            return .green
        case .failed:
            return .red
        case .cancelled:
            return .orange
        }
    }

    @ViewBuilder
    private var statusBadge: some View {
        switch task.status {
        case .pending:
            Image(systemName: "clock")
                .foregroundColor(.gray)
        case .inProgress:
            ProgressView()
                .controlSize(.small)
        case .completed:
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
        case .failed:
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.red)
        case .cancelled:
            Image(systemName: "slash.circle.fill")
                .foregroundColor(.orange)
        }
    }
}
