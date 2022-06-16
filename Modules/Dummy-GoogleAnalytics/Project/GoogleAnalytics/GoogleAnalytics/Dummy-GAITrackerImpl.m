//
//  Dummy-GAITrackerImpl.m
//  GoogleAnalytics
//
//  Created by YoloMao on 2022/6/1.
//

#import "Dummy-GAITrackerImpl.h"

@interface Dummy_GAITrackerImpl ()

@property (nonatomic, copy) NSString *trackingId;
@property (nonatomic, copy) NSString *clientId;

@end

@implementation Dummy_GAITrackerImpl

- (instancetype)initWithName:(NSString *)name
                  trackingId:(NSString *)trackingId {
    if (self = [super init]) {
        _name = name.copy;
        _trackingId = trackingId.copy;
        _allowIDFACollection = NO;
        _allowAdPersonalizationSignals = YES;
    }
    return self;
}

- (void)set:(NSString *)parameterName
      value:(NSString *)value {
    
}

- (void)send:(NSDictionary *)parameters {
    
}

- (NSString *)get:(NSString *)parameterName {
    if ([parameterName isEqualToString:@"&tid"]) {
        return self.trackingId;
    } else if ([parameterName isEqualToString:@"&cid"]) {
        return self.clientId;
    }
    
    // unsupport the other parameterName
    return @"";
}

@end
