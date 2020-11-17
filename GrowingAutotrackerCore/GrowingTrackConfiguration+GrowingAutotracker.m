//
// Created by xiangyang on 2020/11/12.
//

#import <objc/runtime.h>
#import "GrowingTrackConfiguration+GrowingAutotracker.h"

static void *const kKeyImpressionScale = "GrowingAutotrackerKeyImpressionScale";

@implementation GrowingTrackConfiguration (GrowingAutotracker)
- (float)impressionScale {
    return [objc_getAssociatedObject(self, kKeyImpressionScale) floatValue];
}

- (void)setImpressionScale:(float)impressionScale {
    objc_setAssociatedObject(self, kKeyImpressionScale, @(impressionScale), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end