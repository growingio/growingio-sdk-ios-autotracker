//
//  GrowingDeepLinkHandler+Private.h
//  GrowingAnalytics
//
//  Created by YoloMao on 2024/02/20.
//  Copyright (C) 2024 Beijing Yishu Technology Co., Ltd.
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

#import "GrowingDeepLinkHandler.h"

NS_ASSUME_NONNULL_BEGIN

@protocol GrowingDeepLinkHandlerProtocol <NSObject>

/// 处理url，如果能够处理则返回YES,否则返回NO
/// @param url 链接Url
- (BOOL)growingHandleURL:(NSURL *)url;

@end

@interface GrowingDeepLinkHandler (Private)

+ (instancetype)sharedInstance;

- (void)addHandlersObject:(id)object;
- (void)removeHandlersObject:(id)object;

@end

NS_ASSUME_NONNULL_END
