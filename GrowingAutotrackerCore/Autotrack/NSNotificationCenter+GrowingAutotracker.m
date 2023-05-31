//
//  NSNotificationCenter+GrowingAutoTrack.m
//  GrowingAnalytics
//
//  Created by GrowingIO on 2020/7/23.
//  Copyright (C) 2020 Beijing Yishu Technology Co., Ltd.
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

#import <UIKit/UIKit.h>
#import "GrowingAutotrackerCore/Autotrack/GrowingPropertyDefine.h"
#import "GrowingAutotrackerCore/Autotrack/NSNotificationCenter+GrowingAutotracker.h"
#import "GrowingAutotrackerCore/GrowingNode/Category/UIView+GrowingNode.h"
#import "GrowingAutotrackerCore/GrowingNode/GrowingViewChangeProvider.h"

GrowingPropertyDefine(UITextField, NSString *, growingHookOldText, setGrowingHookOldText)
    GrowingPropertyDefine(UITextView, NSString *, growingHookOldText, setGrowingHookOldText)

        @implementation NSNotificationCenter(GrowingAutotracker)

- (void)growing_postNotificationName:(NSNotificationName)aName object:(id)anObject userInfo:(NSDictionary *)aUserInfo {
    if ([aName isEqualToString:UITextFieldTextDidEndEditingNotification]) {
        [self growing_handleInputViewDidEndingEditing:anObject];
    }

    [self growing_postNotificationName:aName object:anObject userInfo:aUserInfo];
}

- (void)growing_handleInputViewDidEndingEditing:(id)anObject {
    if ([anObject isKindOfClass:UITextField.class]) {
        UITextField *inputView = (UITextField *)anObject;

        if (inputView.isSecureTextEntry) {
            return;
        }

        NSString *text = inputView.text;
        if (text && ![inputView.growingHookOldText isEqualToString:text]) {
            inputView.growingHookOldText = text;
            [GrowingViewChangeProvider viewOnChange:inputView];
        }

    } else if ([anObject isKindOfClass:UITextView.class]) {
        UITextView *inputView = (UITextView *)anObject;

        if (inputView.isSecureTextEntry) {
            return;
        }

        NSString *text = inputView.text;
        if (![inputView.growingHookOldText isEqualToString:text]) {
            inputView.growingHookOldText = text;
            [GrowingViewChangeProvider viewOnChange:inputView];
        }
    }
}

@end
