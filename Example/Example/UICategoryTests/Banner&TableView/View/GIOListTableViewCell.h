//
//  GIOListTableViewCell.h
//  GrowingExample
//
//  Created by GrowingIO on 22/03/2018.
//  Copyright © 2018 GrowingIO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GIOListTableViewCell : UITableViewCell<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, assign) NSInteger index;

@end
