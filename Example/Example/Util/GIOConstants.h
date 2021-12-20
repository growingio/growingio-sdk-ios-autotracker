//
//  GIOConstants
//  GrowingExample
//
//  Created by GrowingIO on 2018/6/1.
//  Copyright (C) 2018 Beijing Yishu Technology Co., Ltd.
//

#import <UIKit/UIKit.h>

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
