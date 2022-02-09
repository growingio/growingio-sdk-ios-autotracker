//  Created by Alex Hofsteede on 1/5/14.
//  Copyright (c) 2014 Mixpanel. All rights reserved.
//  Methods and Category have been renamed to namespace to GrowingIO iOS SDK
//  Add some Methods to adapt other cases
//
//  GrowingSwizzler.m
//  GrowingAnalytics
//
//  Created by GrowingIO on 2020/7/23.
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


#import "GrowingSwizzler.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "GrowingLogger.h"

#define GROWING_MIN_ARGS 2
#define GROWING_MAX_ARGS 5

@interface GrowingSwizzleEntity : NSObject

@property (nonatomic, assign) Class class;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, assign) IMP originalMethod;
@property (nonatomic, assign) uint numArgs;
@property (nonatomic, copy) NSMapTable *blocks;

- (instancetype)initWithBlock:(growingSwizzleBlock)aBlock
                        named:(NSString *)aName
                     forClass:(Class)aClass
                     selector:(SEL)aSelector
               originalMethod:(IMP)aMethod
                  withNumArgs:(uint)numArgs;

@end


@implementation GrowingSwizzleEntity

- (instancetype)init {
    if ((self = [super init])) {
        self.blocks = [NSMapTable mapTableWithKeyOptions:(NSPointerFunctionsStrongMemory | NSPointerFunctionsObjectPersonality)
                                            valueOptions:(NSPointerFunctionsStrongMemory | NSPointerFunctionsObjectPointerPersonality)];
    }
    return self;
}

- (instancetype)initWithBlock:(growingSwizzleBlock)aBlock
                        named:(NSString *)aName
                     forClass:(Class)aClass
                     selector:(SEL)aSelector
               originalMethod:(IMP)aMethod
                  withNumArgs:(uint)numArgs {
    if ((self = [self init])) {
        self.class = aClass;
        self.selector = aSelector;
        self.numArgs = numArgs;
        self.originalMethod = aMethod;
        [self.blocks setObject:aBlock forKey:aName];
    }
    return self;
}

- (NSString *)description {
    NSString *descriptors = @"";
    NSString *key;
    NSEnumerator *keys = [self.blocks keyEnumerator];
    while ((key = [keys nextObject])) {
        descriptors = [descriptors stringByAppendingFormat:@"\t%@ : %@\n", key, [self.blocks objectForKey:key]];
    }
    return [NSString stringWithFormat:@"Swizzle on %@::%@ [\n%@]", NSStringFromClass(self.class), NSStringFromSelector(self.selector), descriptors];
}

@end

static NSMapTable *growingSwizzles;

static void growing_swizzledMethod_2(id self, SEL _cmd) {
    Method aMethod = class_getInstanceMethod([self class], _cmd);
    GrowingSwizzleEntity *swizzle = (GrowingSwizzleEntity *)[growingSwizzles objectForKey:GROWING_MAPTABLE_ID(aMethod)];
    if (swizzle) {
        ((void(*)(id, SEL))swizzle.originalMethod)(self, _cmd);

        NSEnumerator *blocks = [swizzle.blocks objectEnumerator];
        growingSwizzleBlock block;
        while ((block = [blocks nextObject])) {
            block(self, _cmd);
        }
    }
}

static void growing_swizzledMethod_3(id self, SEL _cmd, id arg) {
    Method aMethod = class_getInstanceMethod([self class], _cmd);
    GrowingSwizzleEntity *swizzle = (GrowingSwizzleEntity *)[growingSwizzles objectForKey:GROWING_MAPTABLE_ID(aMethod)];
    if (swizzle) {
        ((void(*)(id, SEL, id))swizzle.originalMethod)(self, _cmd, arg);

        NSEnumerator *blocks = [swizzle.blocks objectEnumerator];
        growingSwizzleBlock block;
        while ((block = [blocks nextObject])) {
            block(self, _cmd, arg);
        }
    }
}

static void growing_swizzledMethod_4(id self, SEL _cmd, id arg, id arg2) {
    Method aMethod = class_getInstanceMethod([self class], _cmd);
    GrowingSwizzleEntity *swizzle = (GrowingSwizzleEntity *)[growingSwizzles objectForKey:(__bridge id)((void *)aMethod)];
    if (swizzle) {
        ((void(*)(id, SEL, id, id))swizzle.originalMethod)(self, _cmd, arg, arg2);

        NSEnumerator *blocks = [swizzle.blocks objectEnumerator];
        growingSwizzleBlock block;
        while ((block = [blocks nextObject])) {
            block(self, _cmd, arg, arg2);
        }
    }
}

static void growing_swizzledMethod_5(id self, SEL _cmd, id arg, id arg2, id arg3) {
    Method aMethod = class_getInstanceMethod([self class], _cmd);
    GrowingSwizzleEntity *swizzle = (GrowingSwizzleEntity *)[growingSwizzles objectForKey:(__bridge id)((void *)aMethod)];
    if (swizzle) {
        ((void(*)(id, SEL, id, id, id))swizzle.originalMethod)(self, _cmd, arg, arg2, arg3);

        NSEnumerator *blocks = [swizzle.blocks objectEnumerator];
        growingSwizzleBlock block;
        while ((block = [blocks nextObject])) {
            block(self, _cmd, arg, arg2, arg3);
        }
    }
}

// Ignore the warning cause we need the paramters to be dynamic and it's only being used internally
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-prototypes"
static void (*growing_swizzledMethods[GROWING_MAX_ARGS - GROWING_MIN_ARGS + 1])() = {growing_swizzledMethod_2, growing_swizzledMethod_3, growing_swizzledMethod_4, growing_swizzledMethod_5};
#pragma clang diagnostic pop

@implementation GrowingSwizzler

+ (void)load {
    growingSwizzles = [NSMapTable mapTableWithKeyOptions:(NSPointerFunctionsOpaqueMemory | NSPointerFunctionsOpaquePersonality)
                                     valueOptions:(NSPointerFunctionsStrongMemory | NSPointerFunctionsObjectPointerPersonality)];

}

+ (void)growing_printSwizzles {
    NSEnumerator *en = [growingSwizzles objectEnumerator];
    GrowingSwizzleEntity *swizzle;
    while ((swizzle = (GrowingSwizzleEntity *)[en nextObject])) {
        GIOLogInfo(@"%@", swizzle);
    }
}

+ (GrowingSwizzleEntity *)swizzleForMethod:(Method)aMethod {
    return (GrowingSwizzleEntity *)[growingSwizzles objectForKey:GROWING_MAPTABLE_ID(aMethod)];
}

+ (void)removeSwizzleForMethod:(Method)aMethod {
    [growingSwizzles removeObjectForKey:GROWING_MAPTABLE_ID(aMethod)];
}

+ (void)setSwizzle:(GrowingSwizzleEntity *)swizzle forMethod:(Method)aMethod {
    [growingSwizzles setObject:swizzle forKey:GROWING_MAPTABLE_ID(aMethod)];
}

+ (BOOL)isLocallyDefinedMethod:(Method)aMethod onClass:(Class)aClass {
    uint count;
    BOOL isLocal = NO;
    Method *methods = class_copyMethodList(aClass, &count);
    if (methods) {
        for (NSUInteger i = 0; i < count; i++) {
            if (aMethod == methods[i]) {
                isLocal = YES;
                break;
            }
        }
    }
    free(methods);
    return isLocal;
}

+ (Class)realDelegateClassFromSelector:(SEL)selector proxy:(id)proxy {
    if (!proxy) {
        return nil;
    }
    
    id realDelegate = proxy;
    id obj = nil;
    do {
        //避免proxy本身实现了该方法或通过resolveInstanceMethod添加了方法实现
        if (class_getInstanceMethod(object_getClass(realDelegate), selector)) {
            break;
        }
        
        //如果使用了NSProxy或者快速转发,判断forwardingTargetForSelector是否实现
        //默认forwardingTargetForSelector都有实现，只是返回为nil
        obj = ((id(*)(id, SEL, SEL))objc_msgSend)(realDelegate, @selector(forwardingTargetForSelector:), selector);
        if (!obj) break;
        realDelegate = obj;
    } while (obj);
    return object_getClass(realDelegate);
}

+ (BOOL)realDelegateClass:(Class)cls respondsToSelector:(SEL)sel {
    //如果cls继承自NSProxy，使用respondsToSelector来判断会崩溃
    //因为NSProxy本身未实现respondsToSelector
    return class_respondsToSelector(cls, sel);
}

+ (void)growing_swizzleSelector:(SEL)aSelector
                        onClass:(Class)aClass
                      withBlock:(growingSwizzleBlock)aBlock
                          named:(NSString *)aName {
    
    Method aMethod = class_getInstanceMethod(aClass, aSelector);
    
    if (!aMethod) {
        NSAssert(NO, @"SwizzlerAssert: Cannot find method for %@ on %@", NSStringFromSelector(aSelector), NSStringFromClass(aClass));
        return;
    }
    
    uint numArgs = method_getNumberOfArguments(aMethod);
    if (numArgs >= GROWING_MIN_ARGS && numArgs <= GROWING_MAX_ARGS) {
            
        BOOL isLocal = [self isLocallyDefinedMethod:aMethod onClass:aClass];
        IMP swizzledMethod = (IMP)growing_swizzledMethods[numArgs - 2];
        GrowingSwizzleEntity *swizzle = [self swizzleForMethod:aMethod];
            
        if (isLocal) {
            if (!swizzle) {
                IMP originalMethod = method_getImplementation(aMethod);
                    
                // Replace the local implementation of this method with the swizzled one
                method_setImplementation(aMethod,swizzledMethod);
                    
                // Create and add the swizzle
                swizzle = [[GrowingSwizzleEntity alloc] initWithBlock:aBlock named:aName forClass:aClass selector:aSelector originalMethod:originalMethod withNumArgs:numArgs];
                [self setSwizzle:swizzle forMethod:aMethod];
                    
            } else {
                [swizzle.blocks setObject:aBlock forKey:aName];
            }
        } else {
            IMP originalMethod = swizzle ? swizzle.originalMethod : method_getImplementation(aMethod);
                
            // Add the swizzle as a new local method on the class.
            if (!class_addMethod(aClass, aSelector, swizzledMethod, method_getTypeEncoding(aMethod))) {
                NSAssert(NO, @"SwizzlerAssert: Could not add swizzled for %@::%@, even though it didn't already exist locally", NSStringFromClass(aClass), NSStringFromSelector(aSelector));
                return;
            }
            // Now re-get the Method, it should be the one we just added.
            Method newMethod = class_getInstanceMethod(aClass, aSelector);
            if (aMethod == newMethod) {
                NSAssert(NO, @"SwizzlerAssert: Newly added method for %@::%@ was the same as the old method", NSStringFromClass(aClass), NSStringFromSelector(aSelector));
                return;
            }
                
            GrowingSwizzleEntity *newSwizzle = [[GrowingSwizzleEntity alloc] initWithBlock:aBlock named:aName forClass:aClass selector:aSelector originalMethod:originalMethod withNumArgs:numArgs];
            [self setSwizzle:newSwizzle forMethod:newMethod];
        }
    } else {
        NSAssert(NO, @"SwizzlerAssert: Cannot swizzle method with %d args", numArgs);
    }
}

+ (void)growing_unswizzleSelector:(SEL)aSelector onClass:(Class)aClass {
    Method aMethod = class_getInstanceMethod(aClass, aSelector);
    GrowingSwizzleEntity *swizzle = [self swizzleForMethod:aMethod];
    if (swizzle && aMethod) {
        method_setImplementation(aMethod, swizzle.originalMethod);
        [self removeSwizzleForMethod:aMethod];
    }
}

/*
 Remove the named swizzle from the given class/selector. If aName is nil, remove all
 swizzles for this class/selector
*/
+ (void)growing_unswizzleSelector:(SEL)aSelector onClass:(Class)aClass named:(NSString *)aName {
    Method aMethod = class_getInstanceMethod(aClass, aSelector);
       GrowingSwizzleEntity *swizzle = [self swizzleForMethod:aMethod];
       if (swizzle) {
           if (aName) {
               [swizzle.blocks removeObjectForKey:aName];
           }
           if (aMethod && (!aName || swizzle.blocks.count == 0)) {
               method_setImplementation(aMethod, swizzle.originalMethod);
               [self removeSwizzleForMethod:aMethod];
           }
       }
}


@end
