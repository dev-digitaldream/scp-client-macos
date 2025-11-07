//
//  SCPSessionBridge.h
//  SCP Client for macOS
//
//  Objective-C bridge pour exposer SCPSession à Swift
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RemoteFileInfo : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *path;
@property (nonatomic, assign) uint64_t size;
@property (nonatomic, assign) uint32_t permissions;
@property (nonatomic, assign) BOOL isDirectory;
@property (nonatomic, strong) NSDate *modificationDate;
@end

typedef void(^ProgressBlock)(uint64_t transferred, uint64_t total);

@interface SCPSessionBridge : NSObject

// Configuration
- (void)setProtocolSCP:(BOOL)useSCP;

// Connexion
- (BOOL)connectToHost:(NSString *)host
                 port:(NSInteger)port
             username:(NSString *)username
             password:(NSString *)password
                error:(NSError **)error;

- (BOOL)connectToHost:(NSString *)host
                 port:(NSInteger)port
             username:(NSString *)username
       privateKeyPath:(NSString *)privateKeyPath
           passphrase:(nullable NSString *)passphrase
                error:(NSError **)error;

- (void)disconnect;
- (BOOL)isConnected;

// Navigation
- (nullable NSArray<RemoteFileInfo *> *)listDirectoryAtPath:(NSString *)path
                                                       error:(NSError **)error;
- (BOOL)changeDirectoryToPath:(NSString *)path error:(NSError **)error;
- (NSString *)getCurrentDirectory;

// Opérations fichiers
- (BOOL)uploadFileFrom:(NSString *)localPath
                    to:(NSString *)remotePath
              progress:(nullable ProgressBlock)progress
                 error:(NSError **)error;

- (BOOL)downloadFileFrom:(NSString *)remotePath
                      to:(NSString *)localPath
                progress:(nullable ProgressBlock)progress
                   error:(NSError **)error;

- (BOOL)deleteFileAtPath:(NSString *)remotePath error:(NSError **)error;
- (BOOL)createDirectoryAtPath:(NSString *)remotePath error:(NSError **)error;
- (BOOL)deleteDirectoryAtPath:(NSString *)remotePath error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
