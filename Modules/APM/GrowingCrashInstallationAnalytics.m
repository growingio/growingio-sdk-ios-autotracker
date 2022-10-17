//
//  GrowingCrashInstallationAnalytics.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2022/9/23.
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

#import "GrowingAPM+Private.h"

#ifdef GROWING_APM_CRASH
#import "Modules/APM/GrowingCrashInstallationAnalytics.h"

#ifdef GROWING_APM_CRASH_SOURCE
#import "GrowingCrashInstallation+Private.h"
#import "GrowingCrashReportFilterBasic.h"
#import "GrowingCrashReportFilterAppleFmt.h"
#else
#import <GrowingAPMCrashMonitor/GrowingCrashInstallation+Private.h>
#import <GrowingAPMCrashMonitor/GrowingCrashReportFilterBasic.h>
#import <GrowingAPMCrashMonitor/GrowingCrashReportFilterAppleFmt.h>
#endif

@implementation GrowingCrashInstallationAnalytics

+ (instancetype)sharedInstance {
    static GrowingCrashInstallationAnalytics *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[GrowingCrashInstallationAnalytics alloc] initWithRequiredProperties:nil];
    });
    return sharedInstance;
}

- (id <GrowingCrashReportFilter>)sink {
    id <GrowingCrashReportFilter>formatFilter = [GrowingCrashReportFilterObjectForKey filterWithKey:@"crash/error"
                                                                                      allowNotFound:YES];
    // 测试使用：反注释下面这一行代码，用来在 Xcode console 查看崩溃日志 (AppleFormat)，这将会不上报事件
//    formatFilter = [GrowingCrashReportFilterAppleFmt filterWithReportStyle:GrowingCrashAppleReportStyleSymbolicated];
    return [GrowingCrashReportFilterPipeline filterWithFilters:formatFilter, nil];
}

@end

@implementation GrowingAPM (GrowingAnalytics)

+ (void)initialize {
    self.crashInstallation = GrowingCrashInstallationAnalytics.sharedInstance;
}

@end
#endif
