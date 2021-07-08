//
// GrowingAutotrackConfiguration.m
// GrowingAnalytics
//
//  Created by sheng on 2021/5/8.
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


#import "GrowingAutotrackConfiguration.h"


@implementation GrowingAutotrackConfiguration

- (id)copyWithZone:(NSZone *)zone {
    GrowingAutotrackConfiguration *configuration = [[GrowingAutotrackConfiguration alloc] initWithProjectId:self.projectId];
    configuration.debugEnabled = self.debugEnabled;
    configuration.cellularDataLimit = self.cellularDataLimit;
    configuration.dataUploadInterval = self.dataUploadInterval;
    configuration.sessionInterval = self.sessionInterval;
    configuration.dataCollectionEnabled = self.dataCollectionEnabled;
    configuration.uploadExceptionEnable = self.uploadExceptionEnable;
    configuration.dataCollectionServerHost = [self.dataCollectionServerHost copy];
    configuration.filterEventMask = self.filterEventMask;

    // GrowingAutotrackConfiguration add
    configuration.impressionScale = self.impressionScale;
    return configuration;
}

@end
