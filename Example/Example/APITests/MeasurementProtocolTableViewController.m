//
//  MeasurementProtocolTableViewController.m
//  GrowingExample
//
//  Created by GrowingIO on 20/03/2018.
//  Copyright © 2018 GrowingIO. All rights reserved.
//

#import "MeasurementProtocolTableViewController.h"
#import "GIOAttributesTrackViewController.h"
#import "GIOConstants.h"

//测量协议规定的数据分类：埋点、无埋点和API测试
typedef NS_ENUM(NSInteger, GIOMeasurementProtocolCount) {
    GIOAutoTrack = 0,
    GIOManualTrack,
    GIOAPI
};

@interface MeasurementProtocolTableViewController ()

@end

@implementation MeasurementProtocolTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.accessibilityIdentifier = @"MeasurementProtocolTableView";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"测试类型--测量协议之：%@", cell.textLabel.text);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:GIOAttributesTrackViewController.class]) {
        GIOAttributesTrackViewController *vc = (GIOAttributesTrackViewController *)segue.destinationViewController;
        vc.eventType = segue.identifier;
    }
}

//更新列表头颜色
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    static NSString *kGrowingheaderId = @"customHeader";
    
    UITableViewHeaderFooterView *vHeader;
    
    vHeader = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kGrowingheaderId];
    
    if (!vHeader) {
        vHeader = [GIOConstants globalSectionHeaderForIdentifier:kGrowingheaderId];
    }
    
    vHeader.textLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    
    return vHeader;
}

//表头高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return TableView_Section_Height;
}

@end
