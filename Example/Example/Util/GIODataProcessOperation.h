//
//  GIODataProcessOperation.h
//  GrowingExample
//
//  Created by GrowingIO on 2018/6/4.
//  Copyright (C) 2018 Beijing Yishu Technology Co., Ltd.
//

#import <Foundation/Foundation.h>

@interface GIODataProcessOperation : NSObject

+ (NSString *)randomStringWithLength:(int)length;
+ (int)getRandomLengthFrom:(int)from to:(int)to;

@end
