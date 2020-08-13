//
//  GIOUICategoryViewController.m
//  GrowingExample
//
//  Created by GrowingIO on 14/03/2018.
//  Copyright © 2018 GrowingIO. All rights reserved.
//

#import "GIOUICategoryViewController.h"
#import "GIOConstants.h"
#import "GIOPageStructureViewController.h"

//协议中包含的事件类型
typedef NS_ENUM(NSInteger, GIOElementType) {
    GIOButtonsAndAlertView = 0,
    GIOWebView,
    GIOBannerAndTableView,
    GIOPageStructure,
    GIOTextFields,
    GIOSimpleUIElements,
    GIOPageControlAndImageView,
    GIOTextView,
    GIOActionSheet,
    GIOWKWebView,
    GIOMoveToSuperView,
    GIONotUICotrolView,
    GIONotification,
    GIOLabelAttribute,
    GIOLocation,
    GIOCollectionView
};

@interface GIOUICategoryViewController ()

@end

@implementation GIOUICategoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [UIView new];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
//更新列表头颜色
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    static NSString *kGrowingHeaderId = @"customHeader";
    
    UITableViewHeaderFooterView *vHeader;
    
    vHeader = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kGrowingHeaderId];
    
    if (!vHeader) {
        vHeader = [GIOConstants globalSectionHeaderForIdentifier:kGrowingHeaderId];
    }
    
    vHeader.textLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    
    return vHeader;
}

//表头高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return TableView_Section_Height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.section == 1 && indexPath.row == 1) { // handle page structure vc
        GIOPageStructureViewController *pageStructureVC = [GIOPageStructureViewController pageStructureViewController];
        [self.navigationController pushViewController:pageStructureVC animated:YES];
    }
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"测试类型--UI界面之：%@", cell.textLabel.text);
}

@end
