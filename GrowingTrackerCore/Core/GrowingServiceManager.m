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


#import "GrowingServiceManager.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation GrowingServiceManager {
    dispatch_semaphore_t _signallock;
}

static GrowingServiceManager *manager = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[GrowingServiceManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        _allServiceDict = [[NSMutableDictionary alloc] init];
        _allServiceInstanceDict = [[NSMutableDictionary alloc] init];
        _signallock = dispatch_semaphore_create(1);
    }
    return self;
}

#pragma mark - private

- (void)registerService:(Protocol*)service implClass:(Class)serviceClass {
    dispatch_semaphore_wait(_signallock, DISPATCH_TIME_FOREVER);
    [_allServiceDict setValue:NSStringFromClass(serviceClass) forKey:NSStringFromProtocol(service)];
    dispatch_semaphore_signal(_signallock);
}

- (id)createService:(Protocol *)service {
    return [self createService:service withServiceName:nil];
}

- (id)createService:(Protocol *)service withServiceName:(NSString *)serviceName {
    return [self createService:service withServiceName:serviceName shouldCache:YES];
}

- (BOOL)checkValidService:(Protocol *)service {
    id class = nil;
    dispatch_semaphore_wait(_signallock, DISPATCH_TIME_FOREVER);
    class = [_allServiceDict valueForKey:NSStringFromProtocol(service)];
    dispatch_semaphore_signal(_signallock);
    if (class) {
        return YES;
    }
    return NO;
}

- (id)createService:(Protocol *)service withServiceName:(NSString *)serviceName shouldCache:(BOOL)shouldCache {
    if (!serviceName.length) {
        serviceName = NSStringFromProtocol(service);
    }
    id implInstance = nil;
    
    if (![self checkValidService:service]) {
        if (self.enableException) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"%@ protocol does not been registed", NSStringFromProtocol(service)] userInfo:nil];
        }
    }
    
    NSString *serviceStr = serviceName;
    if (shouldCache) {
        id protocolImpl = [_allServiceInstanceDict objectForKey:serviceStr];
        if (protocolImpl) {
            return protocolImpl;
        }
    }
    
    Class implClass = [self serviceImplClass:service];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if ([[implClass class] respondsToSelector:@selector(singleton)]) {
        BOOL (*sigletonImp)(id,SEL) = (BOOL(*)(id, SEL))objc_msgSend;
        BOOL isSingleton = sigletonImp([implClass class], @selector(singleton));
        if (isSingleton) {
            if ([[implClass class] respondsToSelector:@selector(sharedInstance)])
                implInstance = [[implClass class] performSelector:@selector(sharedInstance)];
            else
                implInstance = [[implClass alloc] init];
            if (shouldCache) {
                [_allServiceInstanceDict setObject:implInstance forKey:serviceStr];
                return implInstance;
            } else {
                return implInstance;
            }
        }
    }
#pragma clang diagnostic pop
    return [[implClass alloc] init];
}

- (id)serviceImplClass:(Protocol *)service {
    NSString *classname = [_allServiceDict valueForKey:NSStringFromProtocol(service)];
    return NSClassFromString(classname);
}

- (id)getServiceInstanceForServiceName:(NSString *)serviceName {
    return [_allServiceInstanceDict objectForKey:serviceName];
}

- (void)removeServiceInstanceForServiceName:(NSString *)serviceName {
    [_allServiceInstanceDict removeObjectForKey:serviceName];
}

@end
