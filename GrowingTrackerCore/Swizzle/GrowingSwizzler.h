//  Created by Alex Hofsteede on 1/5/14.
//  Copyright (c) 2014 Mixpanel. All rights reserved.
//  Methods and Category have been renamed to namespace to GrowingIO iOS SDK
//  Add some Methods to adapt other cases
//
//  GrowingSwizzler.h
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

#import <Foundation/Foundation.h>

// Cast to turn things that are not ids into NSMapTable keys
#define GROWING_MAPTABLE_ID(x) (__bridge id)((void *)x)

// Ignore the warning cause we need the paramters to be dynamic and it's only being used internally
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-prototypes"
typedef void (^growingSwizzleBlock)();
#pragma clang diagnostic pop

NS_ASSUME_NONNULL_BEGIN

@interface GrowingSwizzler : NSObject
//setDelegate时，返回正确的delegate
+ (id)realDelegate:(id)proxy toSelector:(SEL)selector;
+ (BOOL)realDelegateClass:(Class)cls respondsToSelector:(SEL)sel;
+ (void)growing_swizzleSelector:(SEL)aSelector
                        onClass:(Class)aClass
                      withBlock:(growingSwizzleBlock)aBlock
                          named:(NSString *)aName;
+ (void)growing_unswizzleSelector:(SEL)aSelector onClass:(Class)aClass named:(NSString *)aName;
+ (void)growing_printSwizzles;

@end

NS_ASSUME_NONNULL_END
