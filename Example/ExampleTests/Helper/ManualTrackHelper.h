//
//  ManualTrackHelper.h
//  GIOAutoTests
//
//  Created by GrowingIO on 2018/6/6.
//  Copyright (C) 2018 Beijing Yishu Technology Co., Ltd.
//

#import <Foundation/Foundation.h>

@interface ManualTrackHelper : NSObject
//判断字典dicts是否包含关键字ckchar
+ (Boolean *)CheckContainsKey:(NSDictionary *)dicts:(NSString *)ckchar;

// cstm事件对比，测量协议字段完整且每个字段不为空
+ (NSDictionary *)customEventCheck:(NSDictionary *)cstmevent;

// LOGIN_USER_ATTRIBUTES事件对比，测量协议字段完整且每个字段不为空
+ (NSDictionary *)PplEventCheck:(NSDictionary *)pplevent;

// pvar事件对比，测量协议字段完整且每个字段不为空
+ (NSDictionary *)PvarEventCheck:(NSDictionary *)pvarevent;

// CONVERSION_VARIABLES事件对比，测量协议字段完整且每个字段不为空
+ (NSDictionary *)conversionVariablesEventCheck:(NSDictionary *)evarevent;

// VISITOR_ATTRIBUTES 事件对比，测量协议字段完整且每个字段不为空
+ (NSDictionary *)visitorAttributesEventCheck:(NSDictionary *)visitorAttributesEvent;
@end
