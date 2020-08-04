//
//  GrowingBroadcaster.m
//  GrowingTracker
//
//  Created by GrowingIO on 2020/7/6.
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


#import "GrowingBroadcaster.h"
#include <mach-o/getsect.h>
#include <mach-o/loader.h>
#include <mach-o/dyld.h>
#include <dlfcn.h>

@interface GrowingBroadcaster ()

@property (nonatomic, strong) NSMutableDictionary <NSString *, NSHashTable <id <GrowingMessageProtocol>> *> *observersDictM;
@property (nonatomic, strong) dispatch_queue_t notificationQueue;

@end

@implementation GrowingBroadcaster

- (instancetype)init {
    if (self = [super init]) {
        self.observersDictM = [NSMutableDictionary dictionaryWithCapacity:2];
        self.notificationQueue = dispatch_queue_create("com.growingio.broadcaster.queue", DISPATCH_QUEUE_CONCURRENT);
        [self growingBroadcasterReadRegistedInSection];
    }
    return self;
}

+ (instancetype)sharedInstance {
    static GrowingBroadcaster *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[GrowingBroadcaster alloc] init];
    });
    return instance;
}

- (void)registerEvent:(Protocol *)type observer:(id<GrowingMessageProtocol>)observer {
    
    if (!type) { return; }
    
    NSString *key = NSStringFromProtocol(type);
    
    dispatch_barrier_async(self.notificationQueue, ^{
        NSHashTable <id <GrowingMessageProtocol>> *set = [self.observersDictM objectForKey:key];
        if (set) {
            [set addObject:observer];
        } else {
            set = [NSHashTable weakObjectsHashTable];
            [set addObject:observer];
            [self.observersDictM setObject:set forKey:key];
        }
    });
}

- (void)unregisterEvent:(Protocol *)type observer:(id<GrowingMessageProtocol>)observer {
    if (!type) { return; }
    
    NSString *key = NSStringFromProtocol(type);
    [self safeRemoveForKey:key observer:observer];
}

/// Remove all observers which comform to the protocol
- (void)unregisterEvent:(Protocol *)type {
    if (!type) { return; }
    
    NSString *key = NSStringFromProtocol(type);
    [self safeRemoveForKey:key];
}

- (void)notifyEvent:(Protocol *)type usingBlock:(nonnull void (^)(id<GrowingMessageProtocol> _Nonnull))usingBlock {
    
    NSString *key = NSStringFromProtocol(type);
    NSHashTable <id <GrowingMessageProtocol>> *set = [self safeGetObserverSet:key];
        
    if (!set) { return; }
    
    for (id <GrowingMessageProtocol>obj in set) {
        usingBlock(obj);
    }
}

- (void)safeRemoveForKey:(NSString *)key observer:(id<GrowingMessageProtocol>)observer {
    dispatch_barrier_async(self.notificationQueue, ^{
        NSHashTable <id <GrowingMessageProtocol>> *set = [self.observersDictM objectForKey:key];
        if (set) {
            [set removeObject:observer];
            [self.observersDictM setObject:set forKey:key];
        }
    });
}

- (void)safeRemoveForKey:(NSString *)key {
    dispatch_barrier_async(self.notificationQueue, ^{
        [self.observersDictM removeObjectForKey:key];
    });
}

- (NSHashTable <id <GrowingMessageProtocol>> *)safeGetObserverSet:(NSString *)key {
    NSHashTable <id <GrowingMessageProtocol>> * __block set = nil;
    dispatch_barrier_sync(self.notificationQueue, ^{
        set = [self.observersDictM objectForKey:key];
    });
    return set;
}

- (void)growingBroadcasterReadRegistedInSection {
    NSArray<NSString *> *dataListInSection = growingBroadcasterReadConfigFromSection("GIOBroadcaster");
    for (NSString *item in dataListInSection) {
        NSArray *components = [item componentsSeparatedByString:@":"];
        if (components.count < 2) { return; }
        
        NSString *type = components.firstObject;
        if ([type isEqualToString:@"P"] && components.count == 3) {
            NSString *protocolName = components[1];
            NSString *protocolImplName = components[2];
            
            Protocol *serPro = NSProtocolFromString(protocolName);
            Class serCls = NSClassFromString(protocolImplName);
            if (serPro && serCls) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-pointer-types"
                [self registerEvent:serPro observer:serCls];
#pragma clang diagnostic pop
                
            }
        }
    }
}


NSArray<NSString *>* growingBroadcasterReadConfigFromSection(const char *sectionName){
    
#ifndef __LP64__
    const struct mach_header *mhp = NULL;
#else
    const struct mach_header_64 *mhp = NULL;
#endif
    
    NSMutableArray *configs = [NSMutableArray array];
    Dl_info info;
    if (mhp == NULL) {
        dladdr(growingBroadcasterReadConfigFromSection, &info);
#ifndef __LP64__
        mhp = (struct mach_header*)info.dli_fbase;
#else
        mhp = (struct mach_header_64*)info.dli_fbase;
#endif
    }
    
#ifndef __LP64__
    unsigned long size = 0;
    uint32_t *memory = (uint32_t*)getsectiondata(mhp, SEG_DATA, sectionName, & size);
#else /* defined(__LP64__) */
    unsigned long size = 0;
    uint64_t *memory = (uint64_t*)getsectiondata(mhp, SEG_DATA, sectionName, & size);
#endif /* defined(__LP64__) */
    
    for(int idx = 0; idx < size / sizeof(void*); ++idx){
        char *string = (char*)memory[idx];
        
        NSString *str = [NSString stringWithUTF8String:string];
        if (!str) { continue; }
        
        if (str) { [configs addObject:str]; }
    }
    
    return configs;
}

@end
