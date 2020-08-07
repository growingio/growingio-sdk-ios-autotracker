//
//  GrowingAlertMenu.m
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


#import "GrowingAlertMenu.h"

@interface GrowingAlertMenu()
@property (nonatomic, retain) NSArray<GrowingMenuButton*> *buttons;

@property (nonatomic, retain) UILabel *txtTextLabel;
@property (nonatomic, retain) UILabel *txtTextLabel2;
@end

@implementation GrowingAlertMenu

+ (instancetype)alertOnlyText:(NSString *)text buttons:(NSArray<GrowingMenuButton *> *)buttons
{
    return [self alertWithButtons:buttons
                      configBlock:^(GrowingAlertMenu *menu) {
                          menu.text = text;
                          menu.navigationBarHidden = YES;
                      }];
}

+ (instancetype)alertWithTitle:(NSString *)title text:(NSString *)text buttons:(NSArray<GrowingMenuButton *> *)buttons
{
    return [self alertWithButtons:buttons
                      configBlock:^(GrowingAlertMenu *menu) {
                          menu.title = title;
                          menu.text = text;
                      }];
}

+ (instancetype)alertWithTitle:(NSString *)title text1:(NSString *)text1 text2:(NSString *)text2 buttons:(NSArray<GrowingMenuButton *> *)buttons
{
    return [self alertWithButtons:buttons
                      configBlock:^(GrowingAlertMenu *menu) {
                          menu.title = title;
                          menu.text = text1;
                          menu.text2 = text2;
                      }];
}

+ (instancetype)alertWithActionArray:(NSArray *)action
                              config:(void (^)(GrowingAlertMenu *))configBlock
{
    NSMutableArray *btns = [[NSMutableArray alloc] init];
    for (NSInteger i = 1 ; i < action.count ; i += 2)
    {
        GrowingMenuButton *btn = [GrowingMenuButton buttonWithTitle:action[i-1]
                                                              block:action[i]];
        [btns addObject:btn];
    }

    return [self alertWithButtons:btns
                      configBlock:configBlock];
}

+ (instancetype)alertWithButtons:(NSArray<GrowingMenuButton *> *)buttons
                   configBlock:(void(^)(GrowingAlertMenu*))configBlock
{
    GrowingAlertMenu *menu = [[self alloc] init];
    menu.buttons = buttons;
    NSMutableArray *menubuttons = [[NSMutableArray alloc] init];
    __weak GrowingAlertMenu *wself = menu;
    for (GrowingMenuButton *btn in buttons)
    {
        void(^block)(void) = btn.block;
        GrowingMenuButton *newBtn = [GrowingMenuButton buttonWithTitle:btn.title
                                                                  block:^{
                                                                      GrowingAlertMenu *sself = wself;
                                                                      if (!sself)
                                                                      {
                                                                          return ;
                                                                      }
                                                                      if (block)
                                                                      {
                                                                          block();
                                                                      }
                                                                      [sself hide];
                                                                  }];
        [menubuttons addObject:newBtn];
    }
    
    menu.menuButtons = menubuttons;
    
    if (configBlock)
    {
        configBlock(menu);
    }
    
    [menu show];
    
    return menu;
}

- (instancetype)init
{
    return [self initWithType:GrowingMenuShowTypeAlert];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationView.backgroundColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];
    self.titleLabel.textColor = [UIColor blackColor];
    
    if (self.text2) {

        [self.view addSubview:self.txtTextLabel];
        [self.view addSubview:self.txtTextLabel2];
        
        if (@available(iOS 9.0, *)) {
            [self.txtTextLabel.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:20].active = YES;
            [self.txtTextLabel.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant:20].active = YES;
            [self.txtTextLabel.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:20].active = YES;
            [self.txtTextLabel.heightAnchor constraintEqualToConstant:50].active = YES;
            
            [self.txtTextLabel2.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:20].active = YES;
            [self.txtTextLabel2.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant:20].active = YES;
            [self.txtTextLabel2.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:50].active = YES;
            [self.txtTextLabel2.heightAnchor constraintEqualToConstant:50].active = YES;
        }
        
        if (self.text) {
            self.text = self.text;
        }
        
        self.text2 = self.text2;
        
    } else {
        [self.view addSubview:self.txtTextLabel];

        if (@available(iOS 9.0, *)) {
            [self.txtTextLabel.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:20].active = YES;
            [self.txtTextLabel.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant:-20].active = YES;
            [self.txtTextLabel.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:0].active = YES;
            [self.txtTextLabel.heightAnchor constraintEqualToConstant:100].active = YES;
        }
        if (self.text) {
            self.text = self.text;
        }
    }

    self.preferredContentHeight = 110;
}

- (void)setText:(NSString *)text
{
    _text = text;
    self.txtTextLabel.text = text;
}

- (void)setText2:(NSString *)text2
{
    _text2  = text2;
    self.txtTextLabel2.text = text2;
}

#pragma mark Lazy Load

- (UILabel *)txtTextLabel {
    if (!_txtTextLabel) {
        _txtTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _txtTextLabel.font = [UIFont systemFontOfSize:18];
        _txtTextLabel.textColor = [UIColor darkTextColor];
        _txtTextLabel.numberOfLines = 0;
        _txtTextLabel.textAlignment = NSTextAlignmentLeft;
        _txtTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _txtTextLabel;
}

- (UILabel *)txtTextLabel2 {
    if (!_txtTextLabel2) {
        _txtTextLabel2 = [[UILabel alloc] initWithFrame:CGRectZero];
        _txtTextLabel2.font = [UIFont systemFontOfSize:18];
        _txtTextLabel2.textColor = [UIColor darkTextColor];
        _txtTextLabel2.numberOfLines = 1;
        _txtTextLabel2.textAlignment = NSTextAlignmentLeft;
        _txtTextLabel2.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _txtTextLabel2;
}

@end
