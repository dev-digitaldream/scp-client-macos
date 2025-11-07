//
//  SidebarView.swift
//  SCP Client for macOS
//
//  Sidebar avec connexions favorites
//

import SwiftUI

struct SidebarView: View {
    @EnvironmentObject var connectionManager: ConnectionManager
    @EnvironmentObject var connectionService: ConnectionService

    @Binding var showingConnectionSheet: Bool
    @State private var selectedConnection: Connection?
    @State private var editingConnection: Connection?

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Connexions")
                    .font(.headline)
                Spacer()
                Button(action: { showingConnectionSheet = true }) {
                    Image(systemName: "plus")
                }
                .buttonStyle(.borderless)
            }
            .padding()

            // Liste des connexions
            if connectionManager.savedConnections.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "tray")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text("Aucune connexion")
                        .foregroundColor(.secondary)
                    Button("Ajouter") {
                        showingConnectionSheet = true
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(connectionManager.savedConnections) { connection in
                    ConnectionRow(connection: connection)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedConnection = connection
                        }
                        .contextMenu {
                            Button("Modifier") {
                                editingConnection = connection
                            }
                            Divider()
                            Button("Supprimer", role: .destructive) {
                                connectionManager.deleteConnection(connection)
                            }
                        }
                }
                .listStyle(.sidebar)
            }
        }
        .sheet(item: $selectedConnection) { connection in
            PasswordPromptView(
                connection: connection,
                selectedConnection: $selectedConnection
            )
        }
        .sheet(item: $editingConnection) { connection in
            ConnectionFormView(connection: connection, isEditing: true)
        }
    }
}

struct ConnectionRow: View {
    let connection: Connection

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: connection.authType == .password ? "key" : "lock.shield")
                    .foregroundColor(.blue)
                Text(connection.name)
                    .font(.headline)
            }

            Text("\(connection.username)@\(connection.host)")
                .font(.caption)
                .foregroundColor(.secondary)

            if let lastUsed = connection.lastUsed {
                Text("Dernier accès: \(lastUsed, style: .relative)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// Prompt pour le password
struct PasswordPromptView: View {
    let connection: Connection
    @Binding var selectedConnection: Connection?

    @EnvironmentObject var connectionService: ConnectionService
    @EnvironmentObject var connectionManager: ConnectionManager

    @State private var password = ""
    @State private var isConnecting = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: "server.rack")
                    .font(.largeTitle)
                    .foregroundColor(.blue)

                VStack(alignment: .leading) {
                    Text(connection.name)
                        .font(.title2)
                        .bold()
                    Text("\(connection.username)@\(connection.host):\(connection.port)")
                        .foregroundColor(.secondary)
                    Text("Protocole: \(connection.protocol.rawValue)")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }

            Divider()

            if connection.authType == .password {
                SecureField("Mot de passe", text: $password)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit { connect() }
            } else {
                SecureField("Passphrase (optionnel)", text: $password)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit { connect() }
                Text("Clé privée: \(connection.privateKeyPath ?? "N/A")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            HStack {
                Button("Annuler") {
                    selectedConnection = nil
                }
                .keyboardShortcut(.escape)

                Spacer()

                Button("Connexion") {
                    connect()
                }
                .keyboardShortcut(.return)
                .disabled(isConnecting || (connection.authType == .password && password.isEmpty))
            }

            if isConnecting {
                ProgressView("Connexion en cours...")
            }
        }
        .padding(30)
        .frame(width: 450)
    }

    private func connect() {
        isConnecting = true
        errorMessage = nil

        Task {
            do {
                if connection.authType == .password {
                    try await connectionService.connect(to: connection, password: password)
                } else {
                    try await connectionService.connectWithKey(
                        to: connection,
                        passphrase: password.isEmpty ? nil : password
                    )
                }

                await MainActor.run {
                    connectionManager.markConnectionUsed(connection)
                    selectedConnection = nil
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isConnecting = false
                }
            }
        }
    }
}
