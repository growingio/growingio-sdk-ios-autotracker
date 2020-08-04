//
//  GrowingGlobal.m
//  GrowingTracker
//
//  Created by GrowingIO on 9/1/16.
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


#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "GrowingGlobal.h"
#import "GrowingInstance.h"

const NSUInteger    g_K                     = 1024;
const NSUInteger    g_M                     = g_K * g_K;

BOOL                g_GDPRFlag              = NO;

const NSUInteger    g_maxCountOfKVPairs     = 100;
const NSUInteger    g_maxLengthOfKey        = 50;
const NSUInteger    g_maxLengthOfValue      = 1000;


BOOL SDKDoNotTrack() {
    return g_GDPRFlag;
}
