//
// GrowingAppExtensionManager.m
// GrowingAnalytics
//
//  Created by sheng on 2020/9/27.
//  Copyright (C) 2017 Beijing Yishu Technology Co., Ltd.
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

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag on this file.
#endif

#import "GrowingAppExtensionManager.h"



@interface GrowingAppExtensionManager(){
    NSArray * _groupIdentifierArray;
}

@property (nonatomic, strong) dispatch_queue_t appExtensionQueue;

@end

@implementation GrowingAppExtensionManager

+ (instancetype)sharedInstance {
    static GrowingAppExtensionManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[GrowingAppExtensionManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        self.appExtensionQueue = dispatch_queue_create("io.growingio.appExtensionQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (BOOL)isAppExtensionQueue {
    return strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(self.appExtensionQueue)) == 0;
}

- (void)setGroupIdentifierArray:(NSArray *)groupIdentifierArray {
    dispatch_block_t block = ^() {
        self->_groupIdentifierArray = groupIdentifierArray;
    };
    if ([self isAppExtensionQueue]) {
        block();
    } else {
        dispatch_async(self.appExtensionQueue, block);
    }
}

- (NSArray *)groupIdentifierArray {
    @try {
        __block NSArray *groupArray = nil;
        dispatch_block_t block = ^() {
            groupArray = self->_groupIdentifierArray;
        };
        if ([self isAppExtensionQueue]) {
            block();
        } else {
            dispatch_sync(self.appExtensionQueue, block);
        }
        return groupArray;
    } @catch (NSException *exception) {
        return nil;
    }
}

#pragma mark -- plistfile
- (NSString *)filePathForApplicationGroupIdentifier:(NSString *)groupIdentifier {
    @try {
        if (![groupIdentifier isKindOfClass:NSString.class] || !groupIdentifier.length) {
            return nil;
        }
        __block NSString *filePath = nil;
        dispatch_block_t block = ^() {
            NSURL *pathUrl = [[[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:groupIdentifier] URLByAppendingPathComponent:@"growingio_extension_event_data.plist"];
            filePath = pathUrl.path;
        };
        if ([self isAppExtensionQueue]) {
            block();
        } else {
            dispatch_sync(self.appExtensionQueue, block);
        }
        return filePath;
    } @catch (NSException *exception) {
        return nil;
    }
}

- (NSUInteger)fileDataCountForGroupIdentifier:(NSString *)groupIdentifier {
    @try {
        if (![groupIdentifier isKindOfClass:NSString.class] || !groupIdentifier.length) {
            return 0;
        }
        
        __block NSUInteger count = 0;
        dispatch_block_t block = ^() {
            NSString *path = [self filePathForApplicationGroupIdentifier:groupIdentifier];
            NSArray *array = [[NSMutableArray alloc] initWithContentsOfFile:path];
            count = array.count;
        };
        if ([self isAppExtensionQueue]) {
            block();
        } else {
            dispatch_sync(self.appExtensionQueue, block);
        }
        return count;
    } @catch (NSException *exception) {
        return 0;
    }
}

- (NSArray *)fileDataArrayWithPath:(NSString *)path limit:(NSUInteger)limit {
    @try {
        if (![path isKindOfClass:NSString.class] || !path.length) {
            return @[];
        }
        if (limit==0) {
            return @[];
        }
        __block NSArray *dataArray = @[];
        dispatch_block_t block = ^() {
            NSArray *array = [[NSArray alloc] initWithContentsOfFile:path];
            if (array.count >= limit) {
                array = [array subarrayWithRange:NSMakeRange(0, limit)];
            }
            dataArray = array;
        };
        if ([self isAppExtensionQueue]) {
            block();
        } else {
            dispatch_sync(self.appExtensionQueue, block);
        }
        return dataArray;
    } @catch (NSException *exception) {
        return @[];
    }
}

- (BOOL)writeCustomEvent:(NSString *)eventName attributes:(NSDictionary *)attributes groupIdentifier:(NSString *)groupIdentifier {
    @try {
        if (![eventName isKindOfClass:NSString.class] || !eventName.length) {
            return NO;
        }
        if (![groupIdentifier isKindOfClass:NSString.class] || !groupIdentifier.length) {
            return NO;
        }
        if (attributes && ![attributes isKindOfClass:NSDictionary.class]) {
            return NO;
        }
        
        NSDictionary *event = @{@"event": eventName, @"attributes": attributes?attributes:@{}};
        return [self _writeEvent:event key:kGrowingExtensionCustomEvent groupIdentifier:groupIdentifier];
    } @catch (NSException *exception) {
        return NO;
    }
}

- (BOOL)writeConversionVariables:(NSDictionary *)variables groupIdentifier:(NSString *)groupIdentifier {
    if (![groupIdentifier isKindOfClass:NSString.class] || !groupIdentifier.length) {
        return NO;
    }
    if (variables && ![variables isKindOfClass:NSDictionary.class]) {
        return NO;
    }
    @try {
        NSDictionary *event = @{@"variables": variables?variables:@{}};
        return [self _writeEvent:event key:kGrowingExtensionConversionVariables groupIdentifier:groupIdentifier];
    } @catch (NSException *exception) {
        return NO;
    }
}

- (BOOL)writeVisitorAttributes:(NSDictionary *)attributes groupIdentifier:(NSString *)groupIdentifier {
    if (![groupIdentifier isKindOfClass:NSString.class] || !groupIdentifier.length) {
        return NO;
    }
    if (attributes && ![attributes isKindOfClass:NSDictionary.class]) {
        return NO;
    }
    @try {
        NSDictionary *event = @{@"attributes": attributes?attributes:@{}};
        return [self _writeEvent:event key:kGrowingExtensionVisitorAttributes groupIdentifier:groupIdentifier];
    } @catch (NSException *exception) {
        return NO;
    }
}

- (BOOL)_writeEvent:(NSDictionary *)event key:(NSString *)name groupIdentifier:(NSString *)groupIdentifier {
    __block BOOL result = NO;
    dispatch_block_t block = ^{
        NSString *path = [self filePathForApplicationGroupIdentifier:groupIdentifier];
        if(![[NSFileManager defaultManager] fileExistsAtPath:path]) {
            BOOL success = [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
            if (success) {
                //                    SALogDebug(@"create plist file success!!!!!!! APPEXtension...");
            }
        }
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
        if (!dictionary) {
            dictionary = [NSMutableDictionary dictionary];
        }
        NSMutableArray *array = [dictionary objectForKey:name];
        if (array.count) {
            [array addObject:event];
        } else {
            array = [NSMutableArray arrayWithObject:event];
        }
        [dictionary setValue:array forKey:name];
        NSError *err = NULL;
        NSData *data= [NSPropertyListSerialization dataWithPropertyList:dictionary
                                                                 format:NSPropertyListBinaryFormat_v1_0
                                                                options:0
                                                                  error:&err];
        if (path.length && data.length) {
            result = [data  writeToFile:path options:NSDataWritingAtomic error:nil];
        }
    };
    if ([self isAppExtensionQueue]) {
        block();
    } else {
        dispatch_sync(self.appExtensionQueue, block);
    }
    return result;
}



- (NSDictionary *)readAllEventsWithGroupIdentifier:(NSString *)groupIdentifier {
    @try {
        if (![groupIdentifier isKindOfClass:NSString.class] || !groupIdentifier.length) {
            return @{};
        }
        __block NSDictionary *dataDic = @{};
        dispatch_block_t block = ^() {
            NSString *path = [self filePathForApplicationGroupIdentifier:groupIdentifier];
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
            dataDic = dictionary;
        };
        if ([self isAppExtensionQueue]) {
            block();
        } else {
            dispatch_sync(self.appExtensionQueue, block);
        }
        return dataDic;
    } @catch (NSException *exception) {
        return @{};
    }
}

- (BOOL)deleteEventsWithGroupIdentifier:(NSString *)groupIdentifier {
    @try {
        if (![groupIdentifier isKindOfClass:NSString.class] || !groupIdentifier.length) {
            return NO;
        }
        __block BOOL result = NO;
        dispatch_block_t block = ^{
            NSString *path = [self filePathForApplicationGroupIdentifier:groupIdentifier];
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
            [dictionary removeAllObjects];
            NSData *data= [NSPropertyListSerialization dataWithPropertyList:dictionary
                                                                     format:NSPropertyListBinaryFormat_v1_0
                                                                    options:0
                                                                      error:nil];
            if (path.length && data.length) {
                result = [data  writeToFile:path options:NSDataWritingAtomic error:nil];
            }
        };
        if ([self isAppExtensionQueue]) {
            block();
        } else {
            dispatch_sync(self.appExtensionQueue, block);
        }
        return result ;
    } @catch (NSException *exception) {
        return NO;
    }
}

@end
