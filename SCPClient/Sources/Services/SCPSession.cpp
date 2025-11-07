//
//  SCPSession.cpp
//  SCP Client for macOS
//
//  Implémentation du client SSH/SCP avec libssh2
//

#include "SCPSession.h"
#include <libssh2.h>
#include <libssh2_sftp.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <cstring>
#include <sstream>

namespace SCPClient {

class SCPSession::Impl {
public:
    LIBSSH2_SESSION* session = nullptr;
    LIBSSH2_SFTP* sftp = nullptr;
    int sock = -1;
    std::string lastError;
    std::string currentDir = "/";
    bool connected = false;
    ProtocolType protocol = ProtocolType::SCP;

    ~Impl() {
        cleanup();
    }

    void cleanup() {
        if (sftp) {
            libssh2_sftp_shutdown(sftp);
            sftp = nullptr;
        }
        if (session) {
            libssh2_session_disconnect(session, "Normal shutdown");
            libssh2_session_free(session);
            session = nullptr;
        }
        if (sock >= 0) {
            close(sock);
            sock = -1;
        }
        connected = false;
    }

    bool initializeSSH() {
        int rc = libssh2_init(0);
        if (rc != 0) {
            lastError = "Failed to initialize libssh2";
            return false;
        }
        return true;
    }

    bool createSocket(const std::string& host, int port) {
        struct addrinfo hints, *result;
        memset(&hints, 0, sizeof(hints));
        hints.ai_family = AF_UNSPEC;
        hints.ai_socktype = SOCK_STREAM;

        std::string portStr = std::to_string(port);
        int rc = getaddrinfo(host.c_str(), portStr.c_str(), &hints, &result);
        if (rc != 0) {
            lastError = "Failed to resolve hostname: " + std::string(gai_strerror(rc));
            return false;
        }

        sock = socket(result->ai_family, result->ai_socktype, result->ai_protocol);
        if (sock < 0) {
            lastError = "Failed to create socket";
            freeaddrinfo(result);
            return false;
        }

        if (::connect(sock, result->ai_addr, result->ai_addrlen) != 0) {
            lastError = "Failed to connect to " + host + ":" + std::to_string(port);
            close(sock);
            sock = -1;
            freeaddrinfo(result);
            return false;
        }

        freeaddrinfo(result);
        return true;
    }

    bool startSession() {
        session = libssh2_session_init();
        if (!session) {
            lastError = "Failed to create SSH session";
            return false;
        }

        libssh2_session_set_blocking(session, 1);

        int rc = libssh2_session_handshake(session, sock);
        if (rc) {
            char* errMsg;
            libssh2_session_last_error(session, &errMsg, nullptr, 0);
            lastError = "SSH handshake failed: " + std::string(errMsg);
            return false;
        }

        return true;
    }

    bool authenticate(const std::string& username, const std::string& password) {
        int rc = libssh2_userauth_password(session, username.c_str(), password.c_str());
        if (rc) {
            char* errMsg;
            libssh2_session_last_error(session, &errMsg, nullptr, 0);
            lastError = "Authentication failed: " + std::string(errMsg);
            return false;
        }
        return true;
    }

    bool authenticateWithKey(const std::string& username, const std::string& privateKeyPath,
                            const std::string& passphrase) {
        const char* pass = passphrase.empty() ? nullptr : passphrase.c_str();
        int rc = libssh2_userauth_publickey_fromfile(session, username.c_str(),
                                                     nullptr, privateKeyPath.c_str(), pass);
        if (rc) {
            char* errMsg;
            libssh2_session_last_error(session, &errMsg, nullptr, 0);
            lastError = "Key authentication failed: " + std::string(errMsg);
            return false;
        }
        return true;
    }

    bool initSFTP() {
        sftp = libssh2_sftp_init(session);
        if (!sftp) {
            char* errMsg;
            libssh2_session_last_error(session, &errMsg, nullptr, 0);
            lastError = "Failed to initialize SFTP: " + std::string(errMsg);
            return false;
        }
        return true;
    }
};

// Constructeur/Destructeur
SCPSession::SCPSession() : pImpl(new Impl()) {
    pImpl->initializeSSH();
}

SCPSession::~SCPSession() {
    disconnect();
}

void SCPSession::setProtocol(ProtocolType protocol) {
    pImpl->protocol = protocol;
}

// Connexion avec password
bool SCPSession::connect(const std::string& host, int port,
                        const std::string& username, const std::string& password) {
    disconnect();

    if (!pImpl->createSocket(host, port)) return false;
    if (!pImpl->startSession()) return false;
    if (!pImpl->authenticate(username, password)) return false;

    // Initialiser SFTP seulement si protocol = SFTP
    if (pImpl->protocol == ProtocolType::SFTP) {
        if (!pImpl->initSFTP()) return false;
    }

    pImpl->connected = true;
    return true;
}

// Connexion avec clé SSH
bool SCPSession::connectWithKey(const std::string& host, int port,
                               const std::string& username, const std::string& privateKeyPath,
                               const std::string& passphrase) {
    disconnect();

    if (!pImpl->createSocket(host, port)) return false;
    if (!pImpl->startSession()) return false;
    if (!pImpl->authenticateWithKey(username, privateKeyPath, passphrase)) return false;

    // Initialiser SFTP seulement si protocol = SFTP
    if (pImpl->protocol == ProtocolType::SFTP) {
        if (!pImpl->initSFTP()) return false;
    }

    pImpl->connected = true;
    return true;
}

void SCPSession::disconnect() {
    pImpl->cleanup();
}

bool SCPSession::isConnected() const {
    return pImpl->connected;
}

// Helper pour parser une ligne ls -la
RemoteFile parseLsLine(const std::string& line, const std::string& basePath) {
    RemoteFile file;
    std::istringstream iss(line);
    std::string perms, links, owner, group, sizeStr, month, day, timeOrYear, name;

    iss >> perms >> links >> owner >> group >> sizeStr;
    iss >> month >> day >> timeOrYear;

    // Le reste est le nom du fichier
    std::getline(iss >> std::ws, name);

    file.name = name;
    file.path = basePath + (basePath.back() == '/' ? "" : "/") + name;
    file.size = std::stoull(sizeStr);
    file.isDirectory = (perms[0] == 'd');
    file.permissions = 0755; // Valeur par défaut
    file.modificationTime = time(nullptr); // Approximation

    return file;
}

// Liste les fichiers d'un répertoire
std::vector<RemoteFile> SCPSession::listDirectory(const std::string& path) {
    std::vector<RemoteFile> files;

    if (!pImpl->session) {
        pImpl->lastError = "Not connected";
        return files;
    }

    if (pImpl->protocol == ProtocolType::SCP) {
        // Mode SCP - utiliser commande SSH ls
        LIBSSH2_CHANNEL* channel = libssh2_channel_open_session(pImpl->session);
        if (!channel) {
            pImpl->lastError = "Failed to open SSH channel";
            return files;
        }

        std::string command = "ls -la \"" + path + "\" 2>/dev/null";
        int rc = libssh2_channel_exec(channel, command.c_str());
        if (rc != 0) {
            pImpl->lastError = "Failed to execute ls command";
            libssh2_channel_free(channel);
            return files;
        }

        // Lire la sortie
        std::string output;
        char buffer[1024];
        ssize_t nread;

        while ((nread = libssh2_channel_read(channel, buffer, sizeof(buffer))) > 0) {
            output.append(buffer, nread);
        }

        libssh2_channel_close(channel);
        libssh2_channel_free(channel);

        // Parser la sortie ligne par ligne
        std::istringstream stream(output);
        std::string line;

        while (std::getline(stream, line)) {
            if (line.empty() || line.find("total ") == 0) continue;

            // Parser les informations du fichier
            std::istringstream iss(line);
            std::string perms, links, owner, group, sizeStr, month, day, timeOrYear, name;

            if (!(iss >> perms >> links >> owner >> group >> sizeStr >> month >> day >> timeOrYear)) {
                continue;
            }

            // Le reste est le nom du fichier
            std::getline(iss >> std::ws, name);

            if (name == "." || name == "..") continue;

            RemoteFile file;
            file.name = name;
            file.path = path + (path.back() == '/' ? "" : "/") + name;

            try {
                file.size = std::stoull(sizeStr);
            } catch (...) {
                file.size = 0;
            }

            file.isDirectory = (perms[0] == 'd');
            file.permissions = 0755;
            file.modificationTime = time(nullptr);

            files.push_back(file);
        }

        return files;

    } else {
        // Mode SFTP
        if (!pImpl->sftp) {
            pImpl->lastError = "SFTP not initialized";
            return files;
        }

        LIBSSH2_SFTP_HANDLE* handle = libssh2_sftp_opendir(pImpl->sftp, path.c_str());
        if (!handle) {
            pImpl->lastError = "Failed to open directory: " + path;
            return files;
        }

        char buffer[512];
        LIBSSH2_SFTP_ATTRIBUTES attrs;

        while (libssh2_sftp_readdir(handle, buffer, sizeof(buffer), &attrs) > 0) {
            std::string name(buffer);
            if (name == "." || name == "..") continue;

            RemoteFile file;
            file.name = name;
            file.path = path + (path.back() == '/' ? "" : "/") + name;
            file.size = attrs.filesize;
            file.permissions = attrs.permissions;
            file.isDirectory = LIBSSH2_SFTP_S_ISDIR(attrs.permissions);
            file.modificationTime = attrs.mtime;

            files.push_back(file);
        }

        libssh2_sftp_closedir(handle);
        return files;
    }
}

std::string SCPSession::getCurrentDirectory() {
    return pImpl->currentDir;
}

bool SCPSession::changeDirectory(const std::string& path) {
    if (!pImpl->sftp) {
        pImpl->lastError = "Not connected";
        return false;
    }

    // Vérifier que le répertoire existe
    LIBSSH2_SFTP_ATTRIBUTES attrs;
    int rc = libssh2_sftp_stat(pImpl->sftp, path.c_str(), &attrs);
    if (rc == 0 && LIBSSH2_SFTP_S_ISDIR(attrs.permissions)) {
        pImpl->currentDir = path;
        return true;
    }

    pImpl->lastError = "Directory does not exist: " + path;
    return false;
}

// Upload un fichier
bool SCPSession::uploadFile(const std::string& localPath, const std::string& remotePath,
                           ProgressCallback callback) {
    if (!pImpl->session) {
        pImpl->lastError = "Not connected";
        return false;
    }

    // Ouvrir le fichier local
    int fd = open(localPath.c_str(), O_RDONLY);
    if (fd < 0) {
        pImpl->lastError = "Cannot open local file: " + localPath;
        return false;
    }

    struct stat fileInfo;
    fstat(fd, &fileInfo);
    uint64_t totalSize = fileInfo.st_size;

    if (pImpl->protocol == ProtocolType::SCP) {
        // Mode SCP - utiliser libssh2_scp_send64
        LIBSSH2_CHANNEL* channel = libssh2_scp_send64(pImpl->session, remotePath.c_str(),
                                                       fileInfo.st_mode & 0777,
                                                       totalSize, 0, 0);
        if (!channel) {
            char* errMsg;
            libssh2_session_last_error(pImpl->session, &errMsg, nullptr, 0);
            pImpl->lastError = "Failed to open SCP channel: " + std::string(errMsg);
            close(fd);
            return false;
        }

        // Transfer
        char buffer[8192];
        uint64_t transferred = 0;
        ssize_t nread;

        while ((nread = read(fd, buffer, sizeof(buffer))) > 0) {
            ssize_t written = libssh2_channel_write(channel, buffer, nread);
            if (written < 0) {
                pImpl->lastError = "Write error during SCP upload";
                libssh2_channel_free(channel);
                close(fd);
                return false;
            }
            transferred += written;
            if (callback) {
                callback(transferred, totalSize);
            }
        }

        libssh2_channel_send_eof(channel);
        libssh2_channel_wait_eof(channel);
        libssh2_channel_wait_closed(channel);
        libssh2_channel_free(channel);
        close(fd);
        return true;

    } else {
        // Mode SFTP
        if (!pImpl->sftp) {
            pImpl->lastError = "SFTP not initialized";
            close(fd);
            return false;
        }

        // Créer le fichier distant
        LIBSSH2_SFTP_HANDLE* handle = libssh2_sftp_open(pImpl->sftp, remotePath.c_str(),
                                                         LIBSSH2_FXF_WRITE | LIBSSH2_FXF_CREAT | LIBSSH2_FXF_TRUNC,
                                                         LIBSSH2_SFTP_S_IRUSR | LIBSSH2_SFTP_S_IWUSR |
                                                         LIBSSH2_SFTP_S_IRGRP | LIBSSH2_SFTP_S_IROTH);
        if (!handle) {
            pImpl->lastError = "Cannot create remote file: " + remotePath;
            close(fd);
            return false;
        }

        // Transfer
        char buffer[8192];
        uint64_t transferred = 0;
        ssize_t nread;

        while ((nread = read(fd, buffer, sizeof(buffer))) > 0) {
            ssize_t written = libssh2_sftp_write(handle, buffer, nread);
            if (written < 0) {
                pImpl->lastError = "Write error during upload";
                libssh2_sftp_close(handle);
                close(fd);
                return false;
            }
            transferred += written;
            if (callback) {
                callback(transferred, totalSize);
            }
        }

        libssh2_sftp_close(handle);
        close(fd);
        return true;
    }
}

// Download un fichier
bool SCPSession::downloadFile(const std::string& remotePath, const std::string& localPath,
                             ProgressCallback callback) {
    if (!pImpl->session) {
        pImpl->lastError = "Not connected";
        return false;
    }

    if (pImpl->protocol == ProtocolType::SCP) {
        // Mode SCP - utiliser libssh2_scp_recv2
        struct stat fileInfo;
        LIBSSH2_CHANNEL* channel = libssh2_scp_recv2(pImpl->session, remotePath.c_str(), &fileInfo);
        if (!channel) {
            char* errMsg;
            libssh2_session_last_error(pImpl->session, &errMsg, nullptr, 0);
            pImpl->lastError = "Failed to open SCP channel for download: " + std::string(errMsg);
            return false;
        }

        uint64_t totalSize = fileInfo.st_size;

        // Créer le fichier local
        int fd = open(localPath.c_str(), O_WRONLY | O_CREAT | O_TRUNC, 0644);
        if (fd < 0) {
            pImpl->lastError = "Cannot create local file: " + localPath;
            libssh2_channel_free(channel);
            return false;
        }

        // Transfer
        char buffer[8192];
        uint64_t transferred = 0;
        ssize_t nread;

        while (transferred < totalSize) {
            size_t amount = sizeof(buffer);
            if ((totalSize - transferred) < amount) {
                amount = totalSize - transferred;
            }

            nread = libssh2_channel_read(channel, buffer, amount);
            if (nread < 0) {
                pImpl->lastError = "Read error during SCP download";
                libssh2_channel_free(channel);
                close(fd);
                return false;
            }
            if (nread == 0) break;

            ssize_t written = write(fd, buffer, nread);
            if (written < 0) {
                pImpl->lastError = "Write error during download";
                libssh2_channel_free(channel);
                close(fd);
                return false;
            }
            transferred += written;
            if (callback) {
                callback(transferred, totalSize);
            }
        }

        libssh2_channel_free(channel);
        close(fd);
        return true;

    } else {
        // Mode SFTP
        if (!pImpl->sftp) {
            pImpl->lastError = "SFTP not initialized";
            return false;
        }

        // Ouvrir le fichier distant
        LIBSSH2_SFTP_HANDLE* handle = libssh2_sftp_open(pImpl->sftp, remotePath.c_str(),
                                                         LIBSSH2_FXF_READ, 0);
        if (!handle) {
            pImpl->lastError = "Cannot open remote file: " + remotePath;
            return false;
        }

        // Obtenir la taille
        LIBSSH2_SFTP_ATTRIBUTES attrs;
        libssh2_sftp_fstat(handle, &attrs);
        uint64_t totalSize = attrs.filesize;

        // Créer le fichier local
        int fd = open(localPath.c_str(), O_WRONLY | O_CREAT | O_TRUNC, 0644);
        if (fd < 0) {
            pImpl->lastError = "Cannot create local file: " + localPath;
            libssh2_sftp_close(handle);
            return false;
        }

        // Transfer
        char buffer[8192];
        uint64_t transferred = 0;
        ssize_t nread;

        while ((nread = libssh2_sftp_read(handle, buffer, sizeof(buffer))) > 0) {
            ssize_t written = write(fd, buffer, nread);
            if (written < 0) {
                pImpl->lastError = "Write error during download";
                libssh2_sftp_close(handle);
                close(fd);
                return false;
            }
            transferred += written;
            if (callback) {
                callback(transferred, totalSize);
            }
        }

        libssh2_sftp_close(handle);
        close(fd);
        return true;
    }
}

// Helper pour exécuter une commande SSH
bool executeSSHCommand(LIBSSH2_SESSION* session, const std::string& command, std::string& lastError) {
    LIBSSH2_CHANNEL* channel = libssh2_channel_open_session(session);
    if (!channel) {
        lastError = "Failed to open SSH channel";
        return false;
    }

    int rc = libssh2_channel_exec(channel, command.c_str());
    if (rc != 0) {
        lastError = "Failed to execute command: " + command;
        libssh2_channel_free(channel);
        return false;
    }

    // Attendre la fin de l'exécution
    char buffer[1024];
    while (libssh2_channel_read(channel, buffer, sizeof(buffer)) > 0) {
        // Consommer la sortie
    }

    int exitcode = libssh2_channel_get_exit_status(channel);
    libssh2_channel_close(channel);
    libssh2_channel_free(channel);

    if (exitcode != 0) {
        lastError = "Command failed with exit code " + std::to_string(exitcode);
        return false;
    }

    return true;
}

bool SCPSession::deleteFile(const std::string& remotePath) {
    if (!pImpl->session) {
        pImpl->lastError = "Not connected";
        return false;
    }

    if (pImpl->protocol == ProtocolType::SCP) {
        // Mode SCP - utiliser commande SSH rm
        std::string command = "rm -f \"" + remotePath + "\"";
        return executeSSHCommand(pImpl->session, command, pImpl->lastError);
    } else {
        // Mode SFTP
        if (!pImpl->sftp) {
            pImpl->lastError = "SFTP not initialized";
            return false;
        }

        int rc = libssh2_sftp_unlink(pImpl->sftp, remotePath.c_str());
        if (rc != 0) {
            pImpl->lastError = "Failed to delete file: " + remotePath;
            return false;
        }
        return true;
    }
}

bool SCPSession::createDirectory(const std::string& remotePath) {
    if (!pImpl->session) {
        pImpl->lastError = "Not connected";
        return false;
    }

    if (pImpl->protocol == ProtocolType::SCP) {
        // Mode SCP - utiliser commande SSH mkdir
        std::string command = "mkdir -p \"" + remotePath + "\"";
        return executeSSHCommand(pImpl->session, command, pImpl->lastError);
    } else {
        // Mode SFTP
        if (!pImpl->sftp) {
            pImpl->lastError = "SFTP not initialized";
            return false;
        }

        int rc = libssh2_sftp_mkdir(pImpl->sftp, remotePath.c_str(),
                                    LIBSSH2_SFTP_S_IRWXU | LIBSSH2_SFTP_S_IRGRP |
                                    LIBSSH2_SFTP_S_IXGRP | LIBSSH2_SFTP_S_IROTH | LIBSSH2_SFTP_S_IXOTH);
        if (rc != 0) {
            pImpl->lastError = "Failed to create directory: " + remotePath;
            return false;
        }
        return true;
    }
}

bool SCPSession::deleteDirectory(const std::string& remotePath) {
    if (!pImpl->session) {
        pImpl->lastError = "Not connected";
        return false;
    }

    if (pImpl->protocol == ProtocolType::SCP) {
        // Mode SCP - utiliser commande SSH rmdir
        std::string command = "rmdir \"" + remotePath + "\"";
        return executeSSHCommand(pImpl->session, command, pImpl->lastError);
    } else {
        // Mode SFTP
        if (!pImpl->sftp) {
            pImpl->lastError = "SFTP not initialized";
            return false;
        }

        int rc = libssh2_sftp_rmdir(pImpl->sftp, remotePath.c_str());
        if (rc != 0) {
            pImpl->lastError = "Failed to delete directory: " + remotePath;
            return false;
        }
        return true;
    }
}

// Exécuter une commande SSH et retourner la sortie
std::string SCPSession::executeCommand(const std::string& command) {
    if (!pImpl->session) {
        pImpl->lastError = "Not connected";
        return "";
    }

    LIBSSH2_CHANNEL* channel = libssh2_channel_open_session(pImpl->session);
    if (!channel) {
        char* errMsg;
        libssh2_session_last_error(pImpl->session, &errMsg, nullptr, 0);
        pImpl->lastError = "Failed to open SSH channel: " + std::string(errMsg);
        return "";
    }

    int rc = libssh2_channel_exec(channel, command.c_str());
    if (rc != 0) {
        pImpl->lastError = "Failed to execute command: " + command;
        libssh2_channel_free(channel);
        return "";
    }

    // Lire la sortie (stdout et stderr)
    std::string output;
    char buffer[1024];
    ssize_t nread;

    // Lire stdout
    while ((nread = libssh2_channel_read(channel, buffer, sizeof(buffer))) > 0) {
        output.append(buffer, nread);
    }

    // Lire stderr
    while ((nread = libssh2_channel_read_stderr(channel, buffer, sizeof(buffer))) > 0) {
        output.append(buffer, nread);
    }

    // Obtenir le code de retour
    int exitcode = libssh2_channel_get_exit_status(channel);

    libssh2_channel_close(channel);
    libssh2_channel_free(channel);

    if (exitcode != 0 && output.empty()) {
        output = "Command failed with exit code " + std::to_string(exitcode);
    }

    return output;
}

std::string SCPSession::getLastError() const {
    return pImpl->lastError;
}

} // namespace SCPClient
