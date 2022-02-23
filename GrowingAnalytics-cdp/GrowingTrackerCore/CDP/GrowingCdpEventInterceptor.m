//
//  GrowingCdpEventInterceptor.m
//  GrowingAnalytics-cdp
//
//  Created by sheng on 2020/11/24.
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

#import "GrowingCdpEventInterceptor.h"
#import "GrowingPersistenceDataProvider.h"

NSString *kGrowingUserdefault_gioId = @"growingio.userdefault.gioId";

@implementation GrowingCdpEventInterceptor

@synthesize gioId = _gioId;

- (instancetype)initWithSourceId:(NSString *)dataSourceId {
    if (self = [super init]) {
        _dataSourceId = dataSourceId;
    }
    return self;
}

#pragma mark - GrowingEventInterceptor

- (void)growingEventManagerEventWillBuild:(GrowingBaseBuilder * _Nullable)builder {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:self.dataSourceId forKey:@"dataSourceId"];
    if (self.gioId.length > 0) {
        [dict setValue:self.gioId forKey:@"gioId"];
    }
    builder.setExtraParams(dict);
}

#pragma mark - GrowingUserIdChangedDelegate

- (void)userIdDidChangedFrom:(NSString *)oldUserId to:(NSString *)newUserId {
    if (newUserId.length > 0 && ![_gioId isEqualToString:newUserId]) {
        [self setGioId:newUserId];
    }
}

#pragma mark - Setter & Getter

- (void)setGioId:(NSString * _Nonnull)gioId {
    _gioId = gioId;
    [[GrowingPersistenceDataProvider sharedInstance] setString:gioId forKey:kGrowingUserdefault_gioId];
}

- (NSString *)gioId {
    return [[GrowingPersistenceDataProvider sharedInstance] getStringforKey:kGrowingUserdefault_gioId];
}

@end
