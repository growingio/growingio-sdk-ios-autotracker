//
//  GrowingConstApi.h
//  GrowingAnalytics
//
//  Created by GrowingIO on 15/10/27.
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

#ifndef GrowingConstApi_h
#define GrowingConstApi_h

#define kGrowingEventApiTemplate @"v3/projects/%@/collect?stm=%llu"

#endif /* GrowingConstApi_h */

@interface GrowingNetworkConfig : NSObject

@property (nonatomic, copy) NSString *customDataHost;

+ (instancetype)sharedInstance;

/// 返回 growingApiHostEnd 拼接的事件上传地址 eg:https://napi.growingio.com/v3/projects/91eaf9b283361032/collect
+ (NSString *)absoluteURL;

/// 返回url path eg:v3/projects/91eaf9b283361032/collect
+ (NSString *)path;

/// 返回GrowingTrackConfiguration配置的dataCollectionServerHost，如果没有额外配置该参数的话，默认返回 https://napi.growingio.com
- (NSString *)growingApiHostEnd;

@end
