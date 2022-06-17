//
//  Dummy-GAILoggerImpl.h
//  GoogleAnalytics
//
//  Created by YoloMao on 2022/6/17.
//

#import <Foundation/Foundation.h>
#import "GAILogger.h"

NS_ASSUME_NONNULL_BEGIN

@interface Dummy_GAILoggerImpl : NSObject <GAILogger>

@property (nonatomic, assign) GAILogLevel logLevel;

- (void)verbose:(NSString *)message;

- (void)info:(NSString *)message;

- (void)warning:(NSString *)message;

- (void)error:(NSString *)message;

@end

NS_ASSUME_NONNULL_END
