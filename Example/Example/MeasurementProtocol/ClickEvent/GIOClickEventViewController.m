//
//  GIOClickEventViewController.m
//  GrowingExample
//
//  Created by GrowingIO on 2020/2/26.
//  Copyright © 2020 GrowingIO. All rights reserved.
//

#import "GIOClickEventViewController.h"
#import "AppDelegate.h"
#import "UIView+GrowingImpression.h"

@interface GIOClickEventViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (weak, nonatomic) IBOutlet UIButton *sendEventButton;
@property (weak, nonatomic) IBOutlet UISwitch *trackEnabledSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *uploadEnabledSwitch;
@property (weak, nonatomic) IBOutlet UIButton *buttonA;
@property (weak, nonatomic) IBOutlet UIButton *buttonB;
@property (weak, nonatomic) IBOutlet UIButton *buttonC;
@property (weak, nonatomic) IBOutlet UIView *CView;
@property (weak, nonatomic) IBOutlet UIView *DView;
@property (weak, nonatomic) IBOutlet UIView *EView;

@end

@implementation GIOClickEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
#if defined(AUTOTRACKER)
#if defined(SDK3rd)
    [[GrowingAutotracker sharedInstance] autotrackPage:self alias:@"点击事件测试" attributes:@{@"greet": @"hello"}];
    self.sendEventButton.growingUniqueTag = @"UniqueTag-SendButton";
    [self.sendEventButton growingTrackImpression:@"hello_track_impression"];
    [self.view growingTrackImpression:@"self_view_imp_track" attributes:@{@"self_view_key": @"self_view_value"}];
    self.CView.growingUniqueTag = @"CCCCC";
    self.DView.growingUniqueTag = @"DDDDD";
    self.EView.growingUniqueTag = @"EEEEE";
    self.buttonA.growingUniqueTag = @"ButtonAAA";
#endif
#endif
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
//    [Growing setDataTrackEnabled:sender.isOn];
    NSLog(@"setDataTrackEnabled: %@", (sender.isOn ? @"YES" : @"NO"));
}

- (IBAction)uploadSwitchValueChange:(UISwitch *)sender {
//    [Growing setDataUploadEnabled:sender.isOn];
    NSLog(@"setDataUploadEnabled: %@", (sender.isOn ? @"YES" : @"NO"));
}

@end
