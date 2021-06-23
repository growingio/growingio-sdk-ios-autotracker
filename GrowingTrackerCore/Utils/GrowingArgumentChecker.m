//
// Created by xiangyang on 2020/11/13.
//

#import "GrowingArgumentChecker.h"
#import "NSString+GrowingHelper.h"
#import "GrowingLogMacros.h"
#import "GrowingLogger.h"

@implementation GrowingArgumentChecker
+ (BOOL)isIllegalEventName:(NSString *)eventName {
    if ([NSString growingHelper_isBlankString:eventName]) {
        GIOLogError(@"event name is NULL");
        return YES;
    }

    if (![eventName isKindOfClass:[NSString class]]) {
        GIOLogError(@"event name is not kind of NSString class");
        return YES;
    }

    return NO;
}

+ (BOOL)isIllegalAttributes:(NSDictionary *)attributes {
    if (attributes == nil) {
        GIOLogError(@"attributes is NULL");
        return YES;
    }

    if (![attributes isKindOfClass:NSDictionary.class]) {
        GIOLogError(@"attributes is not kind of NSDictionary class");
        return YES;
    }

    for (NSString *key in attributes) {
        if (![key isKindOfClass:NSString.class]) {
            GIOLogError(@"Key %@ is not kind of NSDictionary class", key);
            return YES;
        }

        NSString *stringValue = attributes[key];

        if (![stringValue isKindOfClass:NSString.class]) {
            GIOLogError(@"value for key %@ is not kind of NSDictionary class", key);
            return YES;
        }
    }

    return NO;
}

@end
