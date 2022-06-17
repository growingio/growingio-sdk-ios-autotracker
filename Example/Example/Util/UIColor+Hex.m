//
//  UIColor+Hex.m
//  GrowingIOTest
//
//  Created by YoloMao on 2021/7/22.
//  Copyright © 2021 GrowingIO. All rights reserved.
//

#import "UIColor+Hex.h"

@implementation UIColor (Hex)

+ (UIColor *)colorForHex:(NSString *)hexColor {
    if (hexColor.length >= 6) {
        NSRange range;
        range.location = 0;
        range.length = 2;
        NSString *rString = [hexColor substringWithRange:range];
        range.location = 2;
        NSString *gString = [hexColor substringWithRange:range];
        range.location = 4;
        NSString *bString = [hexColor substringWithRange:range];
        
        unsigned int r, g, b;
        [[NSScanner scannerWithString:rString] scanHexInt:&r];
        [[NSScanner scannerWithString:gString] scanHexInt:&g];
        [[NSScanner scannerWithString:bString] scanHexInt:&b];
        
        return [UIColor colorWithRed:((float) r / 255.0f)
                               green:((float) g / 255.0f)
                                blue:((float) b / 255.0f)
                               alpha:1.0f];
    } else {
        return [UIColor blackColor];
    }
}

+ (UIColor *)colorForHex:(NSString *)hexColor alpha:(CGFloat)alpha {
    if (hexColor.length >= 6) {
        NSRange range;
        range.location = 0;
        range.length = 2;
        NSString *rString = [hexColor substringWithRange:range];
        range.location = 2;
        NSString *gString = [hexColor substringWithRange:range];
        range.location = 4;
        NSString *bString = [hexColor substringWithRange:range];
        
        unsigned int r, g, b;
        [[NSScanner scannerWithString:rString] scanHexInt:&r];
        [[NSScanner scannerWithString:gString] scanHexInt:&g];
        [[NSScanner scannerWithString:bString] scanHexInt:&b];
        
        return [UIColor colorWithRed:((float) r / 255.0f)
                               green:((float) g / 255.0f)
                                blue:((float) b / 255.0f)
                               alpha:alpha];
    } else {
        return [UIColor blackColor];
    }
}

@end
