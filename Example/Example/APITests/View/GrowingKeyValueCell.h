//
//  GrowingKeyValueCell.h
//  GrowingExample
//
//  Created by GrowingIO on 2020/6/9.
//  Copyright © 2020 GrowingIO. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GrowingKeyValueCell;

NS_ASSUME_NONNULL_BEGIN

@protocol GrowingKeyValueCellDelegate <NSObject>

@optional

- (void)growingKeyValueCell:(GrowingKeyValueCell *)keyValueCell contentDidChanged:(NSDictionary *)newContentDict;

@end

@interface GrowingKeyValueCell : UITableViewCell

- (void)configContentDict:(NSDictionary *)contentDict;

@property (nonatomic, weak) id <GrowingKeyValueCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
