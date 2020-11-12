//
// Created by xiangyang on 2020/11/10.
//

#import <Foundation/Foundation.h>

@class GrowingBaseTrackConfiguration;


@interface GrowingConfigurationManager : NSObject
@property(nonatomic, strong) GrowingBaseTrackConfiguration *trackConfiguration;
@property(nonatomic, copy, readonly) NSString *urlScheme;

+ (instancetype)sharedInstance;
@end