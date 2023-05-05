//
//  GrowingNode.m
//  GrowingAnalytics
//
//  Created by GrowingIO on 15/12/12.
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

#import "GrowingAutotrackerCore/GrowingNode/GrowingNode.h"
#import "GrowingAutotrackerCore/Page/GrowingPageManager.h"
#import "GrowingTrackerCore/Helpers/GrowingHelpers.h"
#import "GrowingAutotrackerCore/Autotrack/GrowingPropertyDefine.h"
#import "GrowingAutotrackerCore/Autotrack/UIViewController+GrowingAutotracker.h"
#import "GrowingAutotrackerCore/GrowingNode/Category/UIApplication+GrowingNode.h"
#import "GrowingAutotrackerCore/GrowingNode/Category/UIViewController+GrowingNode.h"
#import "GrowingAutotrackerCore/GrowingNode/Category/UIWindow+GrowingNode.h"

@implementation NSObject (GrowingNode)

static char growingNodeIsBadNodeKey;
- (BOOL)growingNodeIsBadNode {
    return objc_getAssociatedObject(self, &growingNodeIsBadNodeKey) != nil;
}

- (void)setGrowingNodeIsBadNode:(BOOL)growingNodeIsBadNode {
    objc_setAssociatedObject(self, &growingNodeIsBadNodeKey, growingNodeIsBadNode ? @"yes" : nil,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
