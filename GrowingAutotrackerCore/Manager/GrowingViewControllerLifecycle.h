//
// Created by xiangyang on 2020/11/23.
//

#import <Foundation/Foundation.h>

@protocol GrowingViewControllerLifecycleDelegate <NSObject>
@optional
- (void)viewControllerDidAppear:(UIViewController *)controller;

- (void)viewControllerDidDisappear:(UIViewController *)controller;
@end

@interface GrowingViewControllerLifecycle : NSObject
+ (instancetype)sharedInstance;

- (void)addViewControllerLifecycleDelegate:(id <GrowingViewControllerLifecycleDelegate>)delegate;

- (void)removeViewControllerLifecycleDelegate:(id <GrowingViewControllerLifecycleDelegate>)delegate;

- (void)dispatchViewControllerDidAppear:(UIViewController *)controller;

- (void)dispatchViewControllerDidDisappear:(UIViewController *)controller;
@end