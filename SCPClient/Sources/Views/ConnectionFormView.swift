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

    @State private var name = ""
    @State private var host = ""
    @State private var port = 22
    @State private var username = ""
    @State private var authType: Connection.AuthType = .password
    @State private var privateKeyPath = ""

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Nouvelle connexion")
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

                Button("Enregistrer") {
                    saveConnection()
                }
                .keyboardShortcut(.return)
                .disabled(!isValid)
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .frame(width: 500, height: 500)
    }

    private var isValid: Bool {
        !name.isEmpty && !host.isEmpty && !username.isEmpty &&
        (authType == .password || !privateKeyPath.isEmpty)
    }

    private func saveConnection() {
        let connection = Connection(
            name: name,
            host: host,
            port: port,
            username: username,
            authType: authType,
            privateKeyPath: authType == .privateKey ? privateKeyPath : nil
        )

        connectionManager.addConnection(connection)
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
