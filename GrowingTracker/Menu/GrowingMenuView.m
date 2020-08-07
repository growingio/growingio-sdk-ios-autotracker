//
//  GrowingMenuView.m
//  GrowingTracker
//
//  Created by GrowingIO on 15/11/6.
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
#import "GrowingMenu.h"
#import "UIControl+GrowingHelper.h"
#import "GrowingInstance.h"

@interface GrowingMenuButton()
@property (nonatomic, weak) GrowingMenuView *hostView;
@property (nonatomic, retain) UIView* customView;
@end

@interface GrowingMenuView()

@property (nonatomic, assign) CGSize maxSize;

@property (nonatomic, retain) UIScrollView *scrollView;
// views
@property (nonatomic, retain) UIView *leftButtonView;
@property (nonatomic, retain) UIView *rightButtonView;

@property (nonatomic, assign) CGFloat menuButtonsHeight;
@property (nonatomic, retain) NSMutableArray<UIButton *> * menuButtonViews;

@property (nonatomic, assign) BOOL buildContentFinish;

- (void)updateButton:(GrowingMenuButton *)button;

@end

@implementation GrowingMenuPageView

- (void)show
{
    self.showTime = GROWGetTimestamp();
    if (!self.createTime)
    {
        self.createTime = self.showTime;
    }
    [super show];
}

- (NSString*)growingViewContent
{
    return NSStringFromClass(self.class);
}

@end

@implementation GrowingMenuButton

+ (instancetype)buttonWithCustomView:(UIView *)customView
{
    GrowingMenuButton *btn = [[self alloc] init];
    btn.userInteractionEnabled = YES;
    btn.customView = customView;
    return btn;
}

+ (instancetype)buttonWithTitle:(NSString *)title block:(void (^)(void))block
{
    GrowingMenuButton *btn = [[self alloc] init];
    btn.title = title;
    btn.block = block;
    btn.userInteractionEnabled = YES;
    
    return btn;
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    if (self.hostView != nil)
    {
        [self.hostView updateButton:self];
    }
}

- (void)setAttrTitle:(NSAttributedString *)attrTitle
{
    _attrTitle = attrTitle;
    if (self.hostView != nil)
    {
        [self.hostView updateButton:self];
    }
}

- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled
{
    _userInteractionEnabled = userInteractionEnabled;
    if (self.hostView != nil)
    {
        [self.hostView updateButton:self];
    }
}

- (void)setBlock:(void (^)(void))block
{
    _block = block;
    if (self.hostView != nil)
    {
        [self.hostView updateButton:self];
    }
}

@end

#define NavigationBarHeight 50

@implementation GrowingMenuView

- (void)setActive:(BOOL)active
{
    if (_active == active)
    {
        return;
    }
    _active = active;
    if (!self.shadowMaskView)
    {
        self.shadowMaskView = [[UIView alloc] initWithFrame:self.bounds];
        self.shadowMaskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        self.shadowMaskView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:self.shadowMaskView];
    }
    [self bringSubviewToFront:self.shadowMaskView];
    if (active)
    {
        self.shadowMaskView.alpha = 0;
    }
    else
    {
        self.shadowMaskView.alpha = 1;
    }
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(99999, 99999);
}

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithType:GrowingMenuShowTypeAlert];
}

- (instancetype)initWithType:(GrowingMenuShowType)showType
{
    CGRect frame = [UIScreen mainScreen].bounds;
    CGSize maxSize = [GrowingMenu maxSizeForType:showType];
    frame.origin.x = (frame.size.width - maxSize.width) / 2;
    frame.origin.y = (frame.size.height - maxSize.height) / 2;
    frame.size = maxSize;
    
    self = [super initWithFrame:frame];
    if (self)
    {
        _showType = showType;
        self.maxSize = maxSize;
        self.backgroundColor = [UIColor whiteColor];
        self.menuButtonViews = [[NSMutableArray alloc] init];
        self.navigationBarColor = [UIColor cyanColor];
        self.titleColor = [UIColor darkTextColor];
    }
    return self;
}

- (void)setNeedResizeAndLayout
{
    if (!self.isViewLoaded)
    {
        return;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(resizeAndLayout)
                                               object:nil];
    [self performSelector:@selector(resizeAndLayout)
               withObject:nil
               afterDelay:0];
}

- (void)resizeAndLayout
{
    CGRect frame = [UIScreen mainScreen].bounds;
    CGSize maxSize = [GrowingMenu maxSizeForType:self.showType];
    frame.origin.x = (frame.size.width - maxSize.width) / 2;
    frame.origin.y = (frame.size.height - maxSize.height) / 2;
    frame.size = maxSize;
    self.maxSize = maxSize;
    
    CGFloat contentViewY = 0;
    CGRect navigationBarFrame = self.navigationView.frame;
    navigationBarFrame.size.width = self.maxSize.width;
    if (self.navigationBarHidden)
    {
        navigationBarFrame.origin.y = - NavigationBarHeight;
    }
    else
    {
        navigationBarFrame.origin.y = 0;
        contentViewY = NavigationBarHeight;
    }
    self.navigationView.frame = navigationBarFrame;
    
    
    CGFloat preferHeight = [self preferredContentHeight];
    CGFloat selfHeight = 0;
    if (self.showType == GrowingMenuShowTypePresent)
    {
        selfHeight = self.maxSize.height;
    }
    else
    {
        selfHeight = MIN(self.maxSize.height,
                         [self preferredContentHeight]
                         + contentViewY
                         + self.menuButtonsHeight);
    }
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    self.frame = CGRectMake((screenSize.width - self.maxSize.width) / 2,
                            (screenSize.height - selfHeight) / 2,
                            self.maxSize.width,
                            selfHeight);
    
    CGFloat contentHeight = selfHeight - contentViewY - self.menuButtonsHeight;
    
    self.scrollView.frame = CGRectMake(0,
                                 contentViewY,
                                 self.bounds.size.width,
                                 contentHeight);
    self.scrollView.contentSize = CGSizeMake(self.bounds.size.width, preferHeight);
    
    self.view.frame = CGRectMake(0,0,self.scrollView.contentSize.width,self.scrollView.contentSize.height);
    [self layoutIfNeeded];
}

- (void)layoutSubviews
{
    [self resizeAndLayout];
    
    [self sendSubviewToBack:self.scrollView];
    [self bringSubviewToFront:self.navigationView];
    [self bringSubviewToFront:self.shadowMaskView];
    [super layoutSubviews];
}

- (void)setNavigationBarColor:(UIColor *)navigationBarColor
{
    _navigationBarColor = navigationBarColor;
    self.navigationView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.9];
}

- (void)loadView
{
    // 导航
    UIView *navBar = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.bounds.size.width,NavigationBarHeight)];
    navBar.backgroundColor = self.navigationBarColor;
    [self addSubview:navBar];
    self.navigationView = navBar;
    
    [navBar addSubview:self.titleLabel];
    
    if (@available(iOS 9.0, *)) {
        [self.titleLabel.centerXAnchor constraintEqualToAnchor:navBar.centerXAnchor].active = YES;
        [self.titleLabel.centerYAnchor constraintEqualToAnchor:navBar.centerYAnchor].active = YES;
    }
    
    // 按钮
    NSArray<GrowingMenuButton*> *buttons = [self menuButtons];
    
    // 容器
    //fix ios7 crash  fuck!!!!!
    CGFloat buttonHeight = 0;
    if (buttons.count == 0)
    {
        
    }
    else if (buttons.count <= 2)
    {
        buttonHeight = NavigationBarHeight;
    }
    else
    {
        buttonHeight = NavigationBarHeight * buttons.count;
    }
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.alwaysBounceVertical = self.alwaysBounceVertical;
    [self addSubview:self.scrollView];
    
    self.view = [[UIView alloc] initWithFrame:self.bounds];
    [self.scrollView addSubview:self.view];

    // 按钮
    CGFloat addHeight = 0;
    if (buttons.count == 0)
    {
        // do nothing
    }
    else if (buttons.count <= 2)
    {
        CGFloat percent = 1.0f / buttons.count;
        __block UIButton *lastBtn = nil;
        for (int i = 0 ; i < buttons.count; i++)
        {
            GrowingMenuButton *btnObj = buttons[i];
            btnObj.hostView = self;
            
            UIButton *btn = [self buildButtonWithMenuBtn:btnObj
                                              titleColor: (i==1) ? [UIColor redColor] :  [UIColor grayColor]];
            [self addSubview:btn];
            
            if (@available(iOS 9.0, *)) {
                
                if (!lastBtn) {
                    [btn.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:0].active = YES;
                } else {
                    [btn.leftAnchor constraintEqualToAnchor:lastBtn.rightAnchor constant:0].active = YES;
                }

                if (i == buttons.count - 1) {
                    [btn.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:0].active = YES;
                } else {
                    [btn.widthAnchor constraintEqualToAnchor:self.widthAnchor multiplier:percent].active = YES;
                }
                
                [btn.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
                [btn.heightAnchor constraintEqualToConstant:NavigationBarHeight].active = YES;
            }
            
            [self.menuButtonViews addObject:btn];
            lastBtn = btn;
            
            // top seperator line view
            UIView *topLineView = [self buildLineView];
            [btn addSubview:topLineView];
            if (@available(iOS 9.0, *)) {
                [topLineView.leftAnchor constraintEqualToAnchor:btn.leftAnchor].active = YES;
                [topLineView.widthAnchor constraintEqualToAnchor:btn.widthAnchor].active = YES;
                [topLineView.heightAnchor constraintEqualToConstant:1].active = YES;
                [topLineView.topAnchor constraintEqualToAnchor:btn.topAnchor].active = YES;
            }
            
            if (i != 0) {
                // middle seperator line view
                UIView *middleLineView = [self buildLineView];
                [btn addSubview:middleLineView];
                if (@available(iOS 9.0, *)) {
                    [middleLineView.leftAnchor constraintEqualToAnchor:btn.leftAnchor].active = YES;
                    [middleLineView.widthAnchor constraintEqualToConstant:1].active = YES;
                    [middleLineView.heightAnchor constraintEqualToAnchor:btn.heightAnchor].active = YES;
                    [middleLineView.topAnchor constraintEqualToAnchor:btn.topAnchor].active = YES;
                }
            }
        }
        addHeight = NavigationBarHeight;
    }
    else
    {
        for (NSUInteger i = 0 ; i < buttons.count ; i++)
        {
            GrowingMenuButton *btnObj = buttons[i];
            btnObj.hostView = self;
            UIButton *btn = [self buildButtonWithMenuBtn:btnObj titleColor:[UIColor grayColor]];
            [self addSubview:btn];
            
            if (@available(iOS 9.0, *)) {
                [btn.leftAnchor constraintEqualToAnchor:self.leftAnchor].active = YES;
                [btn.rightAnchor constraintEqualToAnchor:self.rightAnchor].active = YES;
                CGFloat offset = -1 * (CGFloat)(buttons.count - 1 - i) * NavigationBarHeight;
                [btn.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:offset].active = YES;
                [btn.heightAnchor constraintEqualToConstant:NavigationBarHeight].active = YES;
                if (i == 0) {
                    [btn.topAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
                }
            }
            
            UIView *lineView = [self buildLineView];
            [btn addSubview:lineView];

            if (@available(iOS 9.0, *)) {
                [lineView.leftAnchor constraintEqualToAnchor:btn.leftAnchor].active = YES;
                [lineView.rightAnchor constraintEqualToAnchor:btn.rightAnchor].active = YES;
                [lineView.topAnchor constraintEqualToAnchor:btn.topAnchor].active = YES;
                [lineView.heightAnchor constraintEqualToConstant:1].active = YES;
            }

            [self.menuButtonViews addObject:btn];
        }
        addHeight = buttons.count * NavigationBarHeight;
    }
    self.menuButtonsHeight = addHeight;

    [self updateTitleButton:YES];
    [self updateTitleButton:NO];
    self.title = self.title;
    [self resizeAndLayout];
}

- (UIButton *)buildButtonWithMenuBtn:(GrowingMenuButton *)btnObj titleColor:(UIColor *)titleColor {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.userInteractionEnabled = btnObj.userInteractionEnabled;
    button.enabled = btnObj.userInteractionEnabled;
    button.growingHelper_onClick = btnObj.block;
    [button setTitleColor:titleColor forState:UIControlStateNormal];
    [button setTitle:btnObj.title forState:UIControlStateNormal];
    button.backgroundColor = [UIColor whiteColor];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    return button;
}

- (UIView *)buildLineView {
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectZero];
    lineView.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.3];
    lineView.translatesAutoresizingMaskIntoConstraints = NO;
    return lineView;
}

- (void)setTitle:(NSString *)title
{
    _title = [title copy];
    self.titleLabel.text = title;
}

- (void)viewDidLoad
{
    // do nothing
}

- (UIView*)view
{
    if (!_view)
    {
        [self loadView];
        if (_view)
        {
            [self viewDidLoad];
        }
    }
    return _view;
}

- (BOOL)isViewLoaded
{
    return _view != nil;
}

- (void)show
{
    [self showWithFinishBlock:nil];
}

- (void)showWithFinishBlock:(void (^)(void))block
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [GrowingMenu showMenuView:self showType:self.showType complate:block];
    
    
}

- (void)keyboardDidShow:(NSNotification*)noti
{
    CGRect scrollViewRect = [self.scrollView.superview convertRect:self.scrollView.frame toView:self.scrollView.window];
    
    CGRect keyBoardFrame = [[noti.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGFloat scrollViewBottom = scrollViewRect.origin.y + scrollViewRect.size.height;
    CGFloat keyBoardTop = keyBoardFrame.origin.y;
    
    if (scrollViewBottom > keyBoardTop)
    {
        UIEdgeInsets inset = self.scrollView.contentInset;
        inset.bottom = scrollViewBottom - keyBoardTop;
        self.scrollView.contentInset = inset;
        self.scrollView.scrollIndicatorInsets = inset;
    }
}

- (void)keyboardDidHide
{
    self.scrollView.contentInset = UIEdgeInsetsZero;
    self.scrollView.scrollIndicatorInsets = UIEdgeInsetsZero;
}

- (void)hide
{
    [self hideWithFinishBlock:nil];
}

- (void)hideWithFinishBlock:(void (^)(void))block
{
    [self keyboardDidHide];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];


    [GrowingMenu hideMenuView:self showType:self.showType complate:block];
}

- (void)updateTitleButton:(BOOL)isLeft
{
    GrowingMenuButton *menuButton = isLeft ? self.leftButton : self.rightButton;
    UIView *btnView = isLeft ? self.leftButtonView : self.rightButtonView;
    
    if (self.isViewLoaded)
    {
        if (menuButton)
        {
            if (!btnView)
            {
                if (menuButton.customView)
                {
                    btnView = menuButton.customView;
                    btnView.translatesAutoresizingMaskIntoConstraints = NO;
                    [self.navigationView addSubview:btnView];
                    
                    if (@available(iOS 9.0, *)) {
                        [btnView.heightAnchor constraintEqualToConstant:btnView.frame.size.height].active = YES;
                        [btnView.widthAnchor constraintEqualToConstant:btnView.frame.size.width].active = YES;
                        [btnView.centerYAnchor constraintEqualToAnchor:self.navigationView.centerYAnchor].active = YES;
                        
                        if (isLeft) {
                            [btnView.leftAnchor constraintEqualToAnchor:self.navigationView.leftAnchor constant:10].active = YES;
                        } else {
                            [btnView.rightAnchor constraintEqualToAnchor:self.navigationView.rightAnchor constant:-10].active = YES;
                        }
                    }
                } else {

                    UIButton *tempBtn = [[UIButton alloc] initWithFrame:CGRectZero];
                    tempBtn.translatesAutoresizingMaskIntoConstraints = NO;
                    [tempBtn setTitle:menuButton.title forState:UIControlStateNormal];
                    [tempBtn setTitleColor:self.tintColor forState:UIControlStateNormal];
                    [tempBtn setTitleColor:[UIColor lightTextColor] forState:UIControlStateDisabled];
                    tempBtn.titleLabel.font = [UIFont systemFontOfSize:16];
                    
                    btnView = tempBtn;
                    [self.navigationView addSubview:btnView];
                    
                    if (@available(iOS 9.0, *)) {
                        [btnView.topAnchor constraintEqualToAnchor:self.navigationView.topAnchor].active = YES;
                        [btnView.bottomAnchor constraintEqualToAnchor:self.navigationView.bottomAnchor].active = YES;
                        [btnView.widthAnchor constraintEqualToConstant:60].active = YES;
                        
                        if (isLeft) {
                            [btnView.leftAnchor constraintEqualToAnchor:self.navigationView.leftAnchor constant:0].active = YES;
                        } else {
                            [btnView.rightAnchor constraintEqualToAnchor:self.navigationView.rightAnchor constant:0].active = YES;
                        }
                    }
                }
            }
            if (isLeft)
            {
                self.leftButtonView = btnView;
            }
            else
            {
                self.rightButtonView = btnView;
            }
            if (!menuButton.customView)
            {
                UIButton *button = (id)btnView;
                [button setTitle:menuButton.title forState:0];
                button .growingHelper_onClick = menuButton.block;
                button.enabled = menuButton.userInteractionEnabled;
                button.userInteractionEnabled = menuButton.userInteractionEnabled;
            }
        }
        else
        {
            if (btnView)
            {
                [btnView removeFromSuperview];
                if (isLeft)
                {
                    self.leftButtonView = nil;
                }
                else
                {
                    self.rightButtonView = nil;
                }
            }
        }
    }
}

- (void)setNavigationBarHidden:(BOOL)navigationBarHidden
{
    if (_navigationBarHidden == navigationBarHidden)
    {
        return;
    }
    _navigationBarHidden = navigationBarHidden;
    [self setNeedResizeAndLayout];
}

- (void)setLeftButton:(GrowingMenuButton *)leftButton
{
    if (_leftButton != nil)
    {
        _leftButton.hostView = nil;
    }
    _leftButton = leftButton;
    _leftButton.hostView = self;
    [self updateTitleButton:YES];
}

- (void)setRightButton:(GrowingMenuButton *)rightButton
{
    if (_rightButton != nil)
    {
        _rightButton.hostView = nil;
    }
    _rightButton = rightButton;
    _rightButton.hostView = self;
    [self updateTitleButton:NO];
}

- (void)setAlwaysBounceVertical:(BOOL)alwaysBounceVertical
{
    _alwaysBounceVertical = alwaysBounceVertical;
    self.scrollView.alwaysBounceVertical = alwaysBounceVertical;
}

- (void)setPreferredContentHeight:(CGFloat)preferredContentHeight
{
    CGFloat diff = _preferredContentHeight - preferredContentHeight ;
    if (ABS(diff) < 0.01)
    {
        return;
    }
    _preferredContentHeight = preferredContentHeight;
    [self setNeedResizeAndLayout];
}

- (void)updateButton:(GrowingMenuButton *)button
{
    if (button.hostView == nil)
    {
        return;
    }
    if (self.leftButton == button || self.rightButton == button)
    {
        [self updateTitleButton:(self.leftButton == button)];
        return;
    }
    for (NSUInteger i = 0; i < self.menuButtons.count; i++)
    {
        if (self.menuButtons[i] == button)
        {
            if (i < self.menuButtonViews.count)
            {
                UIButton * btn = self.menuButtonViews[i];
                [btn setTitle:button.title forState:0];
                btn.userInteractionEnabled = button.userInteractionEnabled;
                
                if ( btn.enabled != button.userInteractionEnabled)
                {
                    btn.enabled = button.userInteractionEnabled;
                    if (btn.enabled)
                    {
                        btn.backgroundColor = [UIColor clearColor];
                        [btn setTitleColor:[UIColor grayColor] forState:0];
                    }
                    else
                    {
                        btn.backgroundColor = [UIColor grayColor];
                        [btn setTitleColor:[UIColor whiteColor] forState:0];
                    }
                }
                btn.growingHelper_onClick = button.block;
            }
            return;
        }
    }
}

#pragma mark Lazy Load

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textColor = self.titleColor;
        _titleLabel.font = [UIFont systemFontOfSize:20];
        _titleLabel.numberOfLines = 1;
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _titleLabel;
}

@end



