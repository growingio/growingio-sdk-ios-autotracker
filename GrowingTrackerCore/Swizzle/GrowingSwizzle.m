//  The MIT License (MIT)
//
//  Copyright (c) 2007-2011 Jonathan 'Wolf' Rentzsch
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//
//  https://github.com/rentzsch/jrswizzle
//
//  GrowingSwizzle.m
//  GrowingAnalytics
//
//  Created by GrowingIO on 2020/7/22.
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

#import "GrowingTrackerCore/Swizzle/GrowingSwizzle.h"

#if TARGET_OS_IPHONE
    #import <objc/runtime.h>
    #import <objc/message.h>
#else
    #import <objc/objc-class.h>
#endif

#define GrowingSetNSErrorFor(FUNC, ERROR_VAR, FORMAT,...)    \
    if (ERROR_VAR) {    \
        NSString *errStr = [NSString stringWithFormat:@"%s: " FORMAT,FUNC,##__VA_ARGS__]; \
        *ERROR_VAR = [NSError errorWithDomain:@"NSCocoaErrorDomain" \
                                         code:-1    \
                                     userInfo:[NSDictionary dictionaryWithObject:errStr forKey:NSLocalizedDescriptionKey]]; \
    }
#define GrowingSetNSError(ERROR_VAR, FORMAT,...) GrowingSetNSErrorFor(__func__, ERROR_VAR, FORMAT, ##__VA_ARGS__)

#if OBJC_API_VERSION >= 2
#define GrowingGetClass(obj)    object_getClass(obj)
#else
#define GrowingGetClass(obj)    (obj ? obj->isa : Nil)
#endif

@implementation NSObject (GrowingSwizzle)

+ (BOOL)growing_swizzleMethod:(SEL)origSel_ withMethod:(SEL)altSel_ error:(NSError *__autoreleasing  _Nullable *)error_ {
#if OBJC_API_VERSION >= 2
    Method origMethod = class_getInstanceMethod(self, origSel_);
    if (!origMethod) {
#if TARGET_OS_IPHONE
        GrowingSetNSError(error_, @"original method %@ not found for class %@", NSStringFromSelector(origSel_), [self class]);
#else
        GrowingSetNSError(error_, @"original method %@ not found for class %@", NSStringFromSelector(origSel_), [self className]);
#endif
        return NO;
    }
    
    Method altMethod = class_getInstanceMethod(self, altSel_);
    if (!altMethod) {
#if TARGET_OS_IPHONE
        GrowingSetNSError(error_, @"alternate method %@ not found for class %@", NSStringFromSelector(altSel_), [self class]);
#else
        GrowingSetNSError(error_, @"alternate method %@ not found for class %@", NSStringFromSelector(altSel_), [self className]);
#endif
        return NO;
    }
    
    class_addMethod(self,
                    origSel_,
                    class_getMethodImplementation(self, origSel_),
                    method_getTypeEncoding(origMethod));
    class_addMethod(self,
                    altSel_,
                    class_getMethodImplementation(self, altSel_),
                    method_getTypeEncoding(altMethod));
    
    method_exchangeImplementations(class_getInstanceMethod(self, origSel_), class_getInstanceMethod(self, altSel_));
    return YES;
#else
    //    Scan for non-inherited methods.
    Method directOriginalMethod = NULL, directAlternateMethod = NULL;
    
    void *iterator = NULL;
    struct objc_method_list *mlist = class_nextMethodList(self, &iterator);
    while (mlist) {
        int method_index = 0;
        for (; method_index < mlist->method_count; method_index++) {
            if (mlist->method_list[method_index].method_name == origSel_) {
                assert(!directOriginalMethod);
                directOriginalMethod = &mlist->method_list[method_index];
            }
            if (mlist->method_list[method_index].method_name == altSel_) {
                assert(!directAlternateMethod);
                directAlternateMethod = &mlist->method_list[method_index];
            }
        }
        mlist = class_nextMethodList(self, &iterator);
    }
    
    //    If either method is inherited, copy it up to the target class to make it non-inherited.
    if (!directOriginalMethod || !directAlternateMethod) {
        Method inheritedOriginalMethod = NULL, inheritedAlternateMethod = NULL;
        if (!directOriginalMethod) {
            inheritedOriginalMethod = class_getInstanceMethod(self, origSel_);
            if (!inheritedOriginalMethod) {
                SetNSError(error_, @"original method %@ not found for class %@", NSStringFromSelector(origSel_), [self className]);
                return NO;
            }
        }
        if (!directAlternateMethod) {
            inheritedAlternateMethod = class_getInstanceMethod(self, altSel_);
            if (!inheritedAlternateMethod) {
                SetNSError(error_, @"alternate method %@ not found for class %@", NSStringFromSelector(altSel_), [self className]);
                return NO;
            }
        }
        
        int hoisted_method_count = !directOriginalMethod && !directAlternateMethod ? 2 : 1;
        struct objc_method_list *hoisted_method_list = malloc(sizeof(struct objc_method_list) + (sizeof(struct objc_method)*(hoisted_method_count-1)));
        hoisted_method_list->obsolete = NULL;    // soothe valgrind - apparently ObjC runtime accesses this value and it shows as uninitialized in valgrind
        hoisted_method_list->method_count = hoisted_method_count;
        Method hoisted_method = hoisted_method_list->method_list;
        
        if (!directOriginalMethod) {
            bcopy(inheritedOriginalMethod, hoisted_method, sizeof(struct objc_method));
            directOriginalMethod = hoisted_method++;
        }
        if (!directAlternateMethod) {
            bcopy(inheritedAlternateMethod, hoisted_method, sizeof(struct objc_method));
            directAlternateMethod = hoisted_method;
        }
        class_addMethods(self, hoisted_method_list);
    }
    
    //    Swizzle.
    IMP temp = directOriginalMethod->method_imp;
    directOriginalMethod->method_imp = directAlternateMethod->method_imp;
    directAlternateMethod->method_imp = temp;
    
    return YES;
#endif
}

+ (BOOL)growing_swizzleClassMethod:(SEL)origSel_ withClassMethod:(SEL)altSel_ error:(NSError *__autoreleasing  _Nullable *)error_ {
    return [GrowingGetClass((id)self) growing_swizzleMethod:origSel_ withMethod:altSel_ error:error_];
}

+ (nullable NSInvocation *)growing_swizzleMethod:(SEL)origSel withBlock:(id)block error:(NSError **)error {
    IMP blockIMP = imp_implementationWithBlock(block);
    NSString *blockSelectorString = [NSString stringWithFormat:@"_growing_block_%@_%p", NSStringFromSelector(origSel), block];
    SEL blockSel = sel_registerName([blockSelectorString cStringUsingEncoding:NSUTF8StringEncoding]);
    Method origSelMethod = class_getInstanceMethod(self, origSel);
    const char* origSelMethodArgs = method_getTypeEncoding(origSelMethod);
    class_addMethod(self, blockSel, blockIMP, origSelMethodArgs);

    NSMethodSignature *origSig = [NSMethodSignature signatureWithObjCTypes:origSelMethodArgs];
    NSInvocation *origInvocation = [NSInvocation invocationWithMethodSignature:origSig];
    origInvocation.selector = blockSel;

    [self growing_swizzleMethod:origSel withMethod:blockSel error:nil];

    return origInvocation;
}

+ (nullable NSInvocation *)growing_swizzleClassMethod:(SEL)origSel withBlock:(id)block error:(NSError **)error {
    NSInvocation *invocation = [GrowingGetClass((id)self) growing_swizzleMethod:origSel withBlock:block error:error];
    invocation.target = self;

    return invocation;
}

@end
