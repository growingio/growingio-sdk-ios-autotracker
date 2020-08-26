//
//  NoburPoMeaProCheck.m
//  GIOAutoTests
//
//  Created by GrowingIO on 2018/5/22.
//  Copyright (C) 2018 Beijing Yishu Technology Co., Ltd.
//  Function:无埋点测量协议对比

#import "NoburPoMeaProCheck.h"

@implementation NoburPoMeaProCheck
//字段串是否为空
+ (BOOL)isBlankString:(NSString *)aStr {
    if (!aStr) {
        return YES;
    }
    if ([aStr isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if (!aStr.length) {
        return YES;
    }
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmedStr = [aStr stringByTrimmingCharactersInSet:set];
    if (!trimmedStr.length) {
        return YES;
    }
    return NO;
}
//对比两个NSArray
+ (NSDictionary *)ComNSArray:(NSArray *)arr1:(NSArray *)arr2 {
    NSDictionary *cmpres;
    NSArray *reduce = [arr1 filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT (SELF in %@)", arr2]];
    NSArray *incre = [arr2 filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT (SELF in %@)", arr1]];
    if (reduce.count == 0 && incre.count == 0) {
        cmpres = @{@"chres" : @"same", @"reduce" : @"", @"incre" : @""};
    } else {
        cmpres = @{@"chres" : @"different", @"reduce" : reduce, @"incre" : incre};
    }
    return cmpres;
}
//判断NSDictionary是否存在空关键字
+ (NSDictionary *)CheckDictEmpty:(NSDictionary *)checkDict {
    NSDictionary *dechres;
    NSArray *emptykeys;

    for (NSString *key in checkDict) {
        // NSLog(@"PRO Value:%@-->%@",key,ckdict[key]);
        id value = checkDict[key];
        NSString *waitForCheckString = nil;
        //添加对多重字典的支持
        if ([value isKindOfClass:[NSDictionary class]]) {
            [self CheckDictEmpty:value];
            continue;
        }
        if ([value isKindOfClass:[NSNumber class]]) {
            waitForCheckString = [NSString stringWithFormat:@"%@", value];
        } else if ([value isKindOfClass:NSString.class]) {
            waitForCheckString = value;
        } else if ([value isKindOfClass:NSArray.class]) {
            NSArray *arrayValue = (NSArray *)value;
            for (NSDictionary *v in arrayValue) {
                [self CheckDictEmpty:v];
            }
        }

        if ([self isBlankString:waitForCheckString]) {
            emptykeys = [NSArray arrayWithObject:key];
        }
    }

    if (emptykeys.count > 0) {
        dechres = @{@"chres" : @"Failed", @"EmptyKeys" : emptykeys};
    } else {
        dechres = @{@"chres" : @"Passed", @"EmptyKeys" : @""};
    }
    return dechres;
}

// Vst事件对比，测量协议字段完整且每个字段不为空
+ (NSDictionary *)visitEventCheck:(NSDictionary *)vstevent {
    NSDictionary *vstchres;
    NSArray *vstprome = @[
        @"userId",
        @"sessionId",
        @"eventType",
        @"timestamp",
        @"av",
        @"domain",
        @"screenHeight",
        @"screenWidth",
        @"deviceBrand",
        @"deviceModel",
        @"deviceType",
        @"operatingSystem",
        @"operatingSystemVersion",
        @"appVersion",
        @"appName",
        @"textValue",
        @"language",
        @"latitude",
        @"longitude",
        @"iv",
        @"ui",
        @"userId",
        @"globalSequenceId",
        @"eventSequenceId",
        @"fv"
    ];
    //对比测量协议结构
    if (vstevent.count > 0) {
        NSArray *chevst = vstevent.allKeys;
        vstchres = @{@"ProCheck" : [self ComNSArray:vstprome:chevst], @"KeysCheck" : [self CheckDictEmpty:vstevent]};
    }
    return vstchres;
}

// click事件对比，测量协议字段完整且每个字段不为空
+ (NSDictionary *)clickEventCheck:(NSDictionary *)clickevent {
    NSDictionary *clickchres;
    NSArray *clickprome = @[
        @"userId", @"sessionId", @"eventType", @"timestamp", @"domain", @"pageName", @"textValue", @"xpath", @"index",
        @"userId", @"globalSequenceId", @"eventSequenceId"
    ];
    //对比测量协议结构
    if (clickevent.count > 0) {
        NSArray *chevst = clickevent.allKeys;
        clickchres =
            @{@"ProCheck" : [self ComNSArray:clickprome:chevst], @"KeysCheck" : [self CheckDictEmpty:clickevent]};
    }
    return clickchres;
}
// VIEW_CHANGE事件对比，测量协议字段完整且每个字段不为空
+ (NSDictionary *)viewChangeEventCheck:(NSDictionary *)chngevent {
    NSDictionary *chngchres;
    NSArray *chngprome = @[
        @"userId", @"sessionId", @"eventType", @"timestamp", @"domain", @"pageName", @"eventName", @"xpath",
        @"textValue", @"timestamp", @"userId", @"globalSequenceId", @"eventSequenceId"
    ];
    //对比测量协议结构
    if (chngevent.count > 0) {
        NSArray *chngvst = chngevent.allKeys;
        chngchres =
            @{@"ProCheck" : [self ComNSArray:chngprome:chngvst], @"KeysCheck" : [self CheckDictEmpty:chngevent]};
    }
    return chngchres;
}

// imp事件对比，测量协议字段完整且每个字段不为空
+ (NSDictionary *)ImpEventCheck:(NSDictionary *)impevent {
    NSDictionary *impchres;
    NSArray *impprome = @[
        @"userId", @"sessionId", @"eventType", @"timestamp", @"domain", @"pageName", @"timestamp", @"eventName",
        @"textValue", @"xpath", @"index", @"userId"
    ];
    //对比测量协议结构
    if (impevent.count > 0) {
        NSArray *impkeys = impevent.allKeys;
        impchres = @{@"ProCheck" : [self ComNSArray:impprome:impkeys], @"KeysCheck" : [self CheckDictEmpty:impevent]};
    }
    return impchres;
}
@end
