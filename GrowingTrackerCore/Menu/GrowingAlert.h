//
//  GrowingAlert.h
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

#if __has_include(<UIKit/UIKit.h>) && !TARGET_OS_WATCH
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GrowingAlert : NSObject

+ (instancetype)createAlertWithStyle:(UIAlertControllerStyle)style title:(NSString *)title message:(NSString *)message;

- (void)addActionWithTitle:(NSString *)title
                     style:(UIAlertActionStyle)style
                   handler:(void (^__nullable)(UIAlertAction *action, NSArray<UITextField *> *textFields))handler;

- (void)addOkWithTitle:(NSString *)title
               handler:(void (^__nullable)(UIAlertAction *action, NSArray<UITextField *> *textFields))handler;

- (void)addCancelWithTitle:(NSString *)title
                   handler:(void (^__nullable)(UIAlertAction *action, NSArray<UITextField *> *textFields))handler;

- (void)addDestructiveWithTitle:(NSString *)title
                        handler:(void (^__nullable)(UIAlertAction *action, NSArray<UITextField *> *textFields))handler;

- (void)addTextFieldWithConfigurationHandler:(void (^__nullable)(UITextField *textField))configurationHandler;

- (void)showAlertAnimated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
#endif
