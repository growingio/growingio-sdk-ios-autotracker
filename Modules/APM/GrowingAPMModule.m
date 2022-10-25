//
//  GrowingAPMModule.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2022/9/26.
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

#import "Modules/APM/Public/GrowingAPMModule.h"

#import "GrowingTrackerCore/Manager/GrowingConfigurationManager.h"
#import "GrowingTrackerCore/Event/GrowingEventGenerator.h"
#import "GrowingTrackerCore/Thirdparty/Logger/GrowingLogger.h"

#import "GrowingAPM+Private.h"

GrowingMod(GrowingAPMModule)

@implementation GrowingAPMModule

#pragma mark - GrowingModuleProtocol

- (void)growingModInit:(GrowingContext *)context {
    GrowingAPMConfig *config = [GrowingConfigurationManager sharedInstance].trackConfiguration.APMConfig;
    if (!config) {
        return;
    }

    // 初始化 GrowingAPM
    [GrowingAPM startWithConfig:config];
    
    GrowingAPM.sharedInstance.pageLoadMonitor.monitorBlock = ^(NSString *pageName,
                                                               double loadDuration,
                                                               double rebootTime,
                                                               BOOL isWarm) {
        NSDictionary *pageLoadDic = @{@"page_name" : pageName,
                                      @"page_load_duration" : [NSString stringWithFormat:@"%.0f", loadDuration]};
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:pageLoadDic];
        if (rebootTime > 0) {
            [params addEntriesFromDictionary:isWarm ? @{@"warm_reboot_time" : [NSString stringWithFormat:@"%.0f", rebootTime],
                                                        @"warm_reboot" : @"true"}
                                                    : @{@"cold_reboot_time" : [NSString stringWithFormat:@"%.0f", rebootTime],
                                                        @"cold_reboot" : @"true"}];
        }
        [GrowingEventGenerator generateCustomEvent:@"AppLaunchTime" attributes:params];
    };
    
    GrowingAPM.sharedInstance.crashMonitor.monitorBlock = ^(NSArray *filteredReports, BOOL completed, NSError *error) {
        if (!completed || error) {
            return;
        }
        for(id report in filteredReports) {
            if ([report isKindOfClass:[NSDictionary class]]) {
                NSMutableString *exception_name = [NSMutableString string];
                NSDictionary *mach = report[@"mach"];
                if ([mach isKindOfClass:[NSDictionary class]] && mach.allKeys.count > 0) {
                    NSString *mach_exception_name = mach[@"exception_name"];
                    if (mach_exception_name.length > 0) {
                        [exception_name appendString:mach_exception_name];
                    }
                }

                NSDictionary *signal = report[@"signal"];
                if ([signal isKindOfClass:[NSDictionary class]] && signal.allKeys.count > 0) {
                    NSString *signal_name = signal[@"name"];
                    if (signal_name.length > 0) {
                        [exception_name appendFormat:@"(%@)", signal_name];
                    }
                }
                
                NSString *reason = @"";
                NSDictionary *nsexception = report[@"nsexception"];
                NSDictionary *cppexception = report[@"cpp_exception"];
                if ([nsexception isKindOfClass:[NSDictionary class]] && nsexception.allKeys.count > 0) {
                    reason = [self stringWithUncaughtExceptionName:nsexception[@"name"] reason:report[@"reason"]];
                } else if ([cppexception isKindOfClass:[NSDictionary class]] && cppexception.allKeys.count > 0) {
                    reason = [self stringWithUncaughtExceptionName:cppexception[@"name"] reason:report[@"reason"]];
                }
                
                [GrowingEventGenerator generateCustomEvent:@"Error" attributes:@{@"error_title" : exception_name,
                                                                                 @"error_content" : reason}];
            } else if ([report isKindOfClass:[NSString class]]) {
                GIOLogDebug(@"\n%s\n", ((NSString *)report).UTF8String);
            }
        }
    };
}

#pragma mark - Private Method

- (NSString *)stringWithUncaughtExceptionName:(NSString *)name reason:(NSString *)reason {
    return [NSString stringWithFormat:@"*** Terminating app due to uncaught exception '%@', reason: '%@'", name, reason];
}

@end
