//
//  GIOConstants
//  GrowingExample
//
//  Created by GrowingIO on 2018/6/1.
//  Copyright (C) 2018 Beijing Yishu Technology Co., Ltd.
//

#import <UIKit/UIKit.h>

//是否是iPhone X
// 判断是否为iPhone X 系列  这样写消除了在Xcode10上的警告。
#define is_iPhoneX \
({BOOL isPhoneX = NO;\
if (@available(iOS 11.0, *)) {\
isPhoneX = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0.0;\
}\
(isPhoneX);})
//状态栏高度
#define StatusBarHeight     (is_iPhoneX ? 44.f : 20.f)
// 导航高度
#define NavigationBarHeight 44.f
// Tabbar高度.   49 + 34 = 83
#define TabbarHeight        (is_iPhoneX ? 83.f : 49.f)
// Tabbar安全区域底部间隙
#define TabbarSafeBottomMargin  (is_iPhoneX ? 34.f : 0.f)
// 状态栏和导航高度
#define StatusBarAndNavigationBarHeight  (is_iPhoneX ? 88.f : 64.f)

#define TableView_Section_Height 44


@interface GIOConstants : NSObject

//定义常量，超过1000个字符的字符串
extern NSString *const OutRangeInput;
//超过100键值对的字典
extern NSDictionary *const lardic;

//获取字符串常量
+ (NSString *)getMyInput;

//返回超过100键值对的字典
+ (NSDictionary *)getLargeDictionary;

+ (UITableViewHeaderFooterView *)globalSectionHeaderForIdentifier:(NSString *)identifier;

@end
