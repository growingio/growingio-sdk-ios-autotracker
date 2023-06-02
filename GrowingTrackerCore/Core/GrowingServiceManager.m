//
// GrowingServiceManager.m
// GrowingAnalytics
//
//  Created by sheng on 2021/6/8.
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

#import "GrowingTrackerCore/Public/GrowingServiceManager.h"
#import <objc/message.h>
#import "GrowingTrackerCore/Public/GrowingAnnotationCore.h"
#import "GrowingTrackerCore/Public/GrowingBaseService.h"
#import "GrowingTrackerCore/Thirdparty/Logger/GrowingLogger.h"

@interface GrowingServiceManager ()

@property (nonatomic, copy) NSMutableDictionary *allServiceDict;
@property (nonatomic, copy) NSMutableDictionary *allServiceInstanceDict;

@end

@implementation GrowingServiceManager

+ (instancetype)sharedInstance {
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (!self) return nil;
    _allServiceDict = [[NSMutableDictionary alloc] init];
    _allServiceInstanceDict = [[NSMutableDictionary alloc] init];
    return self;
}

#pragma mark - Public

- (void)registerAllServices {
    // register services
    growing_section section = growingSectionDataService();
    for (int i = 0; i < section.count; i++) {
        char *string = (char *)section.charAddress[i];
        NSString *map = [NSString stringWithUTF8String:string];
        NSData *jsonData = [map dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        id json = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
        if (!error) {
            if ([json isKindOfClass:[NSDictionary class]] && [json allKeys].count) {
                NSString *protocol = [json allKeys][0];
                NSString *clsName = [json allValues][0];
                if (protocol && clsName) {
                    GIOLogDebug(@"[GrowingServiceManager] load %@(%@)", clsName, protocol);
                    [self.allServiceDict setValue:clsName forKey:protocol];
                }
            }
        }
    }
}

- (void)registerService:(Protocol *)service implClass:(Class)serviceClass {
    [self.allServiceDict setValue:NSStringFromClass(serviceClass) forKey:NSStringFromProtocol(service)];
}

- (id)createService:(Protocol *)service {
    NSString *serviceString = NSStringFromProtocol(service);
    id instance = [self.allServiceInstanceDict objectForKey:serviceString];
    if (instance) {
        return instance;
    }

    Class implClass = [self serviceImplClass:service];
    if (!implClass) {
        return nil;
    }
    
    if ([[implClass class] respondsToSelector:@selector(singleton)]) {
        BOOL (*sigletonImp)(id, SEL) = (BOOL(*)(id, SEL))objc_msgSend;
        BOOL isSingleton = sigletonImp([implClass class], @selector(singleton));
        if (isSingleton) {
            if ([[implClass class] respondsToSelector:@selector(sharedInstance)]) {
                instance = [[implClass class] performSelector:@selector(sharedInstance)];
            }
        }
    }
    
    if (!instance) {
        instance = [[implClass alloc] init];
    }
    
    [self.allServiceInstanceDict setObject:instance forKey:serviceString]; // cache
    return instance;
}

- (id)serviceImplClass:(Protocol *)service {
    NSString *className = [self.allServiceDict valueForKey:NSStringFromProtocol(service)];
    return NSClassFromString(className);
}

@end
