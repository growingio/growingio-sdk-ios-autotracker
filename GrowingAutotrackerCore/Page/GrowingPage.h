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

@class GrowingPageGroup;

@interface GrowingPage : NSObject

@property(readonly, weak, nonatomic) UIViewController *carrier;
@property(readwrite, strong, nonatomic) GrowingPageGroup *parent;
@property(readonly, assign, nonatomic) long long showTimestamp;
@property(readwrite, assign, nonatomic) BOOL isIgnored;
@property(readonly, copy, nonatomic) NSString *name;
@property(readonly, copy, nonatomic) NSString *title;
@property(readwrite, copy, nonatomic) NSString *alias;
@property(readonly, copy, nonatomic) NSString *path;
@property(readwrite, strong, nonatomic) NSDictionary<NSString *, NSString *> *variables;

- (instancetype)initWithCarrier:(UIViewController *)carrier;

+ (instancetype)pageWithCarrier:(UIViewController *)carrier;

- (void)refreshShowTimestamp;

@end
