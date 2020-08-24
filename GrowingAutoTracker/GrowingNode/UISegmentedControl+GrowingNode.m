//
//  UISegmentedControl+GrowingNode.m
//
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

#import "UISegmentedControl+GrowingAutoTrack.h"
#import "UISegmentedControl+GrowingNode.h"
#import "UIView+GrowingNode.h"
#import <objc/runtime.h>


@interface UISegmentedControl () <GrowingNode>

@end

@implementation UISegmentedControl (GrowingNode)

- (BOOL)growingViewUserInteraction {
    return NO;  // the UISegmentControl itself is not interactive
}

- (NSArray<id<GrowingNode>>*)growingNodeChilds {
    return self.growing_segmentViews;
}

@end

@implementation GrowingSegmentButton

+ (void)load {
//    metamacro_foreach(GrowingCategoryBindCheckName, ,__VA_ARGS__ )
    unsigned int count = 0;
    Method *methods = class_copyMethodList(self, &count);
    NSMutableArray *classes = [[NSMutableArray alloc] init];
    Class clazz = NSClassFromString([NSString stringWithFormat:@"UI%@ment",@"Seg"]);
    if (clazz) {
        [classes addObject:clazz];
    }
    for (unsigned int i = 0 ; i < count ; i++) {
        Method method = methods[i];
        for (Class clazz in classes) {
            class_addMethod(clazz,
                            method_getName(method),
                            method_getImplementation(method),
                            method_getTypeEncoding(method));
        }
    }
    free(methods);
}

- (BOOL)growingViewUserInteraction
{
    return YES;
}

- (NSString*)growingNodeName
{
    return @"按钮";
}

- (NSArray<id<GrowingNode>>*)growingNodeChilds {
    return nil;
}

- (NSString*)growingNodeContent
{
    NSString *nodeContent = [UISegmentedControl growing_titleForSegment:(id)self];
    if (nodeContent.length) {
        return nodeContent;
    } else {
        return self.accessibilityLabel;
    }
}


@end
