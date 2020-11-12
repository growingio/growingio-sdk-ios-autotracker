//
// Created by xiangyang on 2020/11/10.
//

#import <Foundation/Foundation.h>


@interface GrowingSession : NSObject
@property(nonatomic, copy, readonly) NSString *sessionId;

+ (instancetype)currentSession;

+ (void)startSession;
@end