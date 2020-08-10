//
//  GrowingConstApi.h
//  GrowingTracker
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

#define kGrowingEventApiTemplate_Custom @"v3/%@/ios/cstm?stm=%llu"
#define kGrowingEventApiTemplate_PV @"v3/%@/ios/pv?stm=%llu"
#define kGrowingEventApiTemplate_Imp @"v3/%@/ios/imp?stm=%llu"
#define kGrowingEventApiTemplate_Other @"v3/%@/ios/other?stm=%llu"
#define kGrowingEventApiV3(Template, AI, STM) [[GrowingNetworkConfig sharedInstance] buildEndPointWithTemplate:(Template) accountId:(AI) andSTM:(STM)]

#define kGrowingReportApi(Template, AI, STM) ([[GrowingNetworkConfig sharedInstance] buildReportEndPointWithTemplate:(Template) accountId:(AI) andSTM:(STM)])

#define kGrowingDataApiHost(path) ([NSString stringWithFormat: @"%@/%@", [[GrowingNetworkConfig sharedInstance] growingDataHostEnd], path])

#define kGrowingLoginApiV2              kGrowingDataApiHost(@"oauth2/token")

#define kGrowingDataCheckAddress      @"/feeds/apps/%@/exchanges/data-check/%@?clientType=sdk"

#endif /* GrowingConstApi_h */




@interface GrowingNetworkConfig : NSObject

@property (nonatomic, copy) NSString *customTrackerHost;
@property (nonatomic, copy) NSString *customDataHost;
//@property (nonatomic, copy) NSString *customAdHost;
@property (nonatomic, copy) NSString *customWsHost;

+ (instancetype)sharedInstance;

- (NSString *)buildEndPointWithTemplate:(NSString *)path
                              accountId:(NSString *)accountId
                                 andSTM:(unsigned long long)stm;

- (NSString *)growingApiHostEnd;

- (NSString *)growingDataHostEnd;

- (NSString *)tagsHost;

- (NSString *)wsEndPoint;

- (NSString *)dataCheckEndPoint;

@end
