//
//  ManualTrackHelper.h
//  GIOAutoTests
//
//  Created by GrowingIO on 2018/6/6.
//  Copyright © 2018年 GrowingIO. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ManualTrackHelper : NSObject
//判断字典dicts是否包含关键字ckchar
+(Boolean *)CheckContainsKey:(NSDictionary *)dicts:(NSString *)ckchar;

//cstm事件对比，测量协议字段完整且每个字段不为空
+(NSDictionary *)CstmEventCheck:(NSDictionary *)cstmevent;

//ppl事件对比，测量协议字段完整且每个字段不为空
+(NSDictionary *)PplEventCheck:(NSDictionary *)pplevent;

//pvar事件对比，测量协议字段完整且每个字段不为空
+(NSDictionary *)PvarEventCheck:(NSDictionary *)pvarevent;

//evar事件对比，测量协议字段完整且每个字段不为空
+(NSDictionary *)EvarEventCheck:(NSDictionary *)evarevent;

//vstr事件对比，测量协议字段完整且每个字段不为空
+(NSDictionary *)VstrEventCheck:(NSDictionary *)vstrevent;
@end
