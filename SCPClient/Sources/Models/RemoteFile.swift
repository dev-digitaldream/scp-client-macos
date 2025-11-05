//
//  RemoteFile.swift
//  SCP Client for macOS
//
//  Modèle Swift pour les fichiers distants
//

import Foundation

struct RemoteFile: Identifiable {
    let id = UUID()
    let name: String
    let path: String
    let size: UInt64
    let permissions: UInt32
    let isDirectory: Bool
    let modificationDate: Date

    init(from info: RemoteFileInfo) {
        self.name = info.name
        self.path = info.path
        self.size = info.size
        self.permissions = info.permissions
        self.isDirectory = info.isDirectory
        self.modificationDate = info.modificationDate
    }

    var formattedSize: String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(size))
    }

    var permissionsString: String {
        let types = "-dl"
        var result = String(types[types.index(types.startIndex, offsetBy: isDirectory ? 1 : 0)])

        let perms = "rwxrwxrwx"
        for i in 0..<9 {
            let bit = (permissions >> UInt32(8 - i)) & 1
            if bit == 1 {
                result.append(perms[perms.index(perms.startIndex, offsetBy: i)])
            } else {
                result.append("-")
            }
        }

        return result
    }

    var icon: String {
        if isDirectory {
            return "📁"
        }

        let ext = (name as NSString).pathExtension.lowercased()
        switch ext {
        case "txt", "md", "log":
            return "📄"
        case "jpg", "jpeg", "png", "gif", "bmp":
            return "🖼️"
        case "zip", "tar", "gz", "bz2", "7z":
            return "📦"
        case "mp3", "wav", "m4a":
            return "🎵"
        case "mp4", "avi", "mov", "mkv":
            return "🎬"
        case "pdf":
            return "📕"
        case "doc", "docx":
            return "📘"
        case "xls", "xlsx":
            return "📗"
        case "sh", "py", "js", "swift", "cpp", "h":
            return "⚙️"
        default:
            return "📄"
        }
    }
}
