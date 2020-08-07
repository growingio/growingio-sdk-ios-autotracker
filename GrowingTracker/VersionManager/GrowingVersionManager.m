//
//  GrowingVersionManager.m
//  GrowingTracker
//
//  Created by GrowingIO on 2019/9/9.
//  Copyright (C) 2019 Beijing Yishu Technology Co., Ltd.
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


#import "GrowingVersionManager.h"
#import "NSDictionary+GrowingHelper.h"

@implementation GrowingVersionManager

static NSMutableDictionary *versionDict;
+ (void)registerVersionInfo:(NSDictionary *)infoDict
{
    if (versionDict.count == 0) {
        versionDict = [[NSMutableDictionary alloc] init];
    }
    [versionDict addEntriesFromDictionary:infoDict];
}

static NSString *kGrowingVersionInfoString;
+ (NSString *)versionInfo
{
    if (kGrowingVersionInfoString.length == 0) {
        kGrowingVersionInfoString = [versionDict growingHelper_jsonString];
    }
    return kGrowingVersionInfoString;
}

@end
