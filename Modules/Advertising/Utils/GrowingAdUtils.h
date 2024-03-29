//
//  GrowingAdUtils.h
//  GrowingAnalytics
//
//  Created by YoloMao on 2022/8/29.
//  Copyright (C) 2022 Beijing Yishu Technology Co., Ltd.
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

NS_ASSUME_NONNULL_BEGIN

@interface GrowingAdUtils : NSObject

+ (BOOL)isGrowingIOUrl:(NSURL *)url;

+ (BOOL)isShortChainUlink:(NSURL *)url;

+ (NSString *)URLDecodedString:(NSString *)urlString;

+ (nullable NSDictionary *)dictFromPasteboard:(NSString *_Nullable)clipboardString;

+ (void)setActivateDefer:(BOOL)activateDefer;

+ (BOOL)isActivateDefer;

+ (void)setActivateWrote:(BOOL)activateWrote;

+ (BOOL)isActivateWrote;

+ (void)setActivateSent:(BOOL)activateSent;

+ (BOOL)isActivateSent;

@end

NS_ASSUME_NONNULL_END
