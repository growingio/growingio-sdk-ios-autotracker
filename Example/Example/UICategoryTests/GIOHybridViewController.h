//
//  GIOHybridViewController.h
//  GrowingExample
//
//  Created by GrowingIO on 16/03/2018.
//  Copyright © 2018 GrowingIO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>


@interface GIOHybridViewController : UIViewController

@end


@interface HybirdEventSender : NSObject

@property (nonatomic, strong) WKWebView *webView;
+ (instancetype)sharedInstance;
- (void)testHybirdEventSender:(NSString *)jsStr;
//
//- (void)TestSendCustomEvent;
//- (void)TestSendCustomEventWithAttributes;
//- (void)TestSendVisitorAttributesEvent;
//- (void)TestSendLoginUserAttributesEvent;
//- (void)TestSendConversionVariablesEvent;
//- (void)TestSendPageEvent;
//- (void)TestSendPageEventWithQuery;
//- (void)TestSendFilePageEvent;
//- (void)TestSendPageAttributesEvent;
//- (void)TestSendViewClickEvent;
//- (void)TestSendViewChangeEvent;
//- (void)TestSendFormSubmitEvent;
//- (void)TestsetUserId;
//- (void)TestclearUserId;
//- (void)TestmockDomChanged;
//
@end
