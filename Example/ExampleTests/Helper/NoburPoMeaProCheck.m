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
    //NSArray * vstprome=@[@"u",@"s",@"t",@"tm",@"av",@"b",@"d",@"p",@"r",@"ch",@"sh",@"sw",@"db",@"dm",@"ph",@"os",@"osv",@"ca",@"cv",@"sn",@"v",@"l",@"lat",@"lng",@"gesid",@"esid",@"tz",@"utm",@"cb",@"iv",@"dt",@"ui",@"cs1"];
//    NSArray * vstprome=@[@"u",@"s",@"t",@"tm",@"av",@"d",@"r",@"sh",@"sw",@"db",@"dm",@"ph",@"os",@"osv",@"ca",@"cv",@"sn",@"v",@"l",@"lat",@"lng",@"gesid",@"esid",@"tz",@"utm",@"cb",@"iv",@"ui",@"cs1"];
    
    //SDK重构2.5.0,调整测量协议 2-18-08-09
    NSArray *vstprome=@[@"u",@"s",@"t",@"tm",@"av",@"d",@"sh",@"sw",@"db",@"dm",@"ph",@"os",@"osv",@"cv",@"sn",@"v",@"l",@"lat",@"lng",@"iv",@"ui",@"cs1",@"gesid",@"esid",@"fv"];
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
   // NSArray * clckprome=@[@"u",@"s",@"t",@"tm",@"ppt",@"pctm",@"ptm",@"d",@"p",@"r",@"tm",@"v",@"gesid",@"esid",@"x",@"idx",@"cs1"];
    //SDK重构2.5.0,调整测量协议 2-18-08-09
    NSArray * clckprome=@[@"u",@"s",@"t",@"tm",@"d",@"p",@"v",@"x",@"idx",@"cs1",@"gesid",@"esid"];
    //对比测量协议结构
    if (clckevent.count>0)
    {
        NSArray * chevst=clckevent.allKeys;
        clckchres=@{@"ProCheck":[self ComNSArray:clckprome :chevst],@"KeysCheck":[self CheckDictEmpty:clckevent]};
    }
    return clckchres;
}
//chng事件对比，测量协议字段完整且每个字段不为空
+(NSDictionary *)ChngEventCheck:(NSDictionary *)chngevent
{
    NSDictionary *chngchres;
    //NSArray * chngprome=@[@"u",@"s",@"t",@"tm",@"ppt",@"pctm",@"ptm",@"d",@"p",@"gesid",@"esid",@"n",@"x",@"v",@"tm",@"cs1"];
     //SDK重构2.5.0,调整测量协议 2-18-08-09
    NSArray * chngprome=@[@"u",@"s",@"t",@"tm",@"d",@"p",@"n",@"x",@"v",@"tm",@"cs1",@"gesid",@"esid"];
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
    //NSArray * impprome=@[@"u",@"s",@"t",@"tm",@"d",@"p",@"gesid",@"esid",@"ppt",@"pctm",@"ptm",@"tm",@"n",@"v",@"x",@"idx",@"cs1"];
    //修改测量协议，去掉gesid,esid两项，2018-05-30
    //NSArray * impprome=@[@"u",@"s",@"t",@"tm",@"d",@"p",@"ppt",@"pctm",@"ptm",@"tm",@"n",@"v",@"x",@"idx",@"cs1"];
     //SDK重构2.5.0,调整测量协议 2018-08-09
    NSArray * impprome=@[@"u",@"s",@"t",@"tm",@"d",@"p",@"tm",@"n",@"v",@"x",@"idx",@"cs1"];
    //对比测量协议结构
    if (impevent.count>0)
    {
        NSArray * impkeys=impevent.allKeys;
        impchres=@{@"ProCheck":[self ComNSArray:impprome :impkeys],@"KeysCheck":[self CheckDictEmpty:impevent]};
    }
    return impchres;
}
@end

