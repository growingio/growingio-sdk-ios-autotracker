//
//  GIOLabelAttributeViewController.m
//  GrowingIOTest
//
//  Created by GrowingIO on 2018/5/22.
//  Copyright © 2018年 GrowingIO. All rights reserved.
//

#import "GIOLabelAttributeViewController.h"
//#import "GrowingAutoTracker.h"
#import <GrowingAutoTracker.h>

#import <CoreLocation/CoreLocation.h>


@interface GIOLabelAttributeViewController () 
@end

@implementation GIOLabelAttributeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //设置不采集Btn GIONotTrack数据
    self.GIONotTrack.growingViewIgonrePolicy = GrowingIgnoreSelf;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//设置alpha的值为0.005
- (IBAction)SetAlphaSmall:(id)sender {
    self.CheckAlpLabel.alpha=0.005;
    NSLog(@"设置alpha的值为0.005");
}
//设置alpha的值为1
- (IBAction)SetAlphLarge:(id)sender {
    self.CheckAlpLabel.alpha=1;
    NSLog(@"设置alpha的值为1");
}
//隐藏label
- (IBAction)HiddenLabel:(id)sender {
    self.CheckHiddenLabel.hidden=TRUE;
    NSLog(@"隐藏Label标签！");
}
- (IBAction)ShowLabel:(id)sender {
    self.CheckHiddenLabel.hidden=false;
    NSLog(@"显示Label标签！");
}
//弹出浮层测试
- (IBAction)ShowAlertTest:(id)sender {
    //alert第一种形式
//    NSString *title = NSLocalizedString(@"A Short Title Is Best", nil);
//    NSString *message = NSLocalizedString(@"A message should be a short, complete sentence.", nil);
//    NSString *cancelButtonTitle = NSLocalizedString(@"Cancel", nil);
//    NSString *otherButtonTitleOne = NSLocalizedString(@"Choice One", nil);
//    NSString *otherButtonTitleTwo = NSLocalizedString(@"Choice Two", nil);
//
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitleOne, otherButtonTitleTwo, nil];
//    alert.window.windowLevel = 200;
//    [alert show];
    
    //alert第二种形式
//    UIAlertController *alert=[UIAlertController alertControllerWithTitle:@"Alert Test" message:@"Test Alert buttton action!" preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction *yesAction=[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
//        NSLog(@"Click OK Button of Alert!");
//    }];
//
//    UIAlertAction *noAction=[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
//        NSLog(@"Click Cancel Button of Alert!");
//    }];
//    [alert addAction:yesAction];
//    [alert addAction:noAction];
//    [self presentViewController:alert animated:true completion:nil];
    
    [self showalert];
    
}

-(void)showalert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"UIAlertView"
                                                    message:@"弹出式对话框相关测试！"
                                                   delegate:self
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles:nil, nil];
    [alert addButtonWithTitle:@"重新弹出"];
    [alert show];
}


//设置GIO不采集数据
- (IBAction)GIONotTrack:(id)sender {
    NSLog(@"GrowingIO 不采集点击事件！");
}

//监听点击事件 代理方法
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        [self showalert];
    }
     NSString *btnTitle = [alertView buttonTitleAtIndex:buttonIndex];
     NSLog(@"弹出框，单击了按钮：%@",btnTitle);
 }

@end
