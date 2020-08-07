//
//  GrowingAlertMenu.h
//  GrowingTracker
//
//  Created by GrowingIO on 15/11/7.
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


#import "GrowingMenuView.h"

@interface GrowingAlertMenu : GrowingMenuView

@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSString *text2;

+ (instancetype)alertWithTitle:(NSString*)title
                          text:(NSString*)text
                       buttons:(NSArray<GrowingMenuButton*>*)buttons;

+ (instancetype)alertWithTitle:(NSString *)title
                         text1:(NSString *)text1
                         text2:(NSString *)text2
                       buttons:(NSArray<GrowingMenuButton *> *)buttons;

+ (instancetype)alertOnlyText:(NSString*)text
                      buttons:(NSArray<GrowingMenuButton*>*)buttons;

+ (instancetype)alertWithActionArray:(NSArray*)action
                              config:(void(^)(GrowingAlertMenu*))configBlock;

@end
