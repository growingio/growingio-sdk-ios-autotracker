//
//  GrowingDataSourceRoute.m
//  GrowingAnalytics
//
//  Created by GrowingIO on 2026/10/20.
//  Copyright (C) 2026 Beijing Yishu Technology Co., Ltd.
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

#import "GrowingTrackerCore/Public/GrowingDataSourceRoute.h"

@implementation GrowingDataSourceRoute

- (instancetype)initWithAccountId:(NSString *)accountId
                     dataSourceId:(NSString *)dataSourceId
         dataCollectionServerHost:(NSString *)dataCollectionServerHost {
    if (self = [super init]) {
        _accountId = [accountId copy];
        _dataSourceId = [dataSourceId copy];
        _dataCollectionServerHost = [dataCollectionServerHost copy];
    }
    return self;
}

+ (instancetype)routeWithAccountId:(NSString *)accountId
                      dataSourceId:(NSString *)dataSourceId
          dataCollectionServerHost:(NSString *)dataCollectionServerHost {
    return [[self alloc] initWithAccountId:accountId
                              dataSourceId:dataSourceId
                  dataCollectionServerHost:dataCollectionServerHost];
}

- (id)copyWithZone:(NSZone *)zone {
    // 不可变对象，直接复用
    return self;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    if (![object isKindOfClass:GrowingDataSourceRoute.class]) {
        return NO;
    }
    GrowingDataSourceRoute *other = (GrowingDataSourceRoute *)object;
    return [self.accountId isEqualToString:other.accountId] && [self.dataSourceId isEqualToString:other.dataSourceId] &&
           [self.dataCollectionServerHost isEqualToString:other.dataCollectionServerHost];
}

- (NSUInteger)hash {
    return self.accountId.hash ^ self.dataSourceId.hash ^ self.dataCollectionServerHost.hash;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: accountId=%@, dataSourceId=%@, dataCollectionServerHost=%@>",
                                      NSStringFromClass(self.class),
                                      self.accountId,
                                      self.dataSourceId,
                                      self.dataCollectionServerHost];
}

@end
