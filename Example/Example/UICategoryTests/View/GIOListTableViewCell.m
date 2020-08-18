//
//  GIOListTableViewCell.m
//  GrowingExample
//
//  Created by GrowingIO on 22/03/2018.
//  Copyright © 2018 GrowingIO. All rights reserved.
//

#import "GIOListTableViewCell.h"
#import "GIOFoodTableViewCell.h"

@interface GIOListTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *subtitle;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *catalogBtn;

@property (nonatomic, retain) NSArray *cuisine;
@property (nonatomic, retain) NSArray *rooms;
@property (nonatomic, retain) NSArray *restaurants;

@end

@implementation GIOListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self configureTableView];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _cuisine = @[@"川菜", @"粤菜", @"炸货", @"小吃", @"零食", @"日料", @"韩式"];
    _rooms = @[@"乾", @"兑", @"离", @"震", @"巽", @"坎", @"坤"];
    _restaurants = @[@"风满楼", @"醉仙居", @"飘渺居", @"静怡轩", @"东来居", @"聚仙阁",@"客来居"];
}

- (void)configureTableView {
    UINib *nib = [UINib nibWithNibName:@"GIOFoodTableViewCell" bundle:nil];
    [_tableView registerNib:nib forCellReuseIdentifier:@"GIOFoodTableViewCell"];
    [_tableView setBounds:CGRectMake(0, 0, 100, 375)];
    _tableView.transform = CGAffineTransformMakeRotation(M_PI_2);
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.scrollEnabled = YES;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.rowHeight = 100;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setIndex:(NSInteger)index {
    _title.text = [NSString stringWithFormat:@"%@", _restaurants[index]];
    _title.accessibilityLabel = [NSString stringWithFormat:@"Restaurant%ld", index];
    _subtitle.text = [NSString stringWithFormat:@"包间:%@", _rooms[index]];
    [_catalogBtn setTitle:[NSString stringWithFormat:@"菜系:%@", _cuisine[index]] forState:UIControlStateNormal];
    _tableView.accessibilityIdentifier = [NSString stringWithFormat:@"FoodTableView%ld", index];
}

#pragma table view
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GIOFoodTableViewCell"];
    [cell.contentView setTransform:CGAffineTransformMakeRotation(-M_PI_2)];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Select %ld", indexPath.item);
}

@end
