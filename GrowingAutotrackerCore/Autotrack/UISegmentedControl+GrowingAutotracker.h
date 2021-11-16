//
//  UISegmentedControl+UISegmentedControl_GrowingAutoTrack.h
//  GrowingAnalytics
//
//  Created by GrowingIO on 2020/7/23.
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

NS_ASSUME_NONNULL_BEGIN

@interface UISegmentedControl (GrowingAutotracker)

+ (NSString *)growing_titleForSegment:(UIView*)segment;
- (nullable NSArray *)growing_segmentViews;

- (instancetype)growing_initWithCoder:(NSCoder *)coder;
- (instancetype)growing_initWithFrame:(CGRect)frame;
- (instancetype)growing_initWithItems:(NSArray *)items;

@end

NS_ASSUME_NONNULL_END
