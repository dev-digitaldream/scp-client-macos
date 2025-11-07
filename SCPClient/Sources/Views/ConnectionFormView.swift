//
//  ConnectionFormView.swift
//  SCP Client for macOS
//
//  Formulaire pour créer/éditer une connexion
//

import SwiftUI

struct ConnectionFormView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var connectionManager: ConnectionManager

    let connection: Connection?
    let isEditing: Bool

    @State private var name = ""
    @State private var host = ""
    @State private var port = 22
    @State private var username = ""
    @State private var protocolType: Connection.ProtocolType = .sftp
    @State private var authType: Connection.AuthType = .password
    @State private var privateKeyPath = ""

    init(connection: Connection? = nil, isEditing: Bool = false) {
        self.connection = connection
        self.isEditing = isEditing
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(isEditing ? "Modifier la connexion" : "Nouvelle connexion")
                    .font(.title2)
                    .bold()

                Spacer()

                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.borderless)
            }
            .padding()

            Divider()

            // Formulaire
            Form {
                Section("Général") {
                    TextField("Nom", text: $name)
                        .help("Nom de cette connexion (ex: Serveur Production)")

                    TextField("Hôte", text: $host)
                        .help("Adresse IP ou nom de domaine")

                    TextField("Port", value: $port, format: .number)
                        .help("Port SSH (par défaut: 22)")

                    TextField("Nom d'utilisateur", text: $username)

                    Picker("Protocole", selection: $protocolType) {
                        Text("SCP").tag(Connection.ProtocolType.scp)
                        Text("SFTP").tag(Connection.ProtocolType.sftp)
                    }
                    .pickerStyle(.segmented)
                }

                Section("Authentification") {
                    Picker("Type", selection: $authType) {
                        Text("Mot de passe").tag(Connection.AuthType.password)
                        Text("Clé privée").tag(Connection.AuthType.privateKey)
                    }
                    .pickerStyle(.segmented)

                    if authType == .privateKey {
                        HStack {
                            TextField("Chemin de la clé privée", text: $privateKeyPath)
                            Button("Parcourir") {
                                selectPrivateKey()
                            }
                        }
                        .help("Chemin vers votre clé privée SSH (ex: ~/.ssh/id_rsa)")

                        Text("La passphrase sera demandée lors de la connexion si nécessaire")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("Le mot de passe sera demandé lors de la connexion")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .formStyle(.grouped)
            .scrollContentBackground(.hidden)

            Divider()

            // Actions
            HStack {
                Button("Annuler") {
                    dismiss()
                }
                .keyboardShortcut(.escape)

                Spacer()

                Button(isEditing ? "Mettre à jour" : "Enregistrer") {
                    saveConnection()
                }
                .keyboardShortcut(.return)
                .disabled(!isValid)
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .frame(width: 500, height: 500)
        .onAppear {
            if let connection = connection, isEditing {
                // Charger les données de la connexion existante
                name = connection.name
                host = connection.host
                port = connection.port
                username = connection.username
                protocolType = connection.protocol
                authType = connection.authType
                privateKeyPath = connection.privateKeyPath ?? ""
            }
        }
    }

    private var isValid: Bool {
        !name.isEmpty && !host.isEmpty && !username.isEmpty &&
        (authType == .password || !privateKeyPath.isEmpty)
    }

    private func saveConnection() {
        if isEditing, let connection = connection {
            // Mise à jour de la connexion existante
            var updatedConnection = connection
            updatedConnection.name = name
            updatedConnection.host = host
            updatedConnection.port = port
            updatedConnection.username = username
            updatedConnection.authType = authType
            updatedConnection.privateKeyPath = authType == .privateKey ? privateKeyPath : nil
            updatedConnection.protocol = protocolType
            
            connectionManager.updateConnection(updatedConnection)
        } else {
            // Création d'une nouvelle connexion
            let newConnection = Connection(
                name: name,
                host: host,
                port: port,
                username: username,
                authType: authType,
                privateKeyPath: authType == .privateKey ? privateKeyPath : nil,
                protocol: protocolType
            )
            
            connectionManager.addConnection(newConnection)
        }
        dismiss()
    }

    private func selectPrivateKey() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.message = "Sélectionnez votre clé privée SSH"

        // Démarrer dans ~/.ssh si existe
        if let homeDir = FileManager.default.homeDirectoryForCurrentUser.path as String? {
            let sshDir = (homeDir as NSString).appendingPathComponent(".ssh")
            panel.directoryURL = URL(fileURLWithPath: sshDir)
        }

        if panel.runModal() == .OK, let url = panel.url {
            privateKeyPath = url.path
        }
    }
}
