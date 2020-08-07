//
//  GrowingMenu.h
//  GrowingTracker
//
//  Created by GrowingIO on 15/11/6.
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


#import <UIKit/UIKit.h>
#import "GrowingWindow.h"

@class GrowingMenuView;

typedef NS_ENUM(NSUInteger, GrowingMenuShowType)
{
    GrowingMenuShowTypeAlert,
    GrowingMenuShowTypePresent
};

@interface GrowingMenu : GrowingWindowView

+ (void)showMenuView:(GrowingMenuView*)view;
+ (void)showMenuView:(GrowingMenuView*)view showType:(GrowingMenuShowType)type;
+ (void)showMenuView:(GrowingMenuView*)view showType:(GrowingMenuShowType)type complate:(void(^)(void))complate;

+ (void)hideMenuView:(GrowingMenuView*)view;
+ (void)hideMenuView:(GrowingMenuView*)view showType:(GrowingMenuShowType)type;
+ (void)hideMenuView:(GrowingMenuView*)view showType:(GrowingMenuShowType)type complate:(void(^)(void))complate;;

+ (NSUInteger)showMenuCount;

+ (CGSize)maxSizeForType:(GrowingMenuShowType)type;

@end
