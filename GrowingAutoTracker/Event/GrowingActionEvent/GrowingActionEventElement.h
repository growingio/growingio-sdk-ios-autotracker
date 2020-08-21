//
//  GrowingActionEventElement.h
//  GrowingAutoTracker
//
//  Created by GrowingIO on 2020/5/29.
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
#import "GrowingEvent.h"
#import "GrowingNodeProtocol.h"

@class GrowingNodeManagerEnumerateContext;

NS_ASSUME_NONNULL_BEGIN

@interface GrowingActionEventElement : NSObject <GrowingEventTransformable>

@property (nonatomic, strong) NSNumber * _Nonnull globalSequenceId;
@property (nonatomic, strong) NSNumber * _Nonnull eventSequenceId;

@property (nonatomic, copy) NSString * _Nonnull xPath;
@property (nonatomic, copy) NSString * _Nullable hyperLink;
@property (nonatomic, copy) NSString * _Nullable index;
@property (nonatomic, copy) NSString * _Nullable cid;
@property (nonatomic, copy) NSString * _Nullable signature;
@property (nonatomic, strong) NSNumber * _Nonnull timestamp;
@property (nonatomic, copy) NSString * _Nullable content;

- (instancetype)initWithNode:(id<GrowingNode>)node
            triggerEventType:(GrowingEventType)eventType;
@end

NS_ASSUME_NONNULL_END
