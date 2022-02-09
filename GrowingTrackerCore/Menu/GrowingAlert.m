//
//  GrowingAlert.m
//  GrowingAnalytics
//
//  Created by BeyondChao on 2020/8/10.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import "GrowingAlert.h"
#import "GrowingLogger.h"
typedef NS_ENUM(NSUInteger, GrowingAlertError) {
    alertControllerNil = 0,
    popoverNotSet = 1,
    sourceViewControllerNil = 2,
};

typedef NS_ENUM(NSUInteger, GrowingAlertResult) {
    success = 0,
    failure = 1,
};

@interface UIViewController (GrowingAlertHelper)

- (UIViewController *)growing_topMostViewController;

@end

@implementation UIViewController (GrowingAlertHelper)

- (UIViewController *)growing_topMostViewController {
    
    UIViewController *presented = self.presentedViewController;
    if (presented) {
        return [presented growing_topMostViewController];
    }
    
    if ([self isKindOfClass:UINavigationController.class]) {
        UINavigationController *navigation = (UINavigationController *)self;
        return [navigation.visibleViewController growing_topMostViewController];
    }
    
    if ([self isKindOfClass:UITabBarController.class]) {
        UITabBarController *tab = (UITabBarController *)self;
        return [tab.selectedViewController growing_topMostViewController];
    }
    
    return self;
}

@end

@interface UIApplication (GrowingAlertHelper)

- (UIViewController *)growing_topMostViewController;

@end

@implementation UIApplication (GrowingAlertHelper)

- (UIViewController *)growing_topMostViewController {
    
    UIWindow *keyWindow = nil;
    for (UIWindow *w in self.windows) {
        if (w.isKeyWindow) {
            keyWindow = w;
            break;
        }
    }
    
    if (!keyWindow) { return nil; }
    
    return [keyWindow.rootViewController growing_topMostViewController];
}

@end


@interface GrowingAlert ()

@property (nonatomic, strong) UIAlertController *alertController;

@end

@implementation GrowingAlert

- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
               preferredStyle:(UIAlertControllerStyle)preferredStyle {
    
    if (self = [super init]) {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:title
                                                                         message:message
                                                                  preferredStyle:preferredStyle];
        
        self.alertController = alertVC;
    }
    return self;
}

#pragma mark - Public

+ (instancetype)createAlertWithStyle:(UIAlertControllerStyle)style
                               title:(NSString *)title
                             message:(NSString *)message {
    return [[GrowingAlert alloc] initWithTitle:title message:message preferredStyle:style];
}

- (void)addTextFieldWithConfigurationHandler:(void (^ __nullable)(UITextField *textField))configurationHandler {
    if (self.alertController.preferredStyle != UIAlertControllerStyleAlert) {
        return;
    }
    
    [self.alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        if (configurationHandler) {
            configurationHandler(textField);
        }
    }];
}

- (void)addActionWithTitle:(NSString *)title
                     style:(UIAlertActionStyle)style
                   handler:(void (^ __nullable)(UIAlertAction *action, NSArray <UITextField *> *textFields))handler {
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:title
                                                     style:style
                                                   handler:^(UIAlertAction * _Nonnull action) {
        
        if (handler) {
            handler(action, self.alertController.preferredStyle == UIAlertControllerStyleAlert ? self.alertController.textFields : nil);
            self.alertController = nil;
        }
    }];
    
    [self.alertController addAction:action];
}

- (void)addOkWithTitle:(NSString *)title
               handler:(void (^ __nullable)(UIAlertAction *action, NSArray <UITextField *> *textFields))handler {
    [self addActionWithTitle:title
                       style:UIAlertActionStyleDefault
                     handler:handler];
}


- (void)addCancelWithTitle:(NSString *)title
                   handler:(void (^ __nullable)(UIAlertAction *action, NSArray <UITextField *> *textFields))handler {
    [self addActionWithTitle:title
                       style:UIAlertActionStyleCancel
                     handler:handler];
}


- (void)addDestructiveWithTitle:(NSString *)title
                        handler:(void (^ __nullable)(UIAlertAction *action, NSArray <UITextField *> *textFields))handler {
    [self addActionWithTitle:title
                       style:UIAlertActionStyleDestructive
                     handler:handler];
}


- (void)showAlertAnimated:(BOOL)animated {
    UIViewController *sourceViewController = [[UIApplication sharedApplication] growing_topMostViewController];
    if (sourceViewController) {
        [sourceViewController presentViewController:self.alertController
          animated:YES
        completion:nil];
    }else {
        GIOLogError(@"Alert show Error : Window Top ViewController is not find");
    }
    
}

@end


