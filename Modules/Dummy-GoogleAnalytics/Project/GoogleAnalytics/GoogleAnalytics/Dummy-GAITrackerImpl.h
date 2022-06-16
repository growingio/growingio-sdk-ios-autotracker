//
//  Dummy-GAITrackerImpl.h
//  GoogleAnalytics
//
//  Created by YoloMao on 2022/6/1.
//

#import <Foundation/Foundation.h>
#import "GAITracker.h"

NS_ASSUME_NONNULL_BEGIN

@interface Dummy_GAITrackerImpl : NSObject <GAITracker>

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, assign) BOOL allowIDFACollection;
@property (nonatomic, assign) BOOL allowAdPersonalizationSignals;

- (instancetype)initWithName:(NSString *)name
                  trackingId:(NSString *)trackingId;

@end

NS_ASSUME_NONNULL_END
