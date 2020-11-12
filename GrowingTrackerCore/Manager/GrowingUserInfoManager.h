//
// Created by xiangyang on 2020/11/11.
//

#import <Foundation/Foundation.h>


@interface GrowingUserInfoManager : NSObject
@property(nonatomic, copy, readwrite) NSString *loginUserId;

+ (instancetype)sharedInstance;
@end