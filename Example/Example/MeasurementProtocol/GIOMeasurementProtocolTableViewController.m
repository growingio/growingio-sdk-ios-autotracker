//
//  GIOMeasurementProtocolTableViewController.m
//  GrowingExample
//
//  Created by GrowingIO on 20/03/2018.
//  Copyright © 2018 GrowingIO. All rights reserved.
//

#import "GIOMeasurementProtocolTableViewController.h"
#import "GIOAttributesTrackViewController.h"
#import "GIOConstants.h"
#import "GIOWebViewWarmuper.h"

//测量协议规定的数据分类：埋点、无埋点和API测试
typedef NS_ENUM(NSInteger, GIOMeasurementProtocolCount) { GIOAutoTrack = 0, GIOManualTrack, GIOAPI };

@interface GIOMeasurementProtocolTableViewController ()

@property (weak, nonatomic) IBOutlet UISwitch *dataCollectionEnabledSwitch;

@end

@implementation GIOMeasurementProtocolTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
#if defined(AUTOTRACKER)
#if defined(SDK3rd)
    [[GrowingAutotracker sharedInstance] autotrackPage:self alias:@"首页" attributes:@{@"xxx" : @"111mmm"}];
#endif
#endif
    self.tableView.accessibilityIdentifier = @"MeasurementProtocolTableView";
    
    self.dataCollectionEnabledSwitch.on = self.dataCollectionEnabled;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[GIOWebViewWarmuper sharedInstance] prepare];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)setDataCollectionEnabled:(UISwitch *)sender {
#if defined(SDK3rd)
    [[GrowingSDK sharedInstance] setDataCollectionEnabled:sender.isOn];
#endif
}

- (void)buttonAction {
    
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
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    [button setTitle:[NSString stringWithFormat:@"header%ld", (long)section] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
    [vHeader addSubview:button];
    
    [NSLayoutConstraint activateConstraints:@[
        [button.centerYAnchor constraintEqualToAnchor:vHeader.centerYAnchor],
        [button.trailingAnchor constraintEqualToAnchor:vHeader.trailingAnchor constant:-15.0f],
        [button.widthAnchor constraintEqualToConstant:80.0f],
        [button.heightAnchor constraintEqualToConstant:35.0f]
    ]];

    return vHeader;
}

//表头高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44.0f;
}

#pragma mark - Getter & Setter

- (BOOL)dataCollectionEnabled {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    Class class = NSClassFromString(@"GrowingConfigurationManager");
    SEL selector = NSSelectorFromString(@"sharedInstance");
    if (class && [class respondsToSelector:selector]) {
        id manager = [class performSelector:selector];
        SEL configurationSelector = NSSelectorFromString(@"trackConfiguration");
        if (manager && [manager respondsToSelector:configurationSelector]) {
            NSObject *configuration = [manager performSelector:configurationSelector];
            if (configuration) {
                return ((NSNumber *)[configuration valueForKey:@"dataCollectionEnabled"]).boolValue;
            }
        }
    }
#pragma clang diagnostic pop
    return YES;
}

@end
