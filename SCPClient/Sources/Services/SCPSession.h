//
//  SCPSession.h
//  SCP Client for macOS
//
//  Interface C++ pour libssh2
//

#ifndef SCPSession_h
#define SCPSession_h

#include <string>
#include <vector>
#include <functional>
#include <memory>

namespace SCPClient {

// Structure pour représenter un fichier distant
struct RemoteFile {
    std::string name;
    std::string path;
    uint64_t size;
    uint32_t permissions;
    bool isDirectory;
    int64_t modificationTime;
};

// Callback pour la progression des transferts
using ProgressCallback = std::function<void(uint64_t transferred, uint64_t total)>;

// Session SSH/SCP
class SCPSession {
public:
    SCPSession();
    ~SCPSession();

    // Connexion
    bool connect(const std::string& host, int port,
                 const std::string& username, const std::string& password);
    bool connectWithKey(const std::string& host, int port,
                       const std::string& username, const std::string& privateKeyPath,
                       const std::string& passphrase = "");
    void disconnect();
    bool isConnected() const;

    // Navigation
    std::vector<RemoteFile> listDirectory(const std::string& path);
    bool changeDirectory(const std::string& path);
    std::string getCurrentDirectory();

    // Opérations fichiers
    bool uploadFile(const std::string& localPath, const std::string& remotePath,
                   ProgressCallback callback = nullptr);
    bool downloadFile(const std::string& remotePath, const std::string& localPath,
                     ProgressCallback callback = nullptr);
    bool deleteFile(const std::string& remotePath);
    bool createDirectory(const std::string& remotePath);
    bool deleteDirectory(const std::string& remotePath);

    // Informations
    std::string getLastError() const;

private:
    class Impl;
    std::unique_ptr<Impl> pImpl;
};

} // namespace SCPClient

#endif /* SCPSession_h */
