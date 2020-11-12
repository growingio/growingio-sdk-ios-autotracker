//
// Created by xiangyang on 2020/11/11.
//

#import "GrowingUserInfoManager.h"


@implementation GrowingUserInfoManager
+ (instancetype)sharedInstance {
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });

    return _sharedInstance;
}

- (NSString *)loginUserId {
    return nil;
}

- (void)setLoginUserId:(NSString *)loginUserId {

}

@end