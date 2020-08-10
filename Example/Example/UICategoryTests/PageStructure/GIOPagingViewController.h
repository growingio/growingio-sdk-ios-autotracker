//
//  GIOPagingViewController.h
//  Example
//
//  Created by BeyondChao on 2020/8/10.
//  Copyright © 2020 GrowingIO. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GIOPageItemController : UIViewController

// Item controller information
@property (nonatomic) NSUInteger itemIndex;
@property (nonatomic, strong) NSString *imageName;

@end


@interface GIOPagingViewController : UIViewController

@end

NS_ASSUME_NONNULL_END
