//
//  MBProgressHUD+GrowingHelper.m
//  GrowingExample
//
//  Created by BeyondChao on 2020/6/11.
//  Copyright © 2020 GrowingIO. All rights reserved.
//

#import "MBProgressHUD+GrowingHelper.h"

typedef NS_ENUM(NSInteger, GIOHUDContentStyle) {
    GIOHUDContentDefaultStyle = 0,//默认是白底黑字 Default
    GIOHUDContentBlackStyle = 1,//黑底白字
    GIOHUDContentCustomStyle = 2,//:自定义风格<由自己设置自定义风格的颜色>
};

CGFloat const delayTime = 1.2;

@implementation MBProgressHUD (GrowingHelper)


NS_INLINE MBProgressHUD *createNew(UIView *view) {
    if (view == nil) view = (UIView*)[UIApplication sharedApplication].delegate.window;
    return [MBProgressHUD showHUDAddedTo:view animated:YES];
}

NS_INLINE MBProgressHUD *growingBuildHUD(UIView *view, NSString *title, BOOL autoHidden) {
    MBProgressHUD *hud = createNew(view);
    //文字
    hud.label.text = title;
    //支持多行
    hud.label.numberOfLines = 0;
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    
    //设置默认风格
    if (GIODefaultHudStyle == 1) {
        hud.hudContentStyle(GIOHUDContentBlackStyle);
        
    } else if (GIODefaultHudStyle == 2) {
        hud.hudContentStyle(GIOHUDContentCustomStyle);
    }
    
    if (autoHidden) {
        // x秒之后消失
        [hud hideAnimated:YES afterDelay:delayTime];
    }
    
    return hud;
}

+ (void)showOnlyTextToView:(UIView *)view title:(NSString *)title {
    MBProgressHUD *hud = growingBuildHUD(view, title, YES);
    hud.mode = MBProgressHUDModeText;
}

+ (void)showOnlyTextToView:(UIView *)view title:(NSString *)title detail:(NSString *)detail {
    MBProgressHUD *hud = growingBuildHUD(view, title, YES);
    hud.detailsLabel.text = detail;
    hud.mode = MBProgressHUDModeText;
}

- (MBProgressHUD *(^)(GIOHUDContentStyle))hudContentStyle {
    return ^(GIOHUDContentStyle hudContentStyle){
        if (hudContentStyle == GIOHUDContentBlackStyle) {
            self.contentColor = [UIColor whiteColor];
            self.bezelView.backgroundColor = [UIColor blackColor];
            self.bezelView.style = MBProgressHUDBackgroundStyleBlur;
            
        } else if (hudContentStyle == GIOHUDContentCustomStyle) {
            self.contentColor = GIOCustomHudStyleContentColor;
            self.bezelView.backgroundColor = GIOCustomHudStyleBackgrandColor;
            self.bezelView.style = MBProgressHUDBackgroundStyleBlur;
            
        } else if (hudContentStyle == GIOHUDContentDefaultStyle){
            self.contentColor = [UIColor blackColor];
            self.bezelView.backgroundColor = [UIColor colorWithWhite:0.902 alpha:1.000];
            self.bezelView.style = MBProgressHUDBackgroundStyleBlur;
        }
        return self;
    };
}


@end
