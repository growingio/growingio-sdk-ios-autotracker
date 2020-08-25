//
//  GrowingClickEvent.m
//  GrowingAutoTracker
//
//  Created by GrowingIO on 2020/5/18.
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


#import "GrowingClickEvent.h"

@implementation GrowingTextEditContentChangeEvent


// override GrowingImpressionEvent logic
+ (BOOL)checkNode:(id<GrowingNode>)aNode {
    if ([aNode respondsToSelector:@selector(growingNodeEligibleEventCategory)]) {
        GrowingElementEventCategory c = [aNode growingNodeEligibleEventCategory];
        if (!(c & GrowingElementEventCategoryContentChange)) {
            return NO;
        }
    }
    return YES;
}

- (NSString*)eventTypeKey {
    return kEventTypeKeyInputChange;
}

@end

// submit 事件
@implementation GrowingSubmitEvent

- (NSString*)eventTypeKey {
    return kEventTypeKeyInputSubmit;
}

@end

@implementation GrowingClickEvent

- (NSString*)eventTypeKey {
    return kEventTypeKeyClick;
}

@end
