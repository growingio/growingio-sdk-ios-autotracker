//
//  GrowingStatusBar.m
//  GrowingTracker
//
//  Created by GrowingIO on 3/15/16.
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


#import "GrowingStatusBar.h"
#import "UIControl+GrowingHelper.h"

@interface GrowingStatusBar ()

@property (nonatomic, retain) UIControl * btn;

@end


@implementation GrowingStatusBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        UILabel *label = [[UILabel alloc] init];
        label.userInteractionEnabled = YES;
        label.backgroundColor = [UIColor blueColor];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:12];
        label.textAlignment = NSTextAlignmentCenter;
        self.statusLable = label;
        [self addSubview:label];
        
        self.btn = [[UIControl alloc] init];
        [label addSubview:self.btn];
        self.btn.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.btn.growingHelper_onClick = self.onButtonClick;

        self.growingViewLevel = 0;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.statusLable.frame = CGRectMake(0,0,self.bounds.size.width, 20);
    self.btn.frame = self.statusLable.bounds;
}

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    if (self == view)
    {
        return nil;
    }
    return view;
}

- (void)setOnButtonClick:(void (^)(void))onButtonClick
{
    _onButtonClick = onButtonClick;
    self.btn.growingHelper_onClick = self.onButtonClick;
}

- (BOOL)growingNodeIsBadNode
{
    return NO;
}

@end
