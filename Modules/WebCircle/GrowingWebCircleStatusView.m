//
//  GrowingWebCircleStatusView.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2023/7/24.
//  Copyright (C) 2023 Beijing Yishu Technology Co., Ltd.
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

#import "Modules/WebCircle/GrowingWebCircleStatusView.h"
#import "GrowingTrackerCore/Menu/GrowingAlert.h"

@interface GrowingWebCircleStatusView ()

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation GrowingWebCircleStatusView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.statusLabel.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}

- (void)dealloc {
    [self stopTimer];
}

- (void)setStatus:(GrowingWebCircleStatus)status {
    _status = status;
    switch (status) {
        case GrowingWebCircleStatusWaitConnect: {
            self.statusLabel.text = @"正在等待web链接";
            self.hidden = NO;
            [self startTimer];
        } break;
        case GrowingWebCircleStatusOpening: {
            self.statusLabel.text = @"正在进行GrowingIO移动端圈选";
        } break;
        case GrowingWebCircleStatusClosing: {
            self.statusLabel.text = @"正在关闭web圈选...";
            self.hidden = YES;
            [self stopTimer];
        } break;
        default:
            break;
    }
}

- (void)startTimer {
    if (!self.timer) {
        self.timer = [NSTimer timerWithTimeInterval:10.0f
                                             target:self
                                           selector:@selector(checkStatusIfOpen)
                                           userInfo:nil
                                            repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
}

- (void)stopTimer {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)checkStatusIfOpen {
    if (self.status != GrowingWebCircleStatusWaitConnect) {
        return;
    }

    GrowingAlert *alert = [GrowingAlert createAlertWithStyle:UIAlertControllerStyleAlert
                                                       title:@"提示"
                                                     message:
                                                         @"电脑端连接超时，请刷新电脑页面，"
                                                         @"再次尝试扫码圈选。"];
    [alert addOkWithTitle:@"知道了" handler:nil];
    [alert showAlertAnimated:NO];
}

@end
