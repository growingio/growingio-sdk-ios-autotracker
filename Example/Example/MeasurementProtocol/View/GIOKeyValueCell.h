//
//  GIOKeyValueCell.h
//  GrowingExample
//
//  Created by GrowingIO on 2020/6/9.
//  Copyright © 2020 GrowingIO. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GIOKeyValueCell;

NS_ASSUME_NONNULL_BEGIN

@protocol GIOKeyValueCellDelegate <NSObject>

@optional

- (void)GIOKeyValueCell:(GIOKeyValueCell *)keyValueCell contentDidChanged:(NSDictionary *)newContentDict;

@end

@interface GIOKeyValueCell : UITableViewCell

- (void)configContentDict:(NSDictionary *)contentDict;

@property (nonatomic, weak) id <GIOKeyValueCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
