//
//  GIOScanViewController.h
//  GrowingIOTest
//
//  Created by YoloMao on 2021/7/22.
//  Copyright © 2021 GrowingIO. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^GIOScanResultBlock)(NSString *string);

@interface GIOScanViewController : UIViewController

@property (nonatomic, copy) GIOScanResultBlock resultBlock;

@end

NS_ASSUME_NONNULL_END
