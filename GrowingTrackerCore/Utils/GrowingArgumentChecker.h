//
// Created by xiangyang on 2020/11/13.
//

#import <Foundation/Foundation.h>


@interface GrowingArgumentChecker : NSObject
+ (BOOL)isIllegalEventName:(NSString *)eventName;

+ (BOOL)isIllegalAttributes:(NSDictionary *)attributes;
@end