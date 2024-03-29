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

#import "GrowingTrackerCore/Event/GrowingEventGenerator.h"
#import "GrowingTrackerCore/Manager/GrowingConfigurationManager.h"
#import "GrowingTrackerCore/Thirdparty/Logger/GrowingLogger.h"
#import "GrowingULApplication.h"

GrowingMod(GrowingAPMModule)

static NSString *const kAPMEventError = @"apm_system_error";
static NSString *const kAPMErrorTitle = @"error_type";
static NSString *const kAPMErrorContent = @"error_content";

static NSString *const kAPMEventLaunchTime = @"apm_app_launch";
static NSString *const kAPMRebootMode = @"reboot_mode";
static NSString *const kAPMRebootModeWarm = @"warm";
static NSString *const kAPMRebootModeCold = @"cold";
static NSString *const kAPMRebootTime = @"reboot_duration";
static NSString *const kAPMPageName = @"title";
static NSString *const kAPMPageDuration = @"page_launch_duration";

@implementation GrowingAPMModule

#pragma mark - GrowingModuleProtocol

- (void)growingModInit:(GrowingContext *)context {
    if ([GrowingULApplication isAppExtension]) {
        return;
    }
    GrowingAPMConfig *config = [GrowingConfigurationManager sharedInstance].trackConfiguration.APMConfig;
    if (!config) {
        return;
    }

    // 初始化 GrowingAPM
    [GrowingAPM startWithConfig:config];

    GrowingAPM *apm = GrowingAPM.sharedInstance;
    if (config.monitors & GrowingAPMMonitorsUserInterface) {
        [apm.loadMonitor addMonitorDelegate:self];
    }
    if (config.monitors & GrowingAPMMonitorsCrash) {
        [apm.crashMonitor addMonitorDelegate:self];
    }
}

#pragma mark - GrowingAPM Delegate

- (void)growingapm_UIMonitorHandleWithPageName:(NSString *)pageName
                                  loadDuration:(double)loadDuration
                                    rebootTime:(double)rebootTime
                                        isWarm:(double)isWarm {
    NSDictionary *pageLoadDic =
        @{kAPMPageName: pageName, kAPMPageDuration: [NSString stringWithFormat:@"%.0f", loadDuration]};
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:pageLoadDic];
    if (rebootTime > 0) {
        [params addEntriesFromDictionary:@{
            kAPMRebootTime: [NSString stringWithFormat:@"%.0f", rebootTime],
            kAPMRebootMode: isWarm ? kAPMRebootModeWarm : kAPMRebootModeCold
        }];
    }
    [GrowingEventGenerator generateCustomEvent:kAPMEventLaunchTime attributes:params];
}

- (void)growingapm_crashMonitorHandleWithReports:(NSArray *)reports completed:(BOOL)completed error:(NSError *)error {
    if (!completed || error) {
        return;
    }

    for (id report in reports) {
        if ([report isKindOfClass:[NSDictionary class]]) {
            id reportForEvent = report[@"errorReport"];
            if ([reportForEvent isKindOfClass:[NSDictionary class]]) {
                NSMutableString *exception_name = [NSMutableString string];
                NSDictionary *mach = reportForEvent[@"mach"];
                if ([mach isKindOfClass:[NSDictionary class]] && mach.allKeys.count > 0) {
                    NSString *mach_exception_name = mach[@"exception_name"];
                    if (mach_exception_name.length > 0) {
                        [exception_name appendString:mach_exception_name];
                    }
                }

                NSDictionary *signal = reportForEvent[@"signal"];
                if ([signal isKindOfClass:[NSDictionary class]] && signal.allKeys.count > 0) {
                    NSString *signal_name = signal[@"name"];
                    if (signal_name.length > 0) {
                        [exception_name appendFormat:@"(%@)", signal_name];
                    }
                }

                NSString *reason = @"";
                NSDictionary *nsexception = reportForEvent[@"nsexception"];
                NSDictionary *cppexception = reportForEvent[@"cpp_exception"];
                if ([nsexception isKindOfClass:[NSDictionary class]] && nsexception.allKeys.count > 0) {
                    reason = [self stringWithUncaughtExceptionName:nsexception[@"name"]
                                                            reason:reportForEvent[@"reason"]];
                } else if ([cppexception isKindOfClass:[NSDictionary class]] && cppexception.allKeys.count > 0) {
                    reason = [self stringWithUncaughtExceptionName:cppexception[@"name"]
                                                            reason:reportForEvent[@"reason"]];
                }

                [GrowingEventGenerator generateCustomEvent:kAPMEventError
                                                attributes:@{kAPMErrorTitle: exception_name, kAPMErrorContent: reason}];
            }

            id appleFmt = report[@"AppleFmt"];
            if ([appleFmt isKindOfClass:[NSString class]]) {
                GIOLogDebug(@"\n%s\n", ((NSString *)appleFmt).UTF8String);
            }
        }
    }
}

#pragma mark - Private Method

- (NSString *)stringWithUncaughtExceptionName:(NSString *)name reason:(NSString *)reason {
    return
        [NSString stringWithFormat:@"*** Terminating app due to uncaught exception '%@', reason: '%@'", name, reason];
}

@end
