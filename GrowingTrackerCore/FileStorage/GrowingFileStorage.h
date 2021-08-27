//
//  GrowingFileStorage.h
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


#import <Foundation/Foundation.h>
#import "GrowingEncryptionService.h"

@protocol GrowingStorage <NSObject>

@property (nonatomic, strong, nullable) id<GrowingEncryptionService> crypto;

- (void)removeKey:(NSString *_Nonnull)key;
- (void)resetAll;

- (void)setData:(NSData *_Nullable)data forKey:(NSString *_Nonnull)key;
- (NSData *_Nullable)dataForKey:(NSString *_Nonnull)key;

- (void)setDictionary:(NSDictionary *_Nullable)dictionary forKey:(NSString *_Nonnull)key;
- (NSDictionary *_Nullable)dictionaryForKey:(NSString *_Nonnull)key;

- (void)setArray:(NSArray *_Nullable)array forKey:(NSString *_Nonnull)key;
- (NSArray *_Nullable)arrayForKey:(NSString *_Nonnull)key;

- (void)setString:(NSString *_Nullable)string forKey:(NSString *_Nonnull)key;
- (NSString *_Nullable)stringForKey:(NSString *_Nonnull)key;

- (void)setNumber:(NSNumber *_Nullable)number forKey:(NSString *_Nonnull)key;
- (NSNumber *_Nullable)numberForKey:(NSString *_Nonnull)key;

@end


typedef NS_ENUM(NSUInteger, GrowingUserDirectory)
{
    GrowingUserDirectoryCaches,
    GrowingUserDirectoryDocuments,
    GrowingUserDirectoryLibrary,
    GrowingUserDirectoryApplicationSupport,
};

NS_ASSUME_NONNULL_BEGIN

@interface GrowingFileStorage : NSObject <GrowingStorage>

@property (nonatomic, strong, nullable) id<GrowingEncryptionService> crypto;

@property (nonatomic, strong, nonnull, readonly) NSURL *folderURL;

- (instancetype _Nonnull)initWithName:(NSString *_Nonnull)name;

- (instancetype _Nonnull)initWithName:(NSString *_Nonnull)name directory:(GrowingUserDirectory)directory;

- (instancetype _Nonnull)initWithName:(NSString *_Nonnull)name directory:(GrowingUserDirectory)directory crypto:(id<GrowingEncryptionService> _Nullable)crypto;

- (NSURL *_Nonnull)urlForKey:(NSString *_Nonnull)key;

+ (NSString *)getTimingDatabasePath;

+ (NSString *)getRealtimeDatabasePath;

@end

NS_ASSUME_NONNULL_END
