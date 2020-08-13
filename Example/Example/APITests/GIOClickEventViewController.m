//
//  GIOClickEventViewController.m
//  GrowingExample
//
//  Created by GrowingIO on 2020/2/26.
//  Copyright © 2020 GrowingIO. All rights reserved.
//

#import "GIOClickEventViewController.h"
#import <GrowingAutoTracker.h>
#import <GrowingTracker.h>
#import "AppDelegate.h"

@interface GIOClickEventViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (weak, nonatomic) IBOutlet UIButton *sendEventButton;
@property (weak, nonatomic) IBOutlet UISwitch *trackEnabledSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *uploadEnabledSwitch;

@end

@implementation GIOClickEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.growingPageAlias = @"CLICK_EVENT_VC_ON_OPTION";
    self.segmentControl.growingUniqueTag = @"language-selector";
 
    self.growingPageAttributes = @{@"greet": @"hello"};
//    self.growingPageIgnorePolicy = GrowingIgnoreChild;
    
//    self.parentViewController.growingPageIgnorePolicy = GrowingIgnoreAll;
    [self.sendEventButton growingTrackImpression:@"hello_track_impression"];
    [self.view growingTrackImpression:@"self_view_imp_track" attributes:@{@"self_view_key": @"self_view_value"}];
    
    if ([UIApplication.sharedApplication.delegate isKindOfClass:AppDelegate.class]) {
        AppDelegate *appDelegate = (AppDelegate *)UIApplication.sharedApplication.delegate;
        [self.trackEnabledSwitch setOn:appDelegate.configuation.dataTrackEnabled animated:YES];
        [self.uploadEnabledSwitch setOn:appDelegate.configuation.dataUploadEnabled animated:YES];
    }
}

- (IBAction)buttonClick:(UIButton *)sender {
    NSLog(@"func = %s, line = %d", __func__, __LINE__);
}

- (IBAction)segmentValueChanged:(UISegmentedControl *)sender {
    NSLog(@"func = %s, line = %d", __func__, __LINE__);
}

- (IBAction)singleTapHandle:(UITapGestureRecognizer *)sender {
    NSLog(@"func = %s, line = %d", __func__, __LINE__);
}

- (IBAction)doubleTapHandle:(UITapGestureRecognizer *)sender {
    NSLog(@"func = %s, line = %d", __func__, __LINE__);
}

- (IBAction)trackSwitchValueChange:(UISwitch *)sender {
    [Growing setDataTrackEnabled:sender.enabled];
    NSLog(@"setDataTrackEnabled: %@", (sender.enabled ? @"YES" : @"NO"));
}

- (IBAction)uploadSwitchValueChange:(UISwitch *)sender {
    [Growing setDataUploadEnabled:sender.enabled];
    NSLog(@"setDataUploadEnabled: %@", (sender.enabled ? @"YES" : @"NO"));
}

@end
