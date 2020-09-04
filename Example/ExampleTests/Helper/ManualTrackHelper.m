//
//  ManualTrackHelper.m
//  GIOAutoTests
//
//  Created by GrowingIO on 2018/6/6.
//  Copyright (C) 2018 Beijing Yishu Technology Co., Ltd.
//  function:打点事件测试公共方法

#import "ManualTrackHelper.h"

#import "NoburPoMeaProCheck.h"

@implementation ManualTrackHelper

//判断字典dicts是否包含关键字ckchar
+ (Boolean *)CheckContainsKey:(NSDictionary *)dicts:(NSString *)ckchar {
    NSArray *allkeys = dicts.allKeys;
    for (int i = 0; i < allkeys.count; i++) {
        if ([allkeys[i] isEqualToString:ckchar]) {
            return TRUE;
        }
    }
    return FALSE;
}

// custom事件对比，测量协议字段完整且每个字段不为空
+ (NSDictionary *)customEventCheck:(NSDictionary *)customevent {
    NSDictionary *cstmchres;
    NSArray *cstmprome = @[
        @"userId", @"sessionId", @"eventType", @"timestamp", @"pageName", @"domain", @"eventName", @"num",
        @"attributes", @"globalSequenceId", @"eventSequenceId",@"deviceId",@"appState",@"urlScheme"
    ];
    //对比测量协议结构
    if (customevent.count > 0) {
        NSArray *checstm = customevent.allKeys;
        cstmchres = @{
            @"ProCheck" : [NoburPoMeaProCheck compareArray:cstmprome toAnother:checstm],
            @"KeysCheck" : [NoburPoMeaProCheck checkDictEmpty:customevent]
        };
    }
    return cstmchres;
}

// LOGIN_USER_ATTRIBUTES事件对比，测量协议字段完整且每个字段不为空
+ (NSDictionary *)PplEventCheck:(NSDictionary *)pplevent {
    NSDictionary *pplchres;
    NSArray *pplprome = @[
        @"userId", @"sessionId", @"eventType", @"timestamp", @"domain", @"attributes", @"userId", @"globalSequenceId",
        @"eventSequenceId",@"deviceId",@"appState",@"urlScheme"
    ];
    //对比测量协议结构
    if (pplevent.count > 0) {
        NSArray *cheppl = pplevent.allKeys;
        pplchres = @{
            @"ProCheck" : [NoburPoMeaProCheck compareArray:pplprome toAnother:cheppl],
            @"KeysCheck" : [NoburPoMeaProCheck checkDictEmpty:pplevent]
        };
    }
    return pplchres;
}

// pvar事件对比，测量协议字段完整且每个字段不为空
+ (NSDictionary *)PvarEventCheck:(NSDictionary *)pvarevent {
    NSDictionary *pvarchres;
    NSArray *pvarlprome = @[
        @"userId", @"sessionId", @"eventType", @"timestamp", @"domain", @"pageName", @"attributes", @"userId",
        @"globalSequenceId", @"eventSequenceId",@"deviceId",@"appState",@"urlScheme"
    ];
    //对比测量协议结构
    if (pvarevent.count > 0) {
        NSArray *chepvar = pvarevent.allKeys;
        pvarchres = @{
            @"ProCheck" : [NoburPoMeaProCheck compareArray:pvarlprome toAnother:chepvar],
            @"KeysCheck" : [NoburPoMeaProCheck checkDictEmpty:pvarevent]
        };
    }
    return pvarchres;
}

// CONVERSION_VARIABLES事件对比，测量协议字段完整且每个字段不为空
+ (NSDictionary *)conversionVariablesEventCheck:(NSDictionary *)evarevent {
    NSDictionary *evarchres;
    NSArray *evarlprome = @[
        @"userId", @"sessionId", @"eventType", @"timestamp", @"domain", @"attributes", @"userId", @"eventSequenceId",
        @"globalSequenceId",@"deviceId",@"appState",@"urlScheme"
    ];
    //对比测量协议结构
    if (evarevent.count > 0) {
        NSArray *cheevar = evarevent.allKeys;
        evarchres = @{
            @"ProCheck" : [NoburPoMeaProCheck compareArray:evarlprome toAnother:cheevar],
            @"KeysCheck" : [NoburPoMeaProCheck checkDictEmpty:evarevent]
        };
    }
    return evarchres;
}

// VISITOR_ATTRIBUTES 事件对比，测量协议字段完整且每个字段不为空
+ (NSDictionary *)visitorAttributesEventCheck:(NSDictionary *)visitorAttributesEvent {
    NSDictionary *visitor_chres;
    NSArray *visitor_prome = @[ @"userId", @"sessionId", @"eventType", @"timestamp", @"domain", @"attributes", @"userId",@"deviceId",@"appState",@"urlScheme" ];
    //对比测量协议结构
    if (visitorAttributesEvent.count > 0) {
        NSArray *chevstr = visitorAttributesEvent.allKeys;
        visitor_chres = @{
            @"ProCheck" : [NoburPoMeaProCheck compareArray:visitor_prome toAnother:chevstr],
            @"KeysCheck" : [NoburPoMeaProCheck checkDictEmpty:visitorAttributesEvent]
        };
    }
    return visitor_chres;
}

@end
