//
//  UISegmentedControl+GrowingNode.m
//  GrowingAnalytics
//
//  Created by GrowingIO on 15/10/7.
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

#import <objc/runtime.h>
#import "GrowingAutotrackerCore/Autotrack/UISegmentedControl+GrowingAutotracker.h"
#import "GrowingAutotrackerCore/GrowingNode/Category/UISegmentedControl+GrowingNode.h"
#import "GrowingAutotrackerCore/GrowingNode/Category/UIView+GrowingNode.h"

@interface UISegmentedControl () <GrowingNode>

@end

@implementation UISegmentedControl (GrowingNode)

- (BOOL)growingViewUserInteraction {
    return NO;  // the UISegmentControl itself is not interactive
}

- (NSArray<id<GrowingNode>> *_Nullable)growingNodeChilds {
    return self.growing_segmentViews;
}

@end

@implementation GrowingSegmentSwizzleHelper

+ (void)addAutoTrackSwizzles {
    unsigned int count = 0;
    Method *methods = class_copyMethodList(self, &count);
    NSMutableArray *classes = [[NSMutableArray alloc] init];
    Class clazz = NSClassFromString(@"UISegment");
    if (clazz) {
        [classes addObject:clazz];
    }
    if (methods) {
        for (unsigned int i = 0; i < count; i++) {
            Method method = methods[i];
            for (Class clazz in classes) {
                class_addMethod(clazz,
                                method_getName(method),
                                method_getImplementation(method),
                                method_getTypeEncoding(method));
            }
        }
    }
    free(methods);
}

- (BOOL)growingViewUserInteraction {
    return YES;
}

- (NSArray<id<GrowingNode>> *)growingNodeChilds {
    return nil;
}

- (NSString *)growingNodeSubSimilarPath {
    // 如果手动标识了该view,返回标识
    if ([self respondsToSelector:@selector(growingUniqueTag)]) {
        if (self.growingUniqueTag.length > 0) {
            return self.growingUniqueTag;
        }
    }

    NSString *className = NSStringFromClass(self.class);
    return index < 0 ? className : [NSString stringWithFormat:@"%@[-]", className];
}

- (NSString *)growingNodeContent {
    NSString *nodeContent = [UISegmentedControl growing_titleForSegment:(id)self];
    if (nodeContent.length) {
        return nodeContent;
    } else {
        return self.accessibilityLabel;
    }
}

@end
