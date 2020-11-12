//
// Created by xiangyang on 2020/11/10.
//

#import <Foundation/Foundation.h>

@protocol GrowingAppLifecycleDelegate <NSObject>
@optional
- (void)applicationDidFinishLaunching:(NSDictionary *)userInfo;

- (void)applicationWillTerminate;

- (void)applicationDidBecomeActive;

- (void)applicationWillResignActive;

- (void)applicationDidEnterBackground;

- (void)applicationWillEnterForeground;
@end

@interface GrowingAppLifecycle : NSObject
+ (instancetype)sharedInstance;

- (void)setupAppStateNotification;

- (void)addAppLifecycleDelegate:(id <GrowingAppLifecycleDelegate>)delegate;

- (void)removeAppLifecycleDelegate:(id <GrowingAppLifecycleDelegate>)delegate;
@end