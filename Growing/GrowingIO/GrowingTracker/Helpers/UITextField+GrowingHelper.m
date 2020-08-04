//
//  UITextFiled+GrowingHelper.m
//  GrowingTracker
//
//  Created by GrowingIO on 15/11/13.
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


#import "UITextField+GrowingHelper.h"


@implementation GrowingHelperTextField


- (CGRect)rectForBounds:(CGRect)bounds
{
    return CGRectMake(bounds.origin.x + self.edgeInset.left,
                      bounds.origin.y + self.edgeInset.top,
                      bounds.size.width - self.edgeInset.left - self.edgeInset.right,
                      bounds.size.height - self.edgeInset.top - self.edgeInset.bottom);
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    return [self rectForBounds:bounds];
}
- (CGRect)placeholderRectForBounds:(CGRect)bounds
{
    return [self rectForBounds:bounds];
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return [self rectForBounds:bounds];
}

@end

