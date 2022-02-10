//
//  InvocationHelper.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2022/1/17.
//  Copyright (C) 2021 Beijing Yishu Technology Co., Ltd.
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

#import "InvocationHelper.h"
#import <CoreGraphics/CoreGraphics.h>
#import <objc/runtime.h>

@interface InvocationHelper ()

+ (id)performSelector:(SEL)selector target:(id)target arguments:(va_list)arguments;

@end

@implementation NSObject (InvocationHelper)

+ (id)safePerformSelector:(SEL)selector {
    return [self safePerformSelector:selector arguments:nil];
}

+ (id)safePerformSelector:(SEL)selector arguments:(id _Nullable)arguments, ... {
    if (!arguments) {
        return [InvocationHelper performSelector:selector target:(id)self arguments:nil];
    }

    va_list args;
    va_start(args, arguments);
    id result = [InvocationHelper performSelector:selector target:(id)self arguments:args];
    va_end(args);
    return result;
}

- (id)safePerformSelector:(SEL)selector {
    return [self safePerformSelector:selector arguments:nil];
}

- (id)safePerformSelector:(SEL)selector arguments:(id _Nullable)arguments, ... {
    if (!arguments) {
        return [InvocationHelper performSelector:selector target:self arguments:nil];
    }

    va_list args;
    va_start(args, arguments);
    id result = [InvocationHelper performSelector:selector target:self arguments:args];
    va_end(args);
    return result;
}

@end

/// 参考：
/// [CTMediator](https://github.com/casatwy/CTMediator)
/// [NSInvocation-Block](https://github.com/deput/NSInvocation-Block)
@implementation InvocationHelper

+ (id)performSelector:(SEL)selector target:(id)target arguments:(va_list)arguments {
    NSMethodSignature *methodSig = [target methodSignatureForSelector:selector];
    if (methodSig == nil) {
        return nil;
    }
    const char *retType = [methodSig methodReturnType];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
    [self invocationInvoke:invocation target:target selector:selector arguments:arguments];

    if (strcmp(retType, @encode(void)) == 0) {
        return nil;
    }

    if (strcmp(retType, @encode(NSInteger)) == 0) {
        NSInteger result = 0;
        [invocation getReturnValue:&result];
        return @(result);
    }

    if (strcmp(retType, @encode(BOOL)) == 0) {
        BOOL result = 0;
        [invocation getReturnValue:&result];
        return @(result);
    }

    if (strcmp(retType, @encode(CGFloat)) == 0) {
        CGFloat result = 0;
        [invocation getReturnValue:&result];
        return @(result);
    }

    if (strcmp(retType, @encode(NSUInteger)) == 0) {
        NSUInteger result = 0;
        [invocation getReturnValue:&result];
        return @(result);
    }

    // retType[0] == '@'
    id result = nil;
    [invocation getReturnValue:&result];
    return result;
}

#define ARG_GET_SET(type)                            \
    do {                                             \
        type val = 0;                                \
        val = va_arg(args, type);                    \
        [invocation setArgument:&val atIndex:i + 2]; \
    } while (0)
+ (void)invocationInvoke:(NSInvocation *)invocation target:(id)target selector:(SEL)selector arguments:(va_list)args {
    if (!args) {
        [invocation setSelector:selector];
        [invocation setTarget:target];
        [invocation invoke];
        return;
    }
    NSUInteger argsCount = invocation.methodSignature.numberOfArguments - 2;
    for (NSUInteger i = 0; i < argsCount; ++i) {
        const char *argType = [invocation.methodSignature getArgumentTypeAtIndex:i + 2];
        if (argType[0] == _C_CONST)
            argType++;
        if (argType[0] == '@') {  // id and block
            ARG_GET_SET(id);
        } else if (strcmp(argType, @encode(Class)) == 0) {  // Class
            ARG_GET_SET(Class);
        } else if (strcmp(argType, @encode(IMP)) == 0) {  // IMP
            ARG_GET_SET(IMP);
        } else if (strcmp(argType, @encode(SEL)) == 0) {  // SEL
            ARG_GET_SET(SEL);
        } else if (strcmp(argType, @encode(double)) == 0) {  // double
            ARG_GET_SET(double);
        } else if (strcmp(argType, @encode(float)) == 0) {  // float
            float val = 0;
            val = (float)va_arg(args, double);
            [invocation setArgument:&val atIndex:i + 2];
        } else if (argType[0] == '^') {  // pointer ( andconst pointer)
            ARG_GET_SET(void *);
        } else if (strcmp(argType, @encode(char *)) == 0) {  // char* (and const char*)
            ARG_GET_SET(char *);
        } else if (strcmp(argType, @encode(unsigned long)) == 0) {
            ARG_GET_SET(unsigned long);
        } else if (strcmp(argType, @encode(unsigned long long)) == 0) {
            ARG_GET_SET(unsigned long long);
        } else if (strcmp(argType, @encode(long)) == 0) {
            ARG_GET_SET(long);
        } else if (strcmp(argType, @encode(long long)) == 0) {
            ARG_GET_SET(long long);
        } else if (strcmp(argType, @encode(int)) == 0) {
            ARG_GET_SET(int);
        } else if (strcmp(argType, @encode(unsigned int)) == 0) {
            ARG_GET_SET(unsigned int);
        } else if (strcmp(argType, @encode(BOOL)) == 0 || strcmp(argType, @encode(bool)) == 0
                   || strcmp(argType, @encode(char)) == 0 || strcmp(argType, @encode(unsigned char)) == 0
                   || strcmp(argType, @encode(short)) == 0 || strcmp(argType, @encode(unsigned short)) == 0) {
            ARG_GET_SET(int);
        } else {
            // struct union and array
            assert(false && "struct union array unsupported!");
        }
    }

    [invocation setSelector:selector];
    [invocation setTarget:target];
    [invocation invoke];
}

@end
