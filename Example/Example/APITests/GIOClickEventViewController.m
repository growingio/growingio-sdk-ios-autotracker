//
//  GIOClickEventViewController.m
//  GrowingIOTest
//
//  Created by GrowingIO on 2020/2/26.
//  Copyright © 2020 GrowingIO. All rights reserved.
//

#import "GIOClickEventViewController.h"
#import <GrowingAutoTracker.h>

@interface GIOClickEventViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (weak, nonatomic) IBOutlet UIButton *sendEventButton;

@end

@implementation GIOClickEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.growingPageAlias = @"CLICK_EVENT_VC_ON_OPTION";
    self.segmentControl.growingUniqueTag = @"language-selector";
    self.view.growingViewIgnorePolicy = GrowingIgnoreChild;
 
    self.growingPageAttributes = @{@"greet": @"hello"};
    self.growingPageIgonrePolicy = GrowingIgnoreChild;
    
    self.parentViewController.growingPageIgonrePolicy = GrowingIgnoreAll;
    [self.sendEventButton growingTrackImpression:@"hello_track_impression"];
    [self.view growingTrackImpression:@"self_view_imp_track" attributes:@{@"self_view_key": @"self_view_value"}];
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

@end
