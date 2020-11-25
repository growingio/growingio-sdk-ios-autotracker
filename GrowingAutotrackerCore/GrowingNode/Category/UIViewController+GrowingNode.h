//
//  UIViewController+GrowingNode.m
//  GrowingTracker
//
//  Created by GrowingIO on 15/8/31.
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
#import "GrowingRealAutotracker.h"
#import "GrowingNodeManager.h"

@interface UIViewController (GrowingNode) <GrowingNode>

@end

@interface UIViewController (GrowingPrivateAttributes)


- (void)mergeGrowingAttributesPvar:(NSDictionary<NSString *,NSObject *> *)growingAttributesPvar;
- (void)removeGrowingAttributesPvar:(NSString *)key;

@end

// 该属性setter方法均使用 objc_setAssociatedObject实现
// 如果是自定义的UIViewController不要使用重写getter方法来实现,因为SDK在set方法内部有逻辑处理
@interface UIViewController (GrowingAttributes)

// 手动标识该页面的标题，必须在该UIViewController显示之前设置
@property (nonatomic, copy) NSString *growingPageAlias;

@property (nonatomic, strong) NSDictionary <NSString *, NSString *> *growingPageAttributes;

@property (nonatomic, assign) GrowingIgnorePolicy growingPageIgnorePolicy;

@end
