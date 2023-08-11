//
//  GrowingFileStorage.m
//  GrowingAnalytics
//
//  Created by GrowingIO on 2020/3/3.
//  Copyright (C) 2020 Beijing Yishu Technology Co., Ltd.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import "GrowingTrackerCore/FileStorage/GrowingFileStorage.h"
#import "GrowingTrackerCore/Helpers/GrowingHelpers.h"
#import "GrowingTrackerCore/Public/GrowingServiceManager.h"
#import "GrowingTrackerCore/Thirdparty/Logger/GrowingLogger.h"
#import "GrowingTrackerCore/Utils/GrowingDeviceInfo.h"

NSString *const kGrowingResidentDirName = @"com.growingio.core";
NSString *const kGrowingDirCommonPrefix = @"com.growingio.";

@interface GrowingFileStorage ()

@property (nonatomic, strong, nonnull) NSURL *folderURL;
@property (nonatomic, copy) NSString *name;

@end

@implementation GrowingFileStorage

- (instancetype)init {
    return [self initWithName:@"default"];
}

- (instancetype)initWithName:(NSString *)name {
    id<GrowingEncryptionService> service =
        [[GrowingServiceManager sharedInstance] createService:@protocol(GrowingEncryptionService)];
    return [self initWithName:name directory:GrowingUserDirectoryLibrary crypto:service];
}

- (instancetype)initWithName:(NSString *)name directory:(GrowingUserDirectory)directory {
    id<GrowingEncryptionService> service =
        [[GrowingServiceManager sharedInstance] createService:@protocol(GrowingEncryptionService)];
    return [self initWithName:name directory:directory crypto:service];
}

- (instancetype)initWithName:(NSString *)name
                   directory:(GrowingUserDirectory)directory
                      crypto:(id<GrowingEncryptionService> _Nullable)crypto {
    if (self = [super init]) {
        NSString *fullPath = [GrowingFileStorage fullPathWithName:name append:nil];
        NSURL *userDir = [GrowingFileStorage userDirectoryURL:directory];
        _folderURL = [userDir URLByAppendingPathComponent:fullPath];
        _crypto = crypto;
        [self createDirectoryAtURLIfNeeded:_folderURL];
    }
    return self;
}

- (void)createDirectoryAtURLIfNeeded:(NSURL *)url {
    if (![[NSFileManager defaultManager] fileExistsAtPath:url.path isDirectory:NULL]) {
        NSError *error = nil;
        if (![[NSFileManager defaultManager] createDirectoryAtPath:url.path
                                       withIntermediateDirectories:YES
                                                        attributes:nil
                                                             error:&error]) {
            GIOLogError(@"error: %@", error.localizedDescription);
        }

        // excluded backup to iCloud
        NSError *excludedBackupErr = nil;
        if (![url setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:&error]) {
            GIOLogError(@"Error excluding %@ from backup %@", [url lastPathComponent], excludedBackupErr);
        }
    }
}

- (NSURL *)urlForKey:(NSString *)key {
    return [self.folderURL URLByAppendingPathComponent:key];
}

+ (NSURL *)userDirectoryURL:(GrowingUserDirectory)directory {
    NSSearchPathDirectory searchDir = NSCachesDirectory;
    if (GrowingUserDirectoryCaches == directory) {
        searchDir = NSCachesDirectory;
    } else if (GrowingUserDirectoryLibrary == directory) {
        searchDir = NSLibraryDirectory;
    } else if (GrowingUserDirectoryDocuments == directory) {
        searchDir = NSDocumentDirectory;
    } else if (GrowingUserDirectoryApplicationSupport == directory) {
        searchDir = NSApplicationSupportDirectory;
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(searchDir, NSUserDomainMask, YES);
    NSString *storagePath = [paths firstObject];
    return [NSURL fileURLWithPath:storagePath];
}

+ (NSString *)fullPathWithName:(NSString *)dirName append:(NSString *_Nullable)lastPathComponent {
    NSString *fullPath =
        [NSString stringWithFormat:@"%@/%@%@", kGrowingResidentDirName, kGrowingDirCommonPrefix, dirName];
#if TARGET_OS_OSX
    // 兼容非沙盒MacApp
    NSString *bundleId = [GrowingDeviceInfo currentDeviceInfo].bundleID;
    fullPath = [fullPath stringByAppendingFormat:@"/%@", bundleId];
#endif
    if (lastPathComponent && lastPathComponent.length > 0) {
        return [fullPath stringByAppendingFormat:@"/%@", lastPathComponent];
    }
    return fullPath;
}

#pragma mark Public

+ (NSString *)getTimingDatabasePath {
    static NSString *kGrowingPathTiming = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *userDir = [GrowingFileStorage userDirectoryURL:GrowingUserDirectoryLibrary];
        NSString *dirName = [GrowingFileStorage fullPathWithName:@"event" append:@"timing.sqlite"];
        kGrowingPathTiming = [userDir URLByAppendingPathComponent:dirName].path;
    });
    return kGrowingPathTiming;
}

+ (NSString *)getRealtimeDatabasePath {
    static NSString *kGrowingPathReal = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *userDir = [GrowingFileStorage userDirectoryURL:GrowingUserDirectoryLibrary];
        NSString *dirName = [GrowingFileStorage fullPathWithName:@"event" append:@"realtime.sqlite"];
        kGrowingPathReal = [userDir URLByAppendingPathComponent:dirName].path;
    });
    return kGrowingPathReal;
}

#pragma mark - GrowingStorage

- (void)removeKey:(NSString *)key {
    NSURL *url = [self urlForKey:key];
    NSError *error = nil;
    if (![[NSFileManager defaultManager] removeItemAtURL:url error:&error]) {
        GIOLogError(@"ERROR: Unable to remove key %@ - error removing file at path %@", key, url);
    }
}

- (void)resetAll {
    NSError *error = nil;
    if (![[NSFileManager defaultManager] removeItemAtURL:self.folderURL error:&error]) {
        GIOLogError(@"ERROR: Unable to reset file storage. Path cannot be removed - %@", self.folderURL.path);
    }
    [self createDirectoryAtURLIfNeeded:self.folderURL];
}

- (void)setData:(NSData *)data forKey:(NSString *)key {
    NSURL *url = [self urlForKey:key];

    // a nil value was supplied, remove the storage for that key.
    if (data == nil) {
        [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
        return;
    }

    if (self.crypto && [self.crypto respondsToSelector:@selector(encryptLocalData:)]) {
        NSData *encryptedData = [self.crypto encryptLocalData:data];
        [encryptedData writeToURL:url atomically:YES];
    } else {
        [data writeToURL:url atomically:YES];
    }
}

- (NSData *)dataForKey:(NSString *)key {
    NSURL *url = [self urlForKey:key];
    NSData *data = [NSData dataWithContentsOfURL:url];
    if (!data) {
        return nil;
    }
    if (self.crypto && [self.crypto respondsToSelector:@selector(decryptLocalData:)]) {
        return [self.crypto decryptLocalData:data];
    }
    return data;
}

- (nullable NSDictionary *)dictionaryForKey:(NSString *)key {
    return [self jsonForKey:key];
}

- (void)setDictionary:(nullable NSDictionary *)dictionary forKey:(NSString *)key {
    [self setJSON:dictionary forKey:key];
}

- (nullable NSArray *)arrayForKey:(NSString *)key {
    return [self jsonForKey:key];
}

- (void)setArray:(nullable NSArray *)array forKey:(NSString *)key {
    [self setJSON:array forKey:key];
}

- (NSString *)stringForKey:(NSString *)key {
    NSDictionary *data = [self jsonForKey:key];
    if (data) {
        return data[key];
    }
    return nil;
}

- (void)setString:(NSString *)string forKey:(NSString *)key {
    [self setJSON:string forKey:key];
}

- (void)setNumber:(NSNumber *)number forKey:(NSString *)key {
    [self setJSON:number forKey:key];
}

- (NSNumber *)numberForKey:(NSString *)key {
    NSDictionary *data = [self jsonForKey:key];
    if (data) {
        return data[key];
    }
    return nil;
}

#pragma mark - Helpers

- (id _Nullable)jsonForKey:(NSString *)key {
    id result = nil;

    NSData *data = [self dataForKey:key];
    if (data) {
        result = [self jsonFromData:data];
    }
    return result;
}

- (id _Nullable)jsonFromData:(NSData *_Nonnull)data {
    NSError *error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error) {
        GIOLogError(@"Unable to parse json from data %@", error);
    }
    return result;
}

- (void)setJSON:(id _Nonnull)json forKey:(NSString *)key {
    NSDictionary *dict = nil;

    if (json) {
        if ([json isKindOfClass:[NSDictionary class]] || [json isKindOfClass:[NSArray class]]) {
            dict = json;
        } else {
            dict = @{key: json};
        }
    }

    // NSDictionary or NSArray
    NSData *data = [dict growingHelper_jsonData];
    [self setData:data forKey:key];
}

@end
