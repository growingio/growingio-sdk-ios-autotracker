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
    //NSLog(@"****check Value:%@****",aStr);
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
+(NSDictionary *)ComNSArray:(NSArray *)arr1:(NSArray *)arr2
{
    NSDictionary *cmpres;
    NSArray *reduce = [arr1 filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT (SELF in %@)", arr2]];
    NSArray *incre = [arr2 filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT (SELF in %@)", arr1]];
    if (reduce.count==0 && incre.count==0)
    {
        cmpres=@{@"chres":@"same",@"reduce":@"",@"incre":@""};
    }
    else
    {
        cmpres=@{@"chres":@"different",@"reduce":reduce,@"incre":incre};
    }
    return cmpres;
    
}
//判断NSDictionary是否存在空关键字
+ (NSDictionary *)CheckDictEmpty:(NSDictionary *)checkDict {
    NSDictionary * dechres;
    NSArray * emptykeys;
    
    for (NSString *key in checkDict) {
        //NSLog(@"PRO Value:%@-->%@",key,ckdict[key]);
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
    
    if (emptykeys.count>0) {
        dechres=@{@"chres":@"Failed",@"EmptyKeys":emptykeys};
    } else {
        dechres=@{@"chres":@"Passed",@"EmptyKeys":@""};
    }
    return dechres;
}

//Vst事件对比，测量协议字段完整且每个字段不为空
+(NSDictionary *)VstEventCheck:(NSDictionary *)vstevent
{
    NSDictionary *vstchres;
    //测试中发现测量协议字段过多，产品删除了b, p, ch,dt
    //NSArray * vstprome=@[@"userId",@"sessionId",@"eventType",@"timestamp",@"av",@"b",@"domain",@"pageName",@"r",@"ch",@"screenHeight",@"screenWidth",@"deviceBrand",@"deviceModel",@"deviceType",@"operatingSystem",@"operatingSystemVersion",@"ca",@"appVersion",@"appName",@"textValue",@"language",@"latitude",@"longitude",@"globalSequenceId",@"eventSequenceId",@"tz",@"utm",@"cb",@"iv",@"dt",@"ui",@"userId"];
//    NSArray * vstprome=@[@"userId",@"sessionId",@"eventType",@"timestamp",@"av",@"domain",@"r",@"screenHeight",@"screenWidth",@"deviceBrand",@"deviceModel",@"deviceType",@"operatingSystem",@"operatingSystemVersion",@"ca",@"appVersion",@"appName",@"textValue",@"language",@"latitude",@"longitude",@"globalSequenceId",@"eventSequenceId",@"tz",@"utm",@"cb",@"iv",@"ui",@"userId"];
    
    //SDK重构2.5.0,调整测量协议 2-18-08-09
    NSArray *vstprome=@[@"userId",@"sessionId",@"eventType",@"timestamp",@"av",@"domain",@"screenHeight",@"screenWidth",@"deviceBrand",@"deviceModel",@"deviceType",@"operatingSystem",@"operatingSystemVersion",@"appVersion",@"appName",@"textValue",@"language",@"latitude",@"longitude",@"iv",@"ui",@"userId",@"globalSequenceId",@"eventSequenceId",@"fv"];
    //对比测量协议结构
    if (vstevent.count>0)
    {
        NSArray * chevst=vstevent.allKeys;
        vstchres=@{@"ProCheck":[self ComNSArray:vstprome :chevst],@"KeysCheck":[self CheckDictEmpty:vstevent]};
    }
    return vstchres;
}

//clck事件对比，测量协议字段完整且每个字段不为空
+(NSDictionary *)ClckEventCheck:(NSDictionary *)clckevent
{
    NSDictionary *clckchres;
   // NSArray * clckprome=@[@"userId",@"sessionId",@"eventType",@"timestamp",@"ppt",@"pctm",@"pageShowTimestamp",@"domain",@"pageName",@"r",@"timestamp",@"textValue",@"globalSequenceId",@"eventSequenceId",@"xpath",@"index",@"userId"];
    //SDK重构2.5.0,调整测量协议 2-18-08-09
    NSArray * clckprome=@[@"userId",@"sessionId",@"eventType",@"timestamp",@"domain",@"pageName",@"textValue",@"xpath",@"index",@"userId",@"globalSequenceId",@"eventSequenceId"];
    //对比测量协议结构
    if (clckevent.count>0)
    {
        NSArray * chevst=clckevent.allKeys;
        clckchres=@{@"ProCheck":[self ComNSArray:clckprome :chevst],@"KeysCheck":[self CheckDictEmpty:clckevent]};
    }
    return clckchres;
}
//VIEW_CHANGE事件对比，测量协议字段完整且每个字段不为空
+(NSDictionary *)ChngEventCheck:(NSDictionary *)chngevent
{
    NSDictionary *chngchres;
    //NSArray * chngprome=@[@"userId",@"sessionId",@"eventType",@"timestamp",@"ppt",@"pctm",@"pageShowTimestamp",@"domain",@"pageName",@"globalSequenceId",@"eventSequenceId",@"eventName",@"xpath",@"textValue",@"timestamp",@"userId"];
     //SDK重构2.5.0,调整测量协议 2-18-08-09
    NSArray * chngprome=@[@"userId",@"sessionId",@"eventType",@"timestamp",@"domain",@"pageName",@"eventName",@"xpath",@"textValue",@"timestamp",@"userId",@"globalSequenceId",@"eventSequenceId"];
    //对比测量协议结构
    if (chngevent.count>0)
    {
        NSArray * chngvst=chngevent.allKeys;
        chngchres=@{@"ProCheck":[self ComNSArray:chngprome :chngvst],@"KeysCheck":[self CheckDictEmpty:chngevent]};
    }
    return chngchres;
}

//imp事件对比，测量协议字段完整且每个字段不为空
+(NSDictionary *)ImpEventCheck:(NSDictionary *)impevent
{
    NSDictionary *impchres;
    //NSArray * impprome=@[@"userId",@"sessionId",@"eventType",@"timestamp",@"domain",@"pageName",@"globalSequenceId",@"eventSequenceId",@"ppt",@"pctm",@"pageShowTimestamp",@"timestamp",@"eventName",@"textValue",@"xpath",@"index",@"userId"];
    //修改测量协议，去掉gesid,esid两项，2018-05-30
    //NSArray * impprome=@[@"userId",@"sessionId",@"eventType",@"timestamp",@"domain",@"pageName",@"ppt",@"pctm",@"pageShowTimestamp",@"timestamp",@"eventName",@"textValue",@"xpath",@"index",@"userId"];
     //SDK重构2.5.0,调整测量协议 2018-08-09
    NSArray * impprome=@[@"userId",@"sessionId",@"eventType",@"timestamp",@"domain",@"pageName",@"timestamp",@"eventName",@"textValue",@"xpath",@"index",@"userId"];
    //对比测量协议结构
    if (impevent.count>0)
    {
        NSArray * impkeys=impevent.allKeys;
        impchres=@{@"ProCheck":[self ComNSArray:impprome :impkeys],@"KeysCheck":[self CheckDictEmpty:impevent]};
    }
    return impchres;
}
@end

