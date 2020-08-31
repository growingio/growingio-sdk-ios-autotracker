//
//  NoburPoMeaProCheck.h
//  GIOAutoTests
//
//  Created by GrowingIO on 2018/5/22.
//  Copyright (C) 2018 Beijing Yishu Technology Co., Ltd.
//

#import <Foundation/Foundation.h>

@interface NoburPoMeaProCheck : NSObject

//字段串是否为空
+ (BOOL)isBlankString:(NSString *)aStr;

//对比两个NSArray
+ (NSDictionary *)compareArray:(NSArray *)arr1 toAnother:(NSArray *)arr2;

//判断NSDictionary是否存在空关键字
+ (NSDictionary *)checkDictEmpty:(NSDictionary *)ckdict;

// Vst事件对比，测量协议字段完整且每个字段不为空
+ (NSDictionary *)visitEventCheck:(NSDictionary *)visitevent;

// click事件对比，测量协议字段完整且每个字段不为空
+ (NSDictionary *)clickEventCheck:(NSDictionary *)clickevent;

// VIEW_CHANGE事件对比，测量协议字段完整且每个字段不为空
+ (NSDictionary *)viewChangeEventCheck:(NSDictionary *)chngevent;

// imp事件对比，测量协议字段完整且每个字段不为空
+ (NSDictionary *)ImpEventCheck:(NSDictionary *)impevent;
@end
