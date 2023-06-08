//
//  GrowingPage.h
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface GrowingPage : NSObject

@property (nonatomic, weak, readonly) UIViewController *carrier;

@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, copy, readonly) NSString *path;
@property (nonatomic, assign, readonly) long long showTimestamp;
@property (nonatomic, copy) NSString *alias;

@property (nonatomic, strong) GrowingPage *parent;
@property (nonatomic, strong, readonly) NSPointerArray *childPages;

+ (instancetype)pageWithCarrier:(UIViewController *)carrier;

- (void)refreshShowTimestamp;

- (void)addChildrenPage:(GrowingPage *)page;
- (void)removeChildrenPage:(GrowingPage *)page;

@end
