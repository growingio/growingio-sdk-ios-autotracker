//
//  UIImageView+GrowingNode.m
//  GrowingTracker
//
//  Created by GrowingIO on 15/9/12.
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


#import "UIImageView+GrowingNode.h"
#import "UIView+GrowingNode.h"

@implementation UIImageView (GrowingNode)

- (NSString*)growingNodeName
{
    return @"图片";
}

- (NSString*)growingViewContent
{
    if (self.accessibilityLabel.length) {
        return self.accessibilityLabel;
    } else {
        for (UIView *view in self.subviews) {
            if ([view isKindOfClass:[UILabel class]] && [view growingViewContent].length) {
                return [view growingViewContent];
            }
        }
    }
    
    return nil;
}

@end
