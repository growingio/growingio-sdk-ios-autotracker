//
//  GIODataProcessOperation.m
//  GrowingExample
//
//  Created by GrowingIO on 2018/6/4.
//  Copyright (C) 2018 Beijing Yishu Technology Co., Ltd.
//

#import "GIODataProcessOperation.h"

@implementation GIODataProcessOperation

+ (NSString *)randomStringWithLength:(int)length {
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [[NSMutableString alloc] initWithCapacity:length];
    for(NSInteger i = 0; i < length; i++) {
        uint32_t ln = (uint32_t)letters.length;
        uint32_t rand = arc4random_uniform(ln);
        [randomString appendFormat:@"%C", [letters characterAtIndex:rand]];
    }
    return randomString;
}

+ (int)getRandomLengthFrom:(int)from to:(int)to {
    return (int)(from + (arc4random() % (to - from + 1)));
}

@end
