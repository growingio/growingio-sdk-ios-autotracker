//
//  GrowingABTesting.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2023/10/10.
//  Copyright (C) 2023 Beijing Yishu Technology Co., Ltd.
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

#import "Modules/ABTesting/Public/GrowingABTesting.h"
#import "GrowingTrackerCore/Event/GrowingEventGenerator.h"
#import "GrowingTrackerCore/Helpers/GrowingHelpers.h"
#import "GrowingTrackerCore/Manager/GrowingConfigurationManager.h"
#import "GrowingTrackerCore/Public/GrowingEventNetworkService.h"
#import "GrowingTrackerCore/Public/GrowingServiceManager.h"
#import "GrowingTrackerCore/Thirdparty/Logger/GrowingLogger.h"
#import "GrowingULTimeUtil.h"
#import "Modules/ABTesting/GrowingABTExperiment+Private.h"
#import "Modules/ABTesting/Request/GrowingABTRequest.h"

GrowingMod(GrowingABTesting)

static NSString *const kABTExpHit = @"$exp_hit";
static NSString *const kABTExpLayerId = @"$exp_layer_id";
static NSString *const kABTExpId = @"$exp_id";
static NSString *const kABTExpStrategyId = @"$exp_strategy_id";

@implementation GrowingABTesting

#pragma mark - GrowingModuleProtocol

+ (BOOL)singleton {
    return YES;
}

+ (instancetype)sharedInstance {
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (void)growingModInit:(GrowingContext *)context {
    GrowingTrackConfiguration *config = GrowingConfigurationManager.sharedInstance.trackConfiguration;
    if (config.abTestingServerHost && config.abTestingServerHost.length > 0) {
        NSString *host = [NSURL URLWithString:config.abTestingServerHost].host;
        if (!host) {
            @throw [NSException exceptionWithName:@"初始化异常"
                                           reason:@"您所配置的ABTestingHost不符合规范"
                                         userInfo:nil];
        }
    } else {
        @throw [NSException exceptionWithName:@"初始化异常" reason:@"请在SDK初始化时，配置ABTestingHost" userInfo:nil];
    }
}

#pragma mark - Private Method

+ (BOOL)isToday:(double)timestamp {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit unit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;

    NSDateComponents *components = [calendar components:unit fromDate:[NSDate date]];
    NSDate *today = [calendar dateFromComponents:components];

    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp / 1000LL];
    components = [calendar components:unit fromDate:date];
    NSDate *otherDay = [calendar dateFromComponents:components];

    return today && otherDay && [today isEqualToDate:otherDay];
}

+ (void)trackExperiment:(GrowingABTExperiment *)experiment {
    [GrowingEventGenerator generateCustomEvent:kABTExpHit
                                    attributes:@{
                                        kABTExpLayerId: experiment.layerId.copy,
                                        kABTExpId: experiment.experimentId.copy,
                                        kABTExpStrategyId: experiment.strategyId.copy
                                    }];
}

+ (void)fetchExperiment:(NSString *)layerId
         completedBlock:(void (^)(GrowingABTExperiment *_Nullable))completedBlock
             retryCount:(NSInteger)retryCount {
    GrowingABTExperiment *exp = [GrowingABTExperiment findExperiment:layerId];
    if (exp) {
        BOOL outdated = ![self isToday:exp.fetchTime];
        if (outdated) {
            // 超过自然日，清除本地缓存
            [exp removeFromDisk];
        } else {
            GrowingTrackConfiguration *config = GrowingConfigurationManager.sharedInstance.trackConfiguration;
            long long now = GrowingULTimeUtil.currentTimeMillis;
            if (now - exp.fetchTime < config.abTestingRequestInterval * 60 * 1000LL) {
                // TTL内
                if (completedBlock) {
                    completedBlock(exp);
                }
                return;
            }
        }
    }

    // 1. 超过自然日
    // 2. 超过TTL
    // 3. 首次调用（无本地缓存）
    [self requestExperiment:layerId
             completedBlock:^(BOOL isSuccess, GrowingABTExperiment *experiment, NSInteger retriesLeft) {
                 if (isSuccess || retriesLeft <= 0) {
                     if (completedBlock) {
                         completedBlock(experiment);
                     }
                 } else {
                     retriesLeft--;
                     [self fetchExperiment:layerId completedBlock:completedBlock retryCount:retriesLeft];
                 }
             }
                 retryCount:retryCount];
}

+ (void)requestExperiment:(NSString *)layerId
           completedBlock:(void (^)(BOOL, GrowingABTExperiment *, NSInteger))completedBlock
               retryCount:(NSInteger)retryCount {
    GrowingABTRequest *request = [[GrowingABTRequest alloc] init];
    request.layerId = layerId;
    id<GrowingEventNetworkService> service =
        [[GrowingServiceManager sharedInstance] createService:@protocol(GrowingEventNetworkService)];
    if (!service) {
        GIOLogError(@"[GrowingABTesting] -fetchExperiment error: no network service support");
        return;
    }
    [service sendRequest:request
              completion:^(NSHTTPURLResponse *_Nonnull httpResponse, NSData *_Nonnull data, NSError *_Nonnull error) {
                  if (httpResponse.statusCode < 200 || httpResponse.statusCode >= 300) {
                      // 请求失败
                      if (completedBlock) {
                          completedBlock(NO, nil, retryCount);
                      }
                      return;
                  }
                  NSInteger code = -1;
                  NSString *strategyId = nil;
                  NSString *experimentId = nil;
                  NSDictionary *variables = nil;
                  @try {
                      NSDictionary *dic = [data growingHelper_dictionaryObject];
                      code = ((NSNumber *)dic[@"code"]).integerValue;
                      if ([dic[@"strategyId"] isKindOfClass:[NSNumber class]]) {
                          strategyId = ((NSNumber *)dic[@"strategyId"]).stringValue;
                      }
                      if ([dic[@"experimentId"] isKindOfClass:[NSNumber class]]) {
                          experimentId = ((NSNumber *)dic[@"experimentId"]).stringValue;
                      }
                      if ([dic[@"variables"] isKindOfClass:[NSDictionary class]]) {
                          variables = dic[@"variables"];
                      }
                  } @catch (NSException *exception) {
                      // 接口返回数据结构异常，SDK无法解析，不上报不缓存
                      if (completedBlock) {
                          completedBlock(NO, nil, 0);
                      }
                      return;
                  }

                  if (code != 0) {
                      // 请求失败
                      if (completedBlock) {
                          completedBlock(NO, nil, 0);
                      }
                      return;
                  }

                  GrowingABTExperiment *exp =
                      [[GrowingABTExperiment alloc] initWithLayerId:layerId
                                                       experimentId:experimentId
                                                         strategyId:strategyId
                                                          variables:variables
                                                          fetchTime:GrowingULTimeUtil.currentTimeMillis];

                  if (experimentId && experimentId.length > 0 && strategyId && strategyId.length > 0) {
                      // 命中实验
                      GrowingABTExperiment *lastExp = [GrowingABTExperiment findExperiment:layerId];
                      if (![exp isEqual:lastExp]) {
                          // 和缓存实验数据不同，上报入组埋点
                          [self trackExperiment:exp];
                      }
                  }

                  // 更新缓存
                  [exp saveToDisk];

                  // 返回实验结果
                  if (completedBlock) {
                      completedBlock(YES, exp, 0);
                  }
              }];
}

#pragma mark - Public Method

+ (void)fetchExperiment:(NSString *)layerId completedBlock:(void (^)(GrowingABTExperiment *))completedBlock {
    if (!layerId || ![layerId isKindOfClass:[NSString class]] || layerId.length == 0) {
        return;
    }
    [self fetchExperiment:layerId completedBlock:completedBlock retryCount:1];
}

@end
