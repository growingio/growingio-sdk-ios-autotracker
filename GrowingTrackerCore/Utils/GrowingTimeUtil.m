//
// Created by xiangyang on 2020/11/11.
//

#import "GrowingTimeUtil.h"


@implementation GrowingTimeUtil
+ (long long)currentTimeMillis {
    NSDate *dateNow = [NSDate date];
    return (long long) ([dateNow timeIntervalSince1970] * 1000LL);
}
@end
