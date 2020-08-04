//
//  GrowingLoginMenu.m
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


#import "GrowingLoginMenu.h"
#import "GrowingLoginModel.h"
#import "GrowingAlertMenu.h"

@interface GrowingLoginTextField : UITextField

@end

#define FONT_SIZE 20
#define LEFT_MARGIN 20

@implementation GrowingLoginTextField

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return self;
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    return CGRectMake(bounds.origin.x + 45,
                      bounds.origin.y + 20,
                      bounds.size.width - 90,
                      bounds.size.height-20);
}
- (CGRect)placeholderRectForBounds:(CGRect)bounds
{
    return [self textRectForBounds:bounds];
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return [self textRectForBounds:bounds];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(paste:))
        return NO;
    if (action == @selector(select:))
        return NO;
    if (action == @selector(selectAll:))
        return NO;
    return [super canPerformAction:action withSender:sender];
}

@end

@interface GrowingLoginMenu()<UITextFieldDelegate>

@property (nonatomic, retain) GrowingLoginTextField *txtUserId;
@property (nonatomic, strong) UIView *userIdLineView;

@property (nonatomic, retain) GrowingLoginTextField *txtPassword;
@property (nonatomic, strong) UIView *pwdLineView;


@property (nonatomic, copy) void(^succeedBlock)(void);
@property (nonatomic, copy) void(^failBlock)(void);

@end

@implementation GrowingLoginMenu

- (instancetype)initWithType:(GrowingMenuShowType)showType
{
    self = [super initWithType:showType];
    if (self)
    {
        self.title = @"登录";
        __weak GrowingLoginMenu *wself = self;
        self.menuButtons = @[
                             [GrowingMenuButton buttonWithTitle:@"取消" block:^{
                                 void (^failBlock)(void)  = wself.failBlock;
                                 [wself clearAlertView];
                                 [wself hide];
                                 
                                 if (failBlock) {
                                     failBlock();
                                 }
                             }],
                             [GrowingMenuButton buttonWithTitle:@"登录" block:^{
                                 [wself loginClick];
                             }]
                             ];

    }
    return self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.txtUserId)
    {
        [self.txtPassword becomeFirstResponder];
    }
    else if (textField == self.txtPassword)
    {
        [self.txtPassword resignFirstResponder];
        [self loginClick];
    }
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view addSubview:self.txtUserId];
    [self.view addSubview:self.userIdLineView];

    [self.view addSubview:self.txtPassword];
    [self.view addSubview:self.pwdLineView];
    
    if (@available(iOS 9.0, *)) {
        [self.txtUserId.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:0].active = YES;
        [self.txtUserId.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant:0].active = YES;
        [self.txtUserId.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:0].active = YES;
        [self.txtUserId.heightAnchor constraintEqualToConstant:64].active = YES;
        
        
        [self.txtPassword.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:0].active = YES;
        [self.txtPassword.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant:0].active = YES;
        [self.txtPassword.topAnchor constraintEqualToAnchor:self.txtUserId.bottomAnchor].active = YES;
        [self.txtPassword.heightAnchor constraintEqualToConstant:64].active = YES;
        
        [self.userIdLineView.leftAnchor constraintEqualToAnchor:self.txtUserId.leftAnchor constant:LEFT_MARGIN].active = YES;
        [self.userIdLineView.rightAnchor constraintEqualToAnchor:self.txtUserId.rightAnchor constant:-LEFT_MARGIN].active = YES;
        [self.userIdLineView.bottomAnchor constraintEqualToAnchor:self.txtUserId.bottomAnchor constant:0].active = YES;
        [self.userIdLineView.heightAnchor constraintEqualToConstant:1].active = YES;
        
        [self.pwdLineView.leftAnchor constraintEqualToAnchor:self.txtPassword.leftAnchor constant:LEFT_MARGIN].active = YES;
        [self.pwdLineView.rightAnchor constraintEqualToAnchor:self.txtPassword.rightAnchor constant:-LEFT_MARGIN].active = YES;
        [self.pwdLineView.bottomAnchor constraintEqualToAnchor:self.txtPassword.bottomAnchor constant:0].active = YES;
        [self.pwdLineView.heightAnchor constraintEqualToConstant:1].active = YES;
    }
}

- (CGFloat)preferredContentHeight
{
    return 160;
}

- (void)clearAlertView
{
    self.txtPassword.text = nil;
    self.txtUserId.text = nil;
    self.succeedBlock = nil;
    self.failBlock = nil;
}

- (void)loginClick
{
    [self loginById:self.txtUserId.text
                pwd:self.txtPassword.text];
}

- (void)loginById:(NSString*)aId pwd:(NSString*)pwd
{
    // 显示登录中
    GrowingAlertMenu *loadingMenu = [GrowingAlertMenu alertWithTitle:@"登录GrowingIO"
                                                                text:@"正在登录..."
                                                             buttons:nil];
    // 显示
    [loadingMenu show];
    // 隐藏自己
    [self hide];
    
    // 成功了
    void (^succeedBlock)(void) = ^{
        void (^succeedBlock)(void) = self.succeedBlock;

        [self clearAlertView];
        if (succeedBlock)
        {
            succeedBlock();
        }
        [loadingMenu hide];
    };
    
    // 失败了
    void(^faileBlock)(NSString *msg) = ^(NSString *msg){
        [GrowingAlertMenu alertWithTitle:@"登录GrowingIO"
                                    text:msg
                                 buttons:@[[GrowingMenuButton buttonWithTitle:@"确定"
                                                                        block:^{
                                                                            [self show];
                                                                        }]]];
        [loadingMenu hide];
    };
    
    
    [[GrowingLoginModel sdkInstance] loginByUserId:aId
                                            password:pwd
                                             succeed:succeedBlock
                                                fail:faileBlock];
}

static GrowingLoginMenu *loginMenu = nil;
static NSMutableArray<void (^)(void)> *succeedBlocks = nil;
static NSMutableArray<void (^)(void)> *failBlocks = nil;
+ (void)showWithSucceed:(void (^)(void))succeedBlock
                   fail:(void (^)(void))failBlock
{
    // TODO: add circle logic
//    if ([GrowingWebSocket isRunning])
//    {
//        failBlock();
//        return;
//    }

    if (!succeedBlocks)
    {
        succeedBlocks = [[NSMutableArray alloc] init];
    }
    if (succeedBlock)
    {
        [succeedBlocks addObject:succeedBlock];
    }
    
    if (!failBlocks)
    {
        failBlocks = [[NSMutableArray alloc] init];
    }
    if (failBlock)
    {
        [failBlocks addObject:failBlock];
    }
    
    
    if (loginMenu)
    {
        return;
    }
    loginMenu = [[GrowingLoginMenu alloc] init];
    loginMenu.succeedBlock = ^{
        [succeedBlocks enumerateObjectsUsingBlock:^(void (^ _Nonnull obj)(), NSUInteger idx, BOOL * _Nonnull stop) {
            obj();
        }];
        [self clearGrowingLoginMenu];
    };
    loginMenu.failBlock = ^{
        [failBlocks enumerateObjectsUsingBlock:^(void (^ _Nonnull obj)(), NSUInteger idx, BOOL * _Nonnull stop) {
            obj();
        }];
        
        [self clearGrowingLoginMenu];
    };
    [loginMenu show];
}

+ (void)showIfNeededSucceed:(void (^)(void))succeedBlock fail:(void (^)(void))failBlock
{
    if ([GrowingLoginModel sdkInstance].token.length)
    {
        succeedBlock();
    }
    else
    {
        [self showWithSucceed:succeedBlock fail:failBlock];
    }
}

+ (void)clearGrowingLoginMenu
{
    [loginMenu hide];
    loginMenu = nil;
    [succeedBlocks removeAllObjects];
    succeedBlocks = nil;
    [failBlocks removeAllObjects];
    failBlocks = nil;
}

#pragma mark Lazy Load

- (GrowingLoginTextField *)txtUserId {
    if (!_txtUserId) {
        _txtUserId = [[GrowingLoginTextField alloc] initWithFrame:CGRectZero];
        UIFont *font = [UIFont systemFontOfSize:FONT_SIZE];

        NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:@"邮箱地址"
                                                                                         attributes:@{NSForegroundColorAttributeName:[UIColor lightTextColor],
                                                                                                      NSFontAttributeName:font}];
        _txtUserId.font = font;
        [_txtUserId setAutocorrectionType:UITextAutocorrectionTypeNo];
        [_txtUserId setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        _txtUserId.attributedPlaceholder = attributeStr;
        _txtUserId.delegate = self;
    }
    return _txtUserId;
}

- (GrowingLoginTextField *)txtPassword {
    if (!_txtPassword) {
        _txtPassword = [[GrowingLoginTextField alloc] initWithFrame:CGRectZero];
        UIFont *font = [UIFont systemFontOfSize:FONT_SIZE];

        NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:@"密码"
                                                                                         attributes:@{NSForegroundColorAttributeName:[UIColor lightTextColor],
                                                                                                      NSFontAttributeName:font}];
        _txtPassword.font = font;
        _txtPassword.secureTextEntry = YES;
        _txtPassword.attributedPlaceholder = attributeStr;
        _txtPassword.delegate = self;
    }
    return _txtPassword;
}

- (UIView *)userIdLineView {
    if (!_userIdLineView) {
        _userIdLineView = [[UIView alloc] initWithFrame:CGRectZero];
        _userIdLineView.backgroundColor = [UIColor cyanColor];
        _userIdLineView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _userIdLineView;
}

- (UIView *)pwdLineView {
    if (!_pwdLineView) {
        _pwdLineView = [[UIView alloc] initWithFrame:CGRectZero];
        _pwdLineView.backgroundColor = [UIColor cyanColor];
        _pwdLineView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _pwdLineView;
}


@end
