//
//  NSURLSession+TestHook.m
//  GrowingSDKTest
//
//  Created by smart on 2018/3/21.
//  Copyright (C) 2018 Beijing Yishu Technology Co., Ltd.
//

#import "NSURLSession+TestHook.h"

#import <objc/runtime.h>

@implementation NSURLSession (TestHook)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class clazz = NSClassFromString(@"NSURLSession");
        
        SEL originalSelector = @selector(dataTaskWithRequest:completionHandler:);
        SEL swizzledSelector = @selector(grow_dataTaskWithRequest:completionHandler:);
        
        Method originalMethod = class_getInstanceMethod(clazz, originalSelector);
        Method swizzledMethod = class_getInstanceMethod([self class], swizzledSelector);
        
        BOOL didAddMethod =
        class_addMethod(clazz,
                        originalSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod));
        
        if (didAddMethod) {
            class_replaceMethod(clazz,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

static NSMutableDictionary *kGlobalHandlerInfo = nil;
+ (void)setTestHandler:(GrowCompletionHandler)handler forKey:(NSString *)key {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kGlobalHandlerInfo = [NSMutableDictionary dictionary];
    });
    
    kGlobalHandlerInfo[key] = handler;
}

+ (GrowCompletionHandler)testHandlerForKey:(NSString *)key {
    return kGlobalHandlerInfo[key];
}

static NSMutableArray *kURLSuccessArray = nil;
+ (void)setURLSuccessArray:(NSMutableArray *)array {
    kURLSuccessArray = array;
}

+ (NSMutableArray *)URLSuccessArray {
    return kURLSuccessArray;
}

- (NSURLSessionDataTask *)grow_dataTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler {
    GrowCompletionHandler growCompletionHandler = ^(NSData * _Nullable data,
                                                    NSURLResponse * _Nullable _response,
                                                    NSError * _Nullable connectionError) {
        if (kURLSuccessArray) {
            // 存储请求成功的URL到数组中
            NSHTTPURLResponse *response = (id)_response;
            if (response.statusCode == 200) {
                [kURLSuccessArray addObject:response.URL.absoluteString];
            }
        }
        
        // 原始自定义回调block
        if (completionHandler) {
            completionHandler(data,_response, connectionError);
        }
        
        // 测试回调block
        [kGlobalHandlerInfo enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            ((GrowCompletionHandler)obj)(data,_response, connectionError);
        }];
    };
    
    return [self grow_dataTaskWithRequest:request completionHandler:growCompletionHandler];
}

@end
