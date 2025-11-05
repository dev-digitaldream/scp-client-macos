//
//  SCPSessionBridge.mm
//  SCP Client for macOS
//
//  Implémentation du bridge Objective-C++ vers C++
//

#import "SCPSessionBridge.h"
#include "SCPSession.h"
#include <memory>

static NSString *const SCPErrorDomain = @"com.scpclient.error";

@implementation RemoteFileInfo
@end

@interface SCPSessionBridge()
@property (nonatomic) std::unique_ptr<SCPClient::SCPSession> session;
@end

@implementation SCPSessionBridge

- (instancetype)init {
    self = [super init];
    if (self) {
        _session = std::make_unique<SCPClient::SCPSession>();
    }
    return self;
}

- (BOOL)connectToHost:(NSString *)host
                 port:(NSInteger)port
             username:(NSString *)username
             password:(NSString *)password
                error:(NSError **)error {

    std::string hostStr = [host UTF8String];
    std::string userStr = [username UTF8String];
    std::string passStr = [password UTF8String];

    BOOL success = _session->connect(hostStr, (int)port, userStr, passStr);

    if (!success && error) {
        std::string errMsg = _session->getLastError();
        NSDictionary *userInfo = @{
            NSLocalizedDescriptionKey: [NSString stringWithUTF8String:errMsg.c_str()]
        };
        *error = [NSError errorWithDomain:SCPErrorDomain code:1 userInfo:userInfo];
    }

    return success;
}

- (BOOL)connectToHost:(NSString *)host
                 port:(NSInteger)port
             username:(NSString *)username
       privateKeyPath:(NSString *)privateKeyPath
           passphrase:(nullable NSString *)passphrase
                error:(NSError **)error {

    std::string hostStr = [host UTF8String];
    std::string userStr = [username UTF8String];
    std::string keyStr = [privateKeyPath UTF8String];
    std::string passStr = passphrase ? [passphrase UTF8String] : "";

    BOOL success = _session->connectWithKey(hostStr, (int)port, userStr, keyStr, passStr);

    if (!success && error) {
        std::string errMsg = _session->getLastError();
        NSDictionary *userInfo = @{
            NSLocalizedDescriptionKey: [NSString stringWithUTF8String:errMsg.c_str()]
        };
        *error = [NSError errorWithDomain:SCPErrorDomain code:1 userInfo:userInfo];
    }

    return success;
}

- (void)disconnect {
    _session->disconnect();
}

- (BOOL)isConnected {
    return _session->isConnected();
}

- (nullable NSArray<RemoteFileInfo *> *)listDirectoryAtPath:(NSString *)path
                                                       error:(NSError **)error {
    std::string pathStr = [path UTF8String];
    std::vector<SCPClient::RemoteFile> files = _session->listDirectory(pathStr);

    NSMutableArray<RemoteFileInfo *> *result = [NSMutableArray array];

    for (const auto& file : files) {
        RemoteFileInfo *info = [[RemoteFileInfo alloc] init];
        info.name = [NSString stringWithUTF8String:file.name.c_str()];
        info.path = [NSString stringWithUTF8String:file.path.c_str()];
        info.size = file.size;
        info.permissions = file.permissions;
        info.isDirectory = file.isDirectory;
        info.modificationDate = [NSDate dateWithTimeIntervalSince1970:file.modificationTime];
        [result addObject:info];
    }

    return result;
}

- (BOOL)changeDirectoryToPath:(NSString *)path error:(NSError **)error {
    std::string pathStr = [path UTF8String];
    BOOL success = _session->changeDirectory(pathStr);

    if (!success && error) {
        std::string errMsg = _session->getLastError();
        NSDictionary *userInfo = @{
            NSLocalizedDescriptionKey: [NSString stringWithUTF8String:errMsg.c_str()]
        };
        *error = [NSError errorWithDomain:SCPErrorDomain code:2 userInfo:userInfo];
    }

    return success;
}

- (NSString *)getCurrentDirectory {
    std::string dir = _session->getCurrentDirectory();
    return [NSString stringWithUTF8String:dir.c_str()];
}

- (BOOL)uploadFileFrom:(NSString *)localPath
                    to:(NSString *)remotePath
              progress:(nullable ProgressBlock)progress
                 error:(NSError **)error {

    std::string localStr = [localPath UTF8String];
    std::string remoteStr = [remotePath UTF8String];

    SCPClient::ProgressCallback callback = nullptr;
    if (progress) {
        callback = [progress](uint64_t transferred, uint64_t total) {
            dispatch_async(dispatch_get_main_queue(), ^{
                progress(transferred, total);
            });
        };
    }

    BOOL success = _session->uploadFile(localStr, remoteStr, callback);

    if (!success && error) {
        std::string errMsg = _session->getLastError();
        NSDictionary *userInfo = @{
            NSLocalizedDescriptionKey: [NSString stringWithUTF8String:errMsg.c_str()]
        };
        *error = [NSError errorWithDomain:SCPErrorDomain code:3 userInfo:userInfo];
    }

    return success;
}

- (BOOL)downloadFileFrom:(NSString *)remotePath
                      to:(NSString *)localPath
                progress:(nullable ProgressBlock)progress
                   error:(NSError **)error {

    std::string remoteStr = [remotePath UTF8String];
    std::string localStr = [localPath UTF8String];

    SCPClient::ProgressCallback callback = nullptr;
    if (progress) {
        callback = [progress](uint64_t transferred, uint64_t total) {
            dispatch_async(dispatch_get_main_queue(), ^{
                progress(transferred, total);
            });
        };
    }

    BOOL success = _session->downloadFile(remoteStr, localStr, callback);

    if (!success && error) {
        std::string errMsg = _session->getLastError();
        NSDictionary *userInfo = @{
            NSLocalizedDescriptionKey: [NSString stringWithUTF8String:errMsg.c_str()]
        };
        *error = [NSError errorWithDomain:SCPErrorDomain code:4 userInfo:userInfo];
    }

    return success;
}

- (BOOL)deleteFileAtPath:(NSString *)remotePath error:(NSError **)error {
    std::string pathStr = [remotePath UTF8String];
    BOOL success = _session->deleteFile(pathStr);

    if (!success && error) {
        std::string errMsg = _session->getLastError();
        NSDictionary *userInfo = @{
            NSLocalizedDescriptionKey: [NSString stringWithUTF8String:errMsg.c_str()]
        };
        *error = [NSError errorWithDomain:SCPErrorDomain code:5 userInfo:userInfo];
    }

    return success;
}

- (BOOL)createDirectoryAtPath:(NSString *)remotePath error:(NSError **)error {
    std::string pathStr = [remotePath UTF8String];
    BOOL success = _session->createDirectory(pathStr);

    if (!success && error) {
        std::string errMsg = _session->getLastError();
        NSDictionary *userInfo = @{
            NSLocalizedDescriptionKey: [NSString stringWithUTF8String:errMsg.c_str()]
        };
        *error = [NSError errorWithDomain:SCPErrorDomain code:6 userInfo:userInfo];
    }

    return success;
}

- (BOOL)deleteDirectoryAtPath:(NSString *)remotePath error:(NSError **)error {
    std::string pathStr = [remotePath UTF8String];
    BOOL success = _session->deleteDirectory(pathStr);

    if (!success && error) {
        std::string errMsg = _session->getLastError();
        NSDictionary *userInfo = @{
            NSLocalizedDescriptionKey: [NSString stringWithUTF8String:errMsg.c_str()]
        };
        *error = [NSError errorWithDomain:SCPErrorDomain code:7 userInfo:userInfo];
    }

    return success;
}

@end
