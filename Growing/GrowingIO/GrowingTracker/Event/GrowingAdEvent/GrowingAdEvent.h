//
//  GrowingAdEvent.h
//  GrowingTracker
//
//  Created by GrowingIO on 2020/5/28.
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


#import "GrowingEvent.h"

NS_ASSUME_NONNULL_BEGIN

@interface GrowingDeeplinkInfo : NSObject

@property (nonatomic, copy, readonly) NSString * _Nullable linkId;
@property (nonatomic, copy, readonly) NSString * _Nullable clickId;
@property (nonatomic, copy, readonly) NSString * _Nullable clickTime;
@property (nonatomic, copy, readonly) NSString * _Nullable userAgent;
@property (nonatomic, copy, readonly) NSString * _Nullable cl;

@property (nonatomic, copy) NSDictionary * _Nullable customParams;
@property (nonatomic, copy) NSString * _Nullable renngageMechanism;

- (instancetype)initWithLinkId:(NSString * _Nullable)linkId
                       clickId:(NSString * _Nullable)clickId
                     clickTime:(NSString * _Nullable)clickTime;

- (instancetype)initWithLinkId:(NSString * _Nullable)linkId
                       clickId:(NSString * _Nullable)clickId
                     clickTime:(NSString * _Nullable)clickTime
                     userAgent:(NSString * _Nullable)ua
                            cl:(NSString * _Nullable)cl;

- (instancetype)initWithQueryDict:(NSDictionary *)queryDict;

@end


@interface GrowingAdEvent : GrowingEvent

@property (nonatomic, strong, readonly) GrowingDeeplinkInfo *deeplinkInfo;

+ (void)sendEventWithDeeplinkInfo:(GrowingDeeplinkInfo *)deeplinkInfo;

@end

NS_ASSUME_NONNULL_END

