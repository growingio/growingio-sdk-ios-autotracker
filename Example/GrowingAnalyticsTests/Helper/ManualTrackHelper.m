//
//  ManualTrackHelper.m
//  GIOAutoTests
//
//  Created by GrowingIO on 2018/6/6.
//  Copyright (C) 2018 Beijing Yishu Technology Co., Ltd.
//  function:打点事件测试公共方法

#import "ManualTrackHelper.h"

@implementation ManualTrackHelper

#pragma mark - Public Methods

+ (BOOL)visitEventCheck:(NSDictionary *)event {
    if (event.count == 0) {
        return NO;
    }
    NSArray *protocol = self.context;
    NSArray *optional = @[@"idfa", @"idfv", @"extraSdk"];
    return [self protocolCheck:event protocol:protocol] && [self emptyPropertyCheck:event optional:optional];
}

+ (BOOL)customEventCheck:(NSDictionary *)event {
    if (event.count == 0) {
        return NO;
    }
    NSArray *protocol = [self.context arrayByAddingObjectsFromArray:@[@"eventName"]];
    NSArray *optional = @[@"path", @"pageShowTimestamp", @"attributes", @"query"];
    return [self protocolCheck:event protocol:protocol] && [self emptyPropertyCheck:event optional:optional];
}

+ (BOOL)loginUserAttributesEventCheck:(NSDictionary *)event {
    if (event.count == 0) {
        return NO;
    }
    NSArray *protocol = [self.context arrayByAddingObjectsFromArray:@[@"attributes"]];
    return [self protocolCheck:event protocol:protocol] && [self emptyPropertyCheck:event];
}

+ (BOOL)conversionVariablesEventCheck:(NSDictionary *)event {
    if (event.count == 0) {
        return NO;
    }
    NSArray *protocol = [self.context arrayByAddingObjectsFromArray:@[@"attributes"]];
    return [self protocolCheck:event protocol:protocol] && [self emptyPropertyCheck:event];
}

+ (BOOL)visitorAttributesEventCheck:(NSDictionary *)event {
    if (event.count == 0) {
        return NO;
    }
    NSArray *protocol = [self.context arrayByAddingObjectsFromArray:@[@"attributes"]];
    return [self protocolCheck:event protocol:protocol] && [self emptyPropertyCheck:event];
}

+ (BOOL)appCloseEventCheck:(NSDictionary *)event {
    if (event.count == 0) {
        return NO;
    }
    NSArray *protocol = self.context;
    return [self protocolCheck:event protocol:protocol] && [self emptyPropertyCheck:event];
}

+ (BOOL)pageEventCheck:(NSDictionary *)event {
    if (event.count == 0) {
        return NO;
    }
    NSArray *protocol = [self.context arrayByAddingObjectsFromArray:@[@"path", @"orientation"]];
    NSArray *optional = @[@"title", @"referralPage", @"query", @"protocolType", @"attributes"];
    return [self protocolCheck:event protocol:protocol] && [self emptyPropertyCheck:event optional:optional];
}

+ (BOOL)viewClickEventCheck:(NSDictionary *)event {
    if (event.count == 0) {
        return NO;
    }
    NSArray *protocol = [self.context arrayByAddingObjectsFromArray:@[@"path", @"pageShowTimestamp", @"xpath"]];
    NSArray *optional = @[@"textValue", @"index", @"hyperlink", @"query"];
    return [self protocolCheck:event protocol:protocol] && [self emptyPropertyCheck:event optional:optional];
}

+ (BOOL)viewChangeEventCheck:(NSDictionary *)event {
    if (event.count == 0) {
        return NO;
    }
    NSArray *protocol = [self.context arrayByAddingObjectsFromArray:@[@"path", @"pageShowTimestamp", @"xpath"]];
    NSArray *optional = @[@"textValue", @"index", @"hyperlink", @"query"];
    return [self protocolCheck:event protocol:protocol] && [self emptyPropertyCheck:event optional:optional];
}

+ (BOOL)hybridFormSubmitEventCheck:(NSDictionary *)event {
    if (event.count == 0) {
        return NO;
    }
    NSArray *protocol = [self.context arrayByAddingObjectsFromArray:@[@"path", @"pageShowTimestamp", @"xpath"]];
    NSArray *optional = @[@"index", @"query"];
    return [self protocolCheck:event protocol:protocol] && [self emptyPropertyCheck:event optional:optional];
}

/// 验证测量协议中通用非必需字段不为空（需在生成事件前赋值对应字段，如userId、userKey等）
/// @param event 事件
+ (BOOL)contextOptionalPropertyCheck:(NSDictionary *)event {
    if (event.count == 0) {
        return NO;
    }
    for (NSString *optionalKey in ManualTrackHelper.contextOptional) {
        BOOL find = NO;
        for (NSString *key in event.allKeys) {
            if ([optionalKey isEqualToString:key]) {
                find = YES;
                break;
            }
        }
        if (!find) {
            return NO;
        }
    }
    
    return YES;
}

#pragma mark - Private Methods

/// 与测量协议对比，验证事件数据完整性
/// @param event 事件
/// @param protocol 测量协议字段数组
+ (BOOL)protocolCheck:(NSDictionary *)event protocol:(NSArray *)protocol {
    NSDictionary *dic = [ManualTrackHelper compareArray:protocol toAnother:event.allKeys];
    if ([dic[@"chres"] isEqualToString:@"same"]) {
        return YES;
    } else if ([dic[@"chres"] isEqualToString:@"different"] && ((NSArray *)dic[@"reduce"]).count == 0) {
        return YES;
    } else {
        return NO;
    }
}

/// 验证事件所有属性是否有值
/// @param event 事件
+ (BOOL)emptyPropertyCheck:(NSDictionary *)event {
    return [self emptyPropertyCheck:event optional:nil];
}

/// 验证事件所有属性是否有值，其中非必需字段可为空
/// @param event 事件
/// @param optional 基于事件类型的非必需字段数组
+ (BOOL)emptyPropertyCheck:(NSDictionary *)event optional:(NSArray *)optional {
    NSDictionary *dic = [ManualTrackHelper checkDictEmpty:event];
    if ([dic[@"chres"] isEqualToString:@"Passed"]) {
        return YES;
    } else if ([dic[@"chres"] isEqualToString:@"Failed"]) {
        NSArray *emptyKeys = dic[@"EmptyKeys"];
        BOOL allEmptyKeysAreOptional = YES;
        for (NSString *key in emptyKeys) {
            BOOL thisEmptyKeyIsOptional = NO;
            for (NSString *optionalKey in self.contextOptional) {
                if ([optionalKey isEqualToString:key]) {
                    thisEmptyKeyIsOptional = YES;
                    break;
                }
            }
            if (!thisEmptyKeyIsOptional && optional.count > 0) {
                for (NSString *optionalKey in optional) {
                    if ([optionalKey isEqualToString:key]) {
                        thisEmptyKeyIsOptional = YES;
                        break;
                    }
                }
            }
            
            if (!thisEmptyKeyIsOptional) {
                allEmptyKeysAreOptional = NO;
                break;
            }
        }
        return allEmptyKeysAreOptional;
    } else {
        return NO;
    }
}

// 字符串是否为空
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

// 对比两个NSArray
+ (NSDictionary *)compareArray:(NSArray *)arr1 toAnother:(NSArray *)arr2 {
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

// 判断NSDictionary是否存在空关键字
+ (NSDictionary *)checkDictEmpty:(NSDictionary *)checkDict {
    NSDictionary *dechres;
    NSArray *emptykeys;

    for (NSString *key in checkDict) {
        id value = checkDict[key];
        NSString *waitForCheckString = nil;
        //添加对多重字典的支持
        if ([value isKindOfClass:[NSDictionary class]]) {
            [self checkDictEmpty:value];
            continue;
        }
        if ([value isKindOfClass:[NSNumber class]]) {
            waitForCheckString = [NSString stringWithFormat:@"%@", value];
        } else if ([value isKindOfClass:NSString.class]) {
            waitForCheckString = value;
        } else if ([value isKindOfClass:NSArray.class]) {
            NSArray *arrayValue = (NSArray *)value;
            for (NSDictionary *v in arrayValue) {
                [self checkDictEmpty:v];
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

#pragma mark - Setter & Getter

+ (NSArray *)context {
    NSArray *context = @[@"platform",
                         @"platformVersion",
                         @"deviceId",
                         @"sessionId",
                         @"eventType",
                         @"timestamp",
                         @"domain",
                         @"urlScheme",
                         @"appState",
                         @"globalSequenceId",
                         @"eventSequenceId",
                         @"networkState",
                         @"screenHeight",
                         @"screenWidth",
                         @"deviceBrand",
                         @"deviceModel",
                         @"deviceType",
                         @"appVersion",
                         @"appName",
                         @"language",
                         @"sdkVersion"];
    return context;
}

+ (NSArray *)contextOptional {
    NSArray *contextOptional = @[@"userId",
                                 @"latitude",
                                 @"longitude",
                                 @"userKey"];
    return contextOptional;
}

@end
