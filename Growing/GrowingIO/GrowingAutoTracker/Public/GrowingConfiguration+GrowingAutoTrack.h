//
//  GrowingConfiguration+GrowingAutoTrack.h
//  GrowingAutoTracker
//
//  Created by GrowingIO on 2020/7/30.
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


#import <GrowingTracker.h>

NS_ASSUME_NONNULL_BEGIN

@interface GrowingConfiguration (GrowingAutoTrack)

// 全局设置节点有效曝光的比例
// 当可见像素值 / 总像素值 >= scale 则判定该节点可见、有效曝光， 反之不可见
// scale 有效曝光比例， 范围[0-1]; 默认值为0, 0：任意像素可见为有效曝光， 1：全部像素可见时为有效曝光
@property(nonatomic, assign) double impressionScale;

@end

NS_ASSUME_NONNULL_END
