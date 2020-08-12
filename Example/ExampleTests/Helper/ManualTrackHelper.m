//
//  ManualTrackHelper.m
//  GIOAutoTests
//
//  Created by GrowingIO on 2018/6/6.
//  Copyright © 2018年 GrowingIO. All rights reserved.
//  function:打点事件测试公共方法

#import "ManualTrackHelper.h"
#import "NoburPoMeaProCheck.h"

@implementation ManualTrackHelper

//判断字典dicts是否包含关键字ckchar
+(Boolean *)CheckContainsKey:(NSDictionary *)dicts:(NSString *)ckchar{
    NSArray *allkeys=dicts.allKeys;
    for (int i=0;i<allkeys.count;i++)
    {
        if([allkeys[i] isEqualToString:ckchar])
        {
            return TRUE;
        }
    }
    return FALSE;
}

//cstm事件对比，测量协议字段完整且每个字段不为空
+(NSDictionary *)CstmEventCheck:(NSDictionary *)cstmevent
{
    NSDictionary *cstmchres;
    //NSArray * cstmprome=@[@"u",@"s",@"t",@"tm",@"ptm",@"d",@"n",@"num",@"gesid",@"esid",@"var",@"cs1"];
    //重构代码后，废弃ptm字段 2018-07-23
    //NSArray * cstmprome=@[@"u",@"s",@"t",@"tm",@"d",@"n",@"num",@"gesid",@"esid",@"var",@"cs1"];
    //SDK重构2.5.0,调整测量协议 2018-08-09
    NSArray * cstmprome=@[@"u",@"s",@"t",@"tm",@"p",@"d",@"n",@"num",@"var",@"cs1",@"gesid",@"esid"];
    //对比测量协议结构
    if (cstmevent.count>0)
    {
        NSArray * checstm=cstmevent.allKeys;
        cstmchres=@{@"ProCheck":[NoburPoMeaProCheck ComNSArray:cstmprome :checstm],@"KeysCheck":[NoburPoMeaProCheck CheckDictEmpty:cstmevent]};
    }
    return cstmchres;
}

//ppl事件对比，测量协议字段完整且每个字段不为空
+(NSDictionary *)PplEventCheck:(NSDictionary *)pplevent
{
    NSDictionary *pplchres;
    //NSArray * pplprome=@[@"u",@"s",@"t",@"tm",@"d",@"gesid",@"esid",@"var",@"cs1"];
     //SDK重构2.5.0,调整测量协议 2018-08-09
    NSArray * pplprome=@[@"u",@"s",@"t",@"tm",@"d",@"var",@"cs1",@"gesid",@"esid"];
    //对比测量协议结构
    if (pplevent.count>0)
    {
        NSArray * cheppl=pplevent.allKeys;
        pplchres=@{@"ProCheck":[NoburPoMeaProCheck ComNSArray:pplprome :cheppl],@"KeysCheck":[NoburPoMeaProCheck CheckDictEmpty:pplevent]};
    }
    return pplchres;
}

//pvar事件对比，测量协议字段完整且每个字段不为空
+(NSDictionary *)PvarEventCheck:(NSDictionary *)pvarevent
{
    NSDictionary *pvarchres;
    NSArray * pvarlprome=@[@"u",@"s",@"t",@"tm",@"d",@"p",@"var",@"cs1",@"gesid",@"esid"];
    //对比测量协议结构
    if (pvarevent.count>0)
    {
        NSArray * chepvar=pvarevent.allKeys;
        pvarchres=@{@"ProCheck":[NoburPoMeaProCheck ComNSArray:pvarlprome :chepvar],@"KeysCheck":[NoburPoMeaProCheck CheckDictEmpty:pvarevent]};
    }
    return pvarchres;
}


//evar事件对比，测量协议字段完整且每个字段不为空
+(NSDictionary *)EvarEventCheck:(NSDictionary *)evarevent
{
    NSDictionary *evarchres;
    NSArray * evarlprome=@[@"u",@"s",@"t",@"tm",@"d",@"var",@"cs1",@"esid",@"gesid"];
    //对比测量协议结构
    if (evarevent.count>0)
    {
        NSArray * cheevar=evarevent.allKeys;
        evarchres=@{@"ProCheck":[NoburPoMeaProCheck ComNSArray:evarlprome :cheevar],@"KeysCheck":[NoburPoMeaProCheck CheckDictEmpty:evarevent]};
    }
    return evarchres;
}

//vstr事件对比，测量协议字段完整且每个字段不为空
+(NSDictionary *)VstrEventCheck:(NSDictionary *)vstrevent
{
    NSDictionary *vstrchres;
    NSArray * vstrprome=@[@"u",@"s",@"t",@"tm",@"d",@"var",@"cs1"];
    //对比测量协议结构
    if (vstrevent.count>0)
    {
        NSArray * chevstr=vstrevent.allKeys;
        vstrchres=@{@"ProCheck":[NoburPoMeaProCheck ComNSArray:vstrprome :chevstr],@"KeysCheck":[NoburPoMeaProCheck CheckDictEmpty:vstrevent]};
    }
    return vstrchres;
}


@end
