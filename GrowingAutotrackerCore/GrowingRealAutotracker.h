//
// Created by xiangyang on 2020/11/12.
//

#import <Foundation/Foundation.h>
#import "GrowingRealTracker.h"

typedef NS_ENUM(NSUInteger, GrowingIgnorePolicy) {
    GrowingIgnoreNone = 0,
    GrowingIgnoreSelf = 1,     // 忽略自身
    GrowingIgnoreChildren = 2, // 忽略所有子页面和孙子页面
    GrowingIgnoreAll = 3,      // 忽略自身 + 忽略所有子页面和孙子页面
};

@interface GrowingRealAutotracker : GrowingRealTracker
@end