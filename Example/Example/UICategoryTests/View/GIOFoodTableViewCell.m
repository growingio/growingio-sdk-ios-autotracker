//
//  GIOFoodTableViewCell.m
//  GrowingExample
//
//  Created by GrowingIO on 22/03/2018.
//  Copyright © 2018 GrowingIO. All rights reserved.
//

#import "GIOFoodTableViewCell.h"

@interface GIOFoodTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *foodImageView;

@property (nonatomic, retain) NSArray *images;

@end


@implementation GIOFoodTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.images = @[@"food1", @"food2", @"food3", @"food4", @"food5", @"food6", @"food7", @"food8", @"food9"];
    self.foodImageView.image = [UIImage imageNamed:_images[(arc4random() % 9)]];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
