//
//  GIOScanViewController.h
//  GrowingIOTest
//
//  Created by YoloMao on 2021/7/22.
//  Copyright © 2021 GrowingIO. All rights reserved.
//

#define LBXScan_Define_Native
#define LBXScan_Define_UI

#import <LBXScan/LBXScanViewController.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^GIOScanResultBlock)(NSString *string);

@interface GIOScanViewController : LBXScanViewController

@property (nonatomic, copy) GIOScanResultBlock resultBlock;

@end

NS_ASSUME_NONNULL_END
