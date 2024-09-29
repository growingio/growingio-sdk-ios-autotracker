//
//  GrowingTrackConfiguration.h
//  GrowingAnalytics
//
//  Created by xiangyang on 2020/11/6.
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

#import <Foundation/Foundation.h>
#import "GrowingEventFilter.h"
#import "GrowingFieldsIgnore.h"
#import "GrowingNetworkConfig.h"

FOUNDATION_EXPORT NSString *const kGrowingDefaultDataCollectionServerHost;

@interface GrowingTrackConfiguration : NSObject <NSCopying>

@property (nonatomic, copy, readonly) NSString *accountId;
@property (nonatomic, copy) NSString *dataSourceId;
@property (nonatomic, assign) BOOL debugEnabled;
@property (nonatomic, assign) NSUInteger cellularDataLimit;
@property (nonatomic, assign) NSTimeInterval dataUploadInterval;
@property (nonatomic, assign) NSTimeInterval sessionInterval;
@property (nonatomic, assign) BOOL dataCollectionEnabled;
@property (nonatomic, assign) BOOL uploadExceptionEnable;
@property (nonatomic, copy) NSString *dataCollectionServerHost;
@property (nonatomic, assign) NSUInteger excludeEvent;
@property (nonatomic, assign) NSUInteger ignoreField;
@property (nonatomic, assign) BOOL idMappingEnabled;
@property (nonatomic, copy) NSString *urlScheme;
@property (nonatomic, assign) BOOL encryptEnabled;
@property (nonatomic, assign) BOOL compressEnabled;
@property (nonatomic, copy) GrowingNetworkConfig *networkConfig;
@property (nonatomic, assign) BOOL useProtobuf;
@property (nonatomic, assign) NSUInteger dataValidityPeriod;
@property (nonatomic, assign) BOOL customEventWithPath;

- (instancetype)initWithAccountId:(NSString *)accountId;

+ (instancetype)configurationWithAccountId:(NSString *)accountId;
+ (instancetype)configurationWithProjectId:(NSString *)accountId;

@end
