//
//  GIOTrackTimerTableViewCell.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2022/9/6.
//  Copyright (C) 2022 Beijing Yishu Technology Co., Ltd.
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

#import "GIOTrackTimerTableViewCell.h"

@implementation GIOTrackTimerTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)pauseAction:(UIButton *)sender {
    if (self.pauseBlock) {
        self.pauseBlock(self.label.text);
    }
}

- (IBAction)resumeAction:(UIButton *)sender {
    if (self.resumeBlock) {
        self.resumeBlock(self.label.text);
    }
}

- (IBAction)endAction:(UIButton *)sender {
    if (self.endBlock) {
        self.endBlock(self.label.text);
    }
}

@end
