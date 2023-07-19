//
//  GrowingPageManager.h
//  GrowingAnalytics
//
// Created by xiangyang on 2020/4/27.
// Copyright (C) 2020 Beijing Yishu Technology Co., Ltd.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import <UIKit/UIKit.h>
#import "GrowingAutotrackerCore/Page/GrowingPage.h"

NS_ASSUME_NONNULL_BEGIN

@interface GrowingPageManager : NSObject

+ (instancetype)sharedInstance;

- (void)start;

- (GrowingPage *)currentPage;
- (NSArray<GrowingPage *> *)allDidAppearPages;

- (void)autotrackPage:(UIViewController *)controller
                alias:(NSString *)alias
           attributes:(NSDictionary<NSString *, NSString *> *_Nullable)attributes;
- (GrowingPage *)findPageByView:(UIView *)view;
- (GrowingPage *_Nullable)findAutotrackPageByPage:(GrowingPage *)page;

@end

NS_ASSUME_NONNULL_END
