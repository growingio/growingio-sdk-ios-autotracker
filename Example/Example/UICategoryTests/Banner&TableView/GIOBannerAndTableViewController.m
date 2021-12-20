//
//  GIOBannerAndTableViewController.m
//  GrowingExample
//
//  Created by GrowingIO on 22/03/2018.
//  Copyright © 2018 GrowingIO. All rights reserved.
//

#import "GIOBannerAndTableViewController.h"
#import "GIOListTableViewCell.h"
#import <SDCycleScrollView/SDCycleScrollView.h>

@interface GIOBannerAndTableViewController ()<SDCycleScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) SDCycleScrollView *scrollHeaderView;
@property (nonatomic, strong) NSArray <NSString *> *titles;

@end

static NSString *kGrowingBannerTableViewCell = @"GIOBannerTableViewCell";
static NSString *kGrowingListTableViewCell = @"GIOListTableViewCell";

@implementation GIOBannerAndTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self configureTableView];
}

//配置tableview
- (void)configureTableView {
    
    UINib *nib = [UINib nibWithNibName:kGrowingListTableViewCell bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:kGrowingListTableViewCell];
    
    self.tableView.accessibilityIdentifier = @"GIOBannerAndTableViewIdentifier";
    self.tableView.accessibilityLabel= @"GIOBannerAndTableViewIdentifier";
    self.tableView.rowHeight = 195;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableHeaderView = self.scrollHeaderView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma table view

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    GIOListTableViewCell *listCell = [tableView dequeueReusableCellWithIdentifier:kGrowingListTableViewCell];
    listCell.index = indexPath.item;
    
    return listCell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 7;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Select %ld", indexPath.item);
}


#pragma mark - SDCycleScrollViewDelegate
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index {
    NSLog(@"---点击了第%ld张图片", (long)index);
}

#pragma mark Lazy Load

- (SDCycleScrollView *)scrollHeaderView {
    if (!_scrollHeaderView) {
        NSMutableArray *images = [NSMutableArray array];
        for (int i = 1; i < 9; i++) {
            [images addObject:[NSString stringWithFormat:@"cycle_0%d", i]];
        }
        _scrollHeaderView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 200)
                                                        imageNamesGroup:images];
        _scrollHeaderView.delegate = self;
        _scrollHeaderView.titlesGroup = self.titles;
    }
    return _scrollHeaderView;;
}

- (NSArray<NSString *> *)titles {
    if (!_titles) {
        _titles = @[@"banner_1",
                    @"banner_2", @"banner_3", @"banner_4", @"banner_5", @"banner_6", @"banner_7", @"banner_8"];
    }
    return _titles;
}

@end
