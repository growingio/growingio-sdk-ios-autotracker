//
//  GrowingTestHelper.h
//  GrowingSDKTest
//
//  Created by apple on 2017/9/28.
//  Copyright © 2017年 GrowingIO. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GrowingTestHelper : NSObject

+ (void)deactivateAppForDuration:(NSTimeInterval)duration;

+ (void)reactivateApp;

@end
