//
//  TerminalView.swift
//  SCP Client for macOS
//
//  Vue terminal SSH intégrée
//

import SwiftUI

struct TerminalView: View {
    @EnvironmentObject var connectionService: ConnectionService

    @State private var commandInput = ""
    @State private var commandHistory: [TerminalEntry] = []
    @State private var isExecuting = false
    @FocusState private var isInputFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "terminal")
                    .foregroundColor(.green)
                Text("Terminal SSH")
                    .font(.headline)

                Spacer()

                if let connection = connectionService.currentConnection {
                    Text("\(connection.username)@\(connection.host):\(connectionService.currentDirectory)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Button(action: clearHistory) {
                    Image(systemName: "trash")
                }
                .buttonStyle(.borderless)
                .help("Effacer l'historique")
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))

            Divider()

            // Historique des commandes
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(commandHistory) { entry in
                            VStack(alignment: .leading, spacing: 4) {
                                // Commande
                                HStack(spacing: 6) {
                                    Text("$")
                                        .foregroundColor(.green)
                                        .fontWeight(.bold)
                                    Text(entry.command)
                                        .foregroundColor(.primary)
                                }
                                .font(.system(.body, design: .monospaced))

                                // Output
                                if !entry.output.isEmpty {
                                    Text(entry.output)
                                        .font(.system(.body, design: .monospaced))
                                        .foregroundColor(entry.isError ? .red : .secondary)
                                        .textSelection(.enabled)
                                        .padding(.leading, 20)
                                }
                            }
                            .padding(.vertical, 4)
                            .id(entry.id)
                        }

                        if isExecuting {
                            HStack(spacing: 6) {
                                ProgressView()
                                    .scaleEffect(0.7)
                                Text("Exécution en cours...")
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .onChange(of: commandHistory.count) { _ in
                    if let lastEntry = commandHistory.last {
                        withAnimation {
                            proxy.scrollTo(lastEntry.id, anchor: .bottom)
                        }
                    }
                }
            }

            Divider()

            // Input
            HStack(spacing: 10) {
                Text("$")
                    .foregroundColor(.green)
                    .fontWeight(.bold)
                    .font(.system(.body, design: .monospaced))

                TextField("Commande SSH (ex: ls, pwd, reboot, unzip fichier.zip)", text: $commandInput)
                    .textFieldStyle(.plain)
                    .font(.system(.body, design: .monospaced))
                    .focused($isInputFocused)
                    .disabled(isExecuting || !connectionService.isConnected)
                    .onSubmit {
                        executeCommand()
                    }

                Button(action: executeCommand) {
                    Image(systemName: "return")
                }
                .keyboardShortcut(.return, modifiers: [])
                .disabled(commandInput.isEmpty || isExecuting || !connectionService.isConnected)
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))
        }
        .onAppear {
            isInputFocused = true
            // Ajouter un message de bienvenue
            if commandHistory.isEmpty {
                commandHistory.append(TerminalEntry(
                    command: "# Terminal SSH connecté",
                    output: "Tapez vos commandes ci-dessous. Exemples:\n- ls -la\n- pwd\n- reboot\n- unzip fichier.zip\n- tar -xzf archive.tar.gz",
                    isError: false
                ))
            }
        }
    }

    private func executeCommand() {
        guard !commandInput.isEmpty else { return }

        let command = commandInput
        commandInput = ""
        isExecuting = true

        // Ajouter la commande à l'historique
        commandHistory.append(TerminalEntry(command: command, output: "", isError: false))

        Task {
            do {
                let output = try await connectionService.executeCommand(command)

                await MainActor.run {
                    if let index = commandHistory.firstIndex(where: { $0.command == command && $0.output.isEmpty }) {
                        commandHistory[index].output = output.isEmpty ? "(commande exécutée avec succès)" : output
                    }
                    isExecuting = false
                }
            } catch {
                await MainActor.run {
                    if let index = commandHistory.firstIndex(where: { $0.command == command && $0.output.isEmpty }) {
                        commandHistory[index].output = "Erreur: \(error.localizedDescription)"
                        commandHistory[index].isError = true
                    }
                    isExecuting = false
                }
            }
        }
    }

    private func clearHistory() {
        commandHistory.removeAll()
    }
}

struct TerminalEntry: Identifiable {
    let id = UUID()
    let command: String
    var output: String
    var isError: Bool
}
