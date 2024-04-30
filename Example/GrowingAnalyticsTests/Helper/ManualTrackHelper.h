//
//  ManualTrackHelper.h
//  GIOAutoTests
//
//  Created by GrowingIO on 2018/6/6.
//  Copyright (C) 2018 Beijing Yishu Technology Co., Ltd.
//

#import <Foundation/Foundation.h>

@interface ManualTrackHelper : NSObject

@property (class, nonatomic, copy, readonly) NSArray *context;
@property (class, nonatomic, copy, readonly) NSArray *contextOptional;

+ (BOOL)visitEventCheck:(NSDictionary *)event;

+ (BOOL)customEventCheck:(NSDictionary *)event;

+ (BOOL)loginUserAttributesEventCheck:(NSDictionary *)event;

+ (BOOL)appCloseEventCheck:(NSDictionary *)event;

+ (BOOL)pageEventCheck:(NSDictionary *)event;

+ (BOOL)viewClickEventCheck:(NSDictionary *)event;

+ (BOOL)viewChangeEventCheck:(NSDictionary *)event;

+ (BOOL)hybridFormSubmitEventCheck:(NSDictionary *)event;

+ (BOOL)contextOptionalPropertyCheck:(NSDictionary *)event;

@end
