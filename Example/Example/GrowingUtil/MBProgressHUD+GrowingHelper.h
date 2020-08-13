//
//  MBProgressHUD+GrowingHelper.h
//  GrowingExample
//
//  Created by BeyondChao on 2020/6/11.
//  Copyright © 2020 GrowingIO. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>

#define GIODefaultHudStyle  1

/**
 * 风格为自定义时，在这里设置颜色
 */
#define GIOCustomHudStyleBackgrandColor  [UIColor colorWithWhite:0.f alpha:0.7f]
#define GIOCustomHudStyleContentColor    [UIColor colorWithWhite:1.f alpha:0.7f]


//默认持续显示时间(x秒后消失)
UIKIT_EXTERN CGFloat const delayTime;

NS_ASSUME_NONNULL_BEGIN

@interface MBProgressHUD (GrowingHelper)

/**
 纯文字
 */
+ (void)showOnlyTextToView:(UIView *)view title:(NSString *)title;

/**
 纯文字标题 + 详情
 */
+ (void)showOnlyTextToView:(UIView *)view title:(NSString *)title detail:(NSString *)detail;


@end

NS_ASSUME_NONNULL_END
