//
// Created by xiangyang on 2020/11/10.
//

#import <Foundation/Foundation.h>

typedef NSString *GrowingEventType NS_STRING_ENUM;

FOUNDATION_EXPORT GrowingEventType const GrowingEventTypeVisit;
FOUNDATION_EXPORT GrowingEventType const GrowingEventTypeCustom;
FOUNDATION_EXPORT GrowingEventType const GrowingEventTypeVisitorAttributes;
FOUNDATION_EXPORT GrowingEventType const GrowingEventTypeLoginUserAttributes;
FOUNDATION_EXPORT GrowingEventType const GrowingEventTypeConversionVariables;
FOUNDATION_EXPORT GrowingEventType const GrowingEventTypeAppClosed;

@interface GrowingTrackEventType : NSObject
@end