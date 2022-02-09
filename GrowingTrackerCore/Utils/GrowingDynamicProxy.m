//
// GrowingDynamicProxy.m
// GrowingAnalytics
//
//  Created by sheng on 2020/11/25.
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


#import "GrowingDynamicProxy.h"
#import "GrowingLogMacros.h"
#import "GrowingLogger.h"

@implementation GrowingDynamicProxy

- (instancetype)initWithTarget:(id)target {
    _target = target;
    return self;
}

+ (instancetype)proxyWithTarget:(id)target {
    return [[GrowingDynamicProxy alloc] initWithTarget:target];
}

- (id)forwardingTargetForSelector:(SEL)selector {
    return _target;
}

//慢速转发
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    NSMethodSignature *ms = [_target methodSignatureForSelector:aSelector];
    if (ms) {
        return ms;
    }
    return [NSMethodSignature signatureWithObjCTypes:"v@:"];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    if (!_target || ![_target respondsToSelector:[invocation selector]]) {
        GIOLogError(@"%@ doesNotRecognizeSelector named : %@",NSStringFromClass([self class]),NSStringFromSelector([invocation selector]));
    }
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return [_target respondsToSelector:aSelector];
}

- (BOOL)isEqual:(id)object {
    return [_target isEqual:object];
}

- (NSUInteger)hash {
    return [_target hash];
}

- (Class)superclass {
    return [_target superclass];
}

- (Class)class {
    return [_target class];
}

- (BOOL)isKindOfClass:(Class)aClass {
    return [_target isKindOfClass:aClass];
}

- (BOOL)isMemberOfClass:(Class)aClass {
    return [_target isMemberOfClass:aClass];
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol {
    return [_target conformsToProtocol:aProtocol];
}

- (BOOL)isProxy {
    return YES;
}

- (NSString *)description {
    return [_target description];
}

- (NSString *)debugDescription {
    return [_target debugDescription];
}

//- (void)forwardInvocation:(NSInvocation *)invocation {
//    void *null = NULL;
//    [invocation setReturnValue:&null];
//}
//
//- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
//    return [NSObject instanceMethodSignatureForSelector:@selector(init)];
//}


@end
