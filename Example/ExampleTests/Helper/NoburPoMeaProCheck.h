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
+ (NSDictionary *)ComNSArray:(NSArray *)arr1:(NSArray *)arr2;

//判断NSDictionary是否存在空关键字
+ (NSDictionary *)CheckDictEmpty:(NSDictionary *)ckdict;

// Vst事件对比，测量协议字段完整且每个字段不为空
+ (NSDictionary *)visitEventCheck:(NSDictionary *)vstevent;

// clck事件对比，测量协议字段完整且每个字段不为空
+ (NSDictionary *)clickEventCheck:(NSDictionary *)clckevent;

// VIEW_CHANGE事件对比，测量协议字段完整且每个字段不为空
+ (NSDictionary *)viewChangeEventCheck:(NSDictionary *)chngevent;

// imp事件对比，测量协议字段完整且每个字段不为空
+ (NSDictionary *)ImpEventCheck:(NSDictionary *)impevent;
@end
