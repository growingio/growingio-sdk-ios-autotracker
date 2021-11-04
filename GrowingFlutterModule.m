//
// GrowingFlutterModule.m
// GrowingAnalytics
//
//  Created by sheng on 2021/9/10.
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


#import "GrowingFlutterModule.h"
#import "GrowingEventManager.h"
#import "GrowingAutotrackEventType.h"
#import "GrowingPageManager.h"
#import "GrowingPageEvent.h"

@GrowingMod(GrowingFlutterModule)

@implementation GrowingFlutterModule

- (void)growingModInit:(GrowingContext *)context {
    [[GrowingEventManager sharedInstance] addInterceptor:self];
}

/// 即将构造事件
/// @param builder 事件构造器
- (void)growingEventManagerEventWillBuild:(GrowingBaseBuilder *_Nullable)builder {
    if ([builder.eventType isEqualToString:GrowingEventTypePage]) {
        // flutter page 需要过滤原生的FlutterViewController
        GrowingPageBuilder *pageBuilder = (GrowingPageBuilder *)builder;
        if ([pageBuilder.pageName hasSuffix:NSClassFromString(@"FlutterViewController")]) {
            
        }
    }
}

@end
