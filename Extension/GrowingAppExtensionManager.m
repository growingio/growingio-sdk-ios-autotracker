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

@interface GrowingAppExtensionManager()
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

#pragma mark - dispatch thread

- (BOOL)isAppExtensionQueue {
    return strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(self.appExtensionQueue)) == 0;
}

- (void)dispatchInExtensionThread:(void (^_Nullable)(void))block {
    if ([self isAppExtensionQueue]) {
        block();
    } else {
        dispatch_sync(self.appExtensionQueue, block);
    }
}

#pragma mark -- plist file

- (NSString *)filePathForGroupIdentifier:(NSString *)groupIdentifier {
    @try {
        if (![groupIdentifier isKindOfClass:NSString.class] || !groupIdentifier.length) {
            return nil;
        }
        __block NSString *filePath = nil;
        [self dispatchInExtensionThread:^{
            NSURL *pathUrl = [[[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:groupIdentifier] URLByAppendingPathComponent:@"growingio_extension_event_data.plist"];
            filePath = pathUrl.path;
        }];
        return filePath;
    } @catch (NSException *exception) {
        return nil;
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
        
        NSDictionary *event = @{kGrowingExtension_event: eventName,
                                kGrowingExtension_timestamp: [NSNumber numberWithUnsignedLongLong:[[NSDate date] timeIntervalSince1970] * 1000.0],
                                kGrowingExtension_attributes: attributes?attributes:@{}};
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
        NSDictionary *event = @{kGrowingExtension_attributes: variables?variables:@{}};
        return [self _writeEvent:event key:kGrowingExtensionConversionVariables groupIdentifier:groupIdentifier];
    } @catch (NSException *exception) {
        return NO;
    }
}

- (BOOL)writeLoginUserAttributes:(NSDictionary *)attributes groupIdentifier:(NSString *)groupIdentifier {
    if (![groupIdentifier isKindOfClass:NSString.class] || !groupIdentifier.length) {
        return NO;
    }
    if (attributes && ![attributes isKindOfClass:NSDictionary.class]) {
        return NO;
    }
    @try {
        NSDictionary *event = @{kGrowingExtension_attributes: attributes?attributes:@{}};
        return [self _writeEvent:event key:kGrowingExtensionLoginUserAttributes groupIdentifier:groupIdentifier];
    } @catch (NSException *exception) {
        return NO;
    }
}

- (BOOL)_writeEvent:(NSDictionary *)event key:(NSString *)name groupIdentifier:(NSString *)groupIdentifier {
    __block BOOL result = NO;
    [self dispatchInExtensionThread:^{
        NSString *path = [self filePathForGroupIdentifier:groupIdentifier];
        if(![[NSFileManager defaultManager] fileExistsAtPath:path]) {
            BOOL success = [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
            if (success) {
                NSLog(@"create extension plist file");
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
    }];
    return result;
}



- (NSDictionary *)readAllEventsWithGroupIdentifier:(NSString *)groupIdentifier {
    @try {
        if (![groupIdentifier isKindOfClass:NSString.class] || !groupIdentifier.length) {
            return @{};
        }
        __block NSDictionary *dataDic = @{};
        [self dispatchInExtensionThread:^{
            NSString *path = [self filePathForGroupIdentifier:groupIdentifier];
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
            dataDic = dictionary;
        }];
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
        [self dispatchInExtensionThread:^{
            NSString *path = [self filePathForGroupIdentifier:groupIdentifier];
            NSData *data= [NSPropertyListSerialization dataWithPropertyList:@{}
                                                                     format:NSPropertyListBinaryFormat_v1_0
                                                                    options:0
                                                                      error:nil];
            if (path.length && data.length) {
                result = [data  writeToFile:path options:NSDataWritingAtomic error:nil];
            }
        }];
        return result ;
    } @catch (NSException *exception) {
        return NO;
    }
}

@end
