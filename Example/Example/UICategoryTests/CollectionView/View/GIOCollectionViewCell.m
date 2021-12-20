//
//  GIOCollectionViewCell.m
//  GrowingExample
//
//  Created by GrowingIO on 2020/6/9.
//  Copyright © 2020 GrowingIO. All rights reserved.
//

#import "GIOCollectionViewCell.h"

@interface GIOCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation GIOCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.contentView.backgroundColor = [UIColor lightGrayColor];
    self.contentView.layer.cornerRadius = 3.0;
}

- (void)configWithTitle:(NSString *)title andIamgeName:(NSString *)imageName {
    self.titleLabel.text = title;
    self.imageView.image = [UIImage imageNamed:imageName];
}

@end
