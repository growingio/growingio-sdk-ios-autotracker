//
//  GrowingMediator.m
//  GrowingTracker
//
//  Created by GrowingIO on 2018/4/16.
//  Copyright (C) 2018 Beijing Yishu Technology Co., Ltd.
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


#import "GrowingMediator.h"
#import <objc/runtime.h>

@interface GrowingMediator ()

@end

@implementation GrowingMediator

+ (instancetype)sharedInstance
{
    static GrowingMediator *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[GrowingMediator alloc] init];
    });
    return instance;
}

- (id)performClass:(NSString *)className action:(NSString *)actionName params:(NSDictionary *)params
{
    Class class = NSClassFromString(className);
    // 没有该类直接return
    if (!class) {
        return nil;
    }
    
    SEL action = NSSelectorFromString(actionName);
    // 没有响应sel直接return
    if (![class respondsToSelector:action]) {
        return nil;
    }
    
    id ret = [self safePerformAction:action target:class params:params isClass:YES];
    
    return ret;
}

- (id)performTarget:(NSObject *)target action:(NSString *)actionName params:(NSDictionary *)params
{
    if (!target) {
        return nil;
    }
    
    SEL action = NSSelectorFromString(actionName);
    // 没有响应sel直接return
    if (![target respondsToSelector:action]) {
        return nil;
    }
    
    id ret = [self safePerformAction:action target:target params:params isClass:NO];
    
    return ret;

}

- (id)safePerformAction:(SEL)action target:(id)target params:(NSDictionary *)params isClass:(BOOL)isClass
{
    NSMethodSignature *methodSig = [target methodSignatureForSelector:action];
    // 没有方法签名直接return
    if (!methodSig) {
        return nil;
    }
    
    Method method;
    if (isClass) {
        method = class_getClassMethod(target, action);
    } else {
        method = class_getInstanceMethod([target class], action);
    }
    int argumentsNumber = method_getNumberOfArguments(method);
    argumentsNumber = argumentsNumber - 2;
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
    [invocation setSelector:action];
    [invocation setTarget:target];
    
    for (int i = 0; i < argumentsNumber; i++) {
        id argument = params[[NSString stringWithFormat:@"%d",i]];
        
        if ([argument isKindOfClass:[NSNumber class]]) {
            
            NSNumber *number = argument;
            const char* argumentType = [methodSig getArgumentTypeAtIndex:i+2];
            
            if (strcmp(argumentType, @encode(int)) == 0) {
                int arg = number.intValue;
                [invocation setArgument:&arg atIndex:i+2];
            } else if (strcmp(argumentType, @encode(unsigned int)) == 0) {
                unsigned int arg = number.unsignedIntValue;
                [invocation setArgument:&arg atIndex:i+2];
            } else if (strcmp(argumentType, @encode(long)) == 0) {
                long arg  = number.longValue;
                [invocation setArgument:&arg atIndex:i+2];
            } else if (strcmp(argumentType, @encode(unsigned long)) == 0) {
                unsigned long arg = number.longValue;
                [invocation setArgument:&arg atIndex:i+2];
            } else if (strcmp(argumentType, @encode(long long)) == 0) {
                long long arg = number.longLongValue;
                [invocation setArgument:&arg atIndex:i+2];
            } else if (strcmp(argumentType, @encode(unsigned long long)) == 0) {
                unsigned long long arg = number.unsignedLongLongValue;
                [invocation setArgument:&arg atIndex:i+2];
            } else if (strcmp(argumentType, @encode(float)) == 0) {
                float arg = number.floatValue;
                [invocation setArgument:&arg atIndex:i+2];
            } else if (strcmp(argumentType, @encode(double)) == 0) {
                double arg = number.doubleValue;
                [invocation setArgument:&arg atIndex:i+2];
            } else if (strcmp(argumentType, @encode(BOOL)) == 0) {
                BOOL arg = number.boolValue;
                [invocation setArgument:&arg atIndex:i+2];
            } else if (strcmp(argumentType, @encode(NSInteger)) == 0) {
                NSInteger arg = number.integerValue;
                [invocation setArgument:&arg atIndex:i+2];
            } else if (strcmp(argumentType, @encode(NSUInteger)) == 0) {
                NSUInteger arg = number.unsignedIntegerValue;
                [invocation setArgument:&arg atIndex:i+2];
            } else {
                // 异常
            }
            
        } else {
            [invocation setArgument:&argument atIndex:i+2];
        }
        
    }
    
    [invocation invoke];

    const char* retType = [methodSig methodReturnType];

    if (strcmp(retType, @encode(int)) == 0) {
        int ret = 0;
        [invocation getReturnValue:&ret];
        return @(ret);
    } else if (strcmp(retType, @encode(unsigned int)) == 0) {
        unsigned int ret = 0;
        [invocation getReturnValue:&ret];
        return @(ret);
    } else if (strcmp(retType, @encode(long)) == 0) {
        long ret = 0;
        [invocation getReturnValue:&ret];
        return @(ret);
    } else if (strcmp(retType, @encode(unsigned long)) == 0) {
        unsigned long ret = 0;
        [invocation getReturnValue:&ret];
        return @(ret);
    } else if (strcmp(retType, @encode(long long)) == 0) {
        long long ret = 0;
        [invocation getReturnValue:&ret];
        return @(ret);
    } else if (strcmp(retType, @encode(unsigned long long)) == 0) {
        unsigned long long ret = 0;
        [invocation getReturnValue:&ret];
        return @(ret);
    } else if (strcmp(retType, @encode(float)) == 0) {
        float ret = 0;
        [invocation getReturnValue:&ret];
        return @(ret);
    } else if (strcmp(retType, @encode(double)) == 0) {
        double ret = 0;
        [invocation getReturnValue:&ret];
        return @(ret);
    } else if (strcmp(retType, @encode(BOOL)) == 0) {
        BOOL ret = 0;
        [invocation getReturnValue:&ret];
        return @(ret);
    } else if (strcmp(retType, @encode(NSInteger)) == 0) {
        NSInteger ret = 0;
        [invocation getReturnValue:&ret];
        return @(ret);
    } else if (strcmp(retType, @encode(NSUInteger)) == 0) {
        NSUInteger ret = 0;
        [invocation getReturnValue:&ret];
        return @(ret);
    } else if (strcmp(retType, @encode(void)) == 0) {
        return nil;
    } else {
        NSObject * __unsafe_unretained ret;
        [invocation getReturnValue:&ret];
        NSObject *objRet = ret;
        return objRet;
    }
}


@end
