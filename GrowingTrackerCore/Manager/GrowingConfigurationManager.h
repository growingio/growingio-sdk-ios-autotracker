//
// Created by xiangyang on 2020/11/10.
//

#import <Foundation/Foundation.h>

@class GrowingTrackConfiguration;


@interface GrowingConfigurationManager : NSObject
@property(nonatomic, strong) GrowingTrackConfiguration *trackConfiguration;
@property(nonatomic, copy, readonly) NSString *urlScheme;

+ (instancetype)sharedInstance;
@end