//
//  FileExplorerView.swift
//  SCP Client for macOS
//
//  Explorateur de fichiers distant
//

import SwiftUI
import UniformTypeIdentifiers

struct FileExplorerView: View {
    @EnvironmentObject var connectionService: ConnectionService

    @State private var selectedFiles = Set<UUID>()
    @State private var showingNewFolderSheet = false
    @State private var newFolderName = ""
    @State private var isRefreshing = false

    var body: some View {
        VStack(spacing: 0) {
            // Barre de navigation
            NavigationBar(isRefreshing: $isRefreshing)

            Divider()

            // Liste des fichiers
            if connectionService.remoteFiles.isEmpty && !isRefreshing {
                EmptyDirectoryView()
            } else {
                FileListView(selectedFiles: $selectedFiles)
            }

            Divider()

            // Barre de transferts
            if !connectionService.transferTasks.isEmpty {
                TransferPanel()
                    .frame(height: 200)
            }
        }
        .sheet(isPresented: $showingNewFolderSheet) {
            NewFolderSheet(isPresented: $showingNewFolderSheet)
        }
        .onDrop(of: [.fileURL], isTargeted: nil) { providers in
            handleDrop(providers: providers)
            return true
        }
    }

    private func handleDrop(providers: [NSItemProvider]) {
        for provider in providers {
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, error in
                guard let data = item as? Data,
                      let url = URL(dataRepresentation: data, relativeTo: nil) else {
                    return
                }

                let fileName = url.lastPathComponent
                let remotePath = connectionService.currentDirectory + "/" + fileName

                Task {
                    do {
                        try await connectionService.uploadFile(
                            from: url.path,
                            to: remotePath
                        )
                        try await connectionService.loadDirectory(connectionService.currentDirectory)
                    } catch {
                        print("Upload failed: \(error)")
                    }
                }
            }
        }
    }
}

// Barre de navigation
struct NavigationBar: View {
    @EnvironmentObject var connectionService: ConnectionService
    @Binding var isRefreshing: Bool
    @State private var showingNewFolderSheet = false

    var body: some View {
        HStack {
            // Bouton retour
            Button(action: {
                Task {
                    do {
                        try await connectionService.navigateUp()
                    } catch {
                        print("Navigation failed: \(error)")
                    }
                }
            }) {
                Image(systemName: "chevron.left")
            }
            .disabled(connectionService.currentDirectory == "/")

            // Chemin actuel
            Text(connectionService.currentDirectory)
                .font(.headline)
                .lineLimit(1)
                .truncationMode(.middle)

            Spacer()

            // Actions
            Button(action: { showingNewFolderSheet = true }) {
                Image(systemName: "folder.badge.plus")
            }
            .help("Nouveau dossier")

            Button(action: {
                Task {
                    isRefreshing = true
                    do {
                        try await connectionService.loadDirectory(connectionService.currentDirectory)
                    } catch {
                        print("Refresh failed: \(error)")
                    }
                    isRefreshing = false
                }
            }) {
                Image(systemName: "arrow.clockwise")
            }
            .help("Actualiser")
            .disabled(isRefreshing)
        }
        .padding()
        .sheet(isPresented: $showingNewFolderSheet) {
            NewFolderSheet(isPresented: $showingNewFolderSheet)
        }
    }
}

// Liste des fichiers
struct FileListView: View {
    @EnvironmentObject var connectionService: ConnectionService
    @Binding var selectedFiles: Set<UUID>

    var body: some View {
        Table(connectionService.remoteFiles, selection: $selectedFiles) {
            TableColumn("Nom") { file in
                HStack {
                    Text(file.icon)
                    Text(file.name)
                        .font(.body)
                }
            }

            TableColumn("Taille") { file in
                Text(file.isDirectory ? "—" : file.formattedSize)
                    .foregroundColor(.secondary)
            }
            .width(100)

            TableColumn("Permissions") { file in
                Text(file.permissionsString)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.secondary)
            }
            .width(100)

            TableColumn("Modifié") { file in
                Text(file.modificationDate, style: .relative)
                    .foregroundColor(.secondary)
            }
            .width(120)
        }
        .contextMenu(forSelectionType: UUID.self) { items in
            if items.count == 1, let fileId = items.first,
               let file = connectionService.remoteFiles.first(where: { $0.id == fileId }) {

                if file.isDirectory {
                    Button("Ouvrir") {
                        Task {
                            try? await connectionService.changeDirectory(to: file.path)
                        }
                    }
                } else {
                    Button("Télécharger") {
                        downloadFile(file)
                    }
                }

                Divider()

                Button("Supprimer", role: .destructive) {
                    Task {
                        try? await deleteFile(file)
                    }
                }
            }
        } primaryAction: { items in
            if let fileId = items.first,
               let file = connectionService.remoteFiles.first(where: { $0.id == fileId }),
               file.isDirectory {
                Task {
                    try? await connectionService.changeDirectory(to: file.path)
                }
            }
        }
    }

    private func downloadFile(_ file: RemoteFile) {
        let panel = NSSavePanel()
        panel.nameFieldStringValue = file.name
        panel.canCreateDirectories = true

        if panel.runModal() == .OK, let url = panel.url {
            Task {
                do {
                    try await connectionService.downloadFile(
                        from: file.path,
                        to: url.path,
                        size: file.size
                    )
                } catch {
                    print("Download failed: \(error)")
                }
            }
        }
    }

    private func deleteFile(_ file: RemoteFile) async throws {
        if file.isDirectory {
            try await connectionService.deleteDirectory(at: file.path)
        } else {
            try await connectionService.deleteFile(at: file.path)
        }
    }
}

// Vue dossier vide
struct EmptyDirectoryView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "folder")
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            Text("Ce dossier est vide")
                .font(.title3)
                .foregroundColor(.secondary)

            Text("Glissez-déposez des fichiers ici pour les uploader")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// Formulaire nouveau dossier
struct NewFolderSheet: View {
    @Binding var isPresented: Bool
    @State var folderName = ""
    @EnvironmentObject var connectionService: ConnectionService

    var body: some View {
        VStack(spacing: 20) {
            Text("Nouveau dossier")
                .font(.headline)

            TextField("Nom du dossier", text: $folderName)
                .textFieldStyle(.roundedBorder)

            HStack {
                Button("Annuler") {
                    isPresented = false
                }
                .keyboardShortcut(.escape)

                Spacer()

                Button("Créer") {
                    Task {
                        let newPath = connectionService.currentDirectory + "/" + folderName
                        try? await connectionService.createDirectory(at: newPath)
                        isPresented = false
                    }
                }
                .keyboardShortcut(.return)
                .disabled(folderName.isEmpty)
            }
        }
        .padding()
        .frame(width: 300)
    }
}
