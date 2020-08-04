//
//  GIOUserIdViewController.m
//  GrowingIOTest
//
//  Created by GrowingIO on 2018/5/22.
//  Copyright © 2018年 GrowingIO. All rights reserved.
//

#import "GIOUserIdViewController.h"
#import <GrowingAutoTracker.h>
#import "GIOConstants.h"

@interface GIOUserIdViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *userIdTextField;

@end

@implementation GIOUserIdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.userIdTextField.accessibilityLabel = @"userIdTextField";
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//设置UID为10048
- (IBAction)setUserId:(id)sender {
    [Growing setLoginUserId:@"10048"];
    NSLog(@"设置用户ID为10048");
}
//更新用户ID为10084
- (IBAction)changeUserId:(id)sender {
    [Growing setLoginUserId:@"10084"];
    NSLog(@"设置用户ID为10084");
}
//清除用户ID
- (IBAction)cleanUserId:(id)sender {
    [Growing cleanLoginUserId];
    NSLog(@"清除用户ID");
}
//自定义UID操作
- (IBAction)customSetUserId:(id)sender {
    NSString *userId = self.userIdTextField.text;
    [Growing setLoginUserId:userId];
    NSLog(@"设置用户ID为%@", userId);
}
//UID超过1000个字符操作
- (IBAction)setOutRangeUserId:(id)sender {
    NSString *outRangeUid = [GIOConstants getMyInput];
    NSLog(@"GetMyInput length:%ld",outRangeUid.length);
    [Growing setLoginUserId:outRangeUid];
}

- (IBAction)tapGestureHandle:(UITapGestureRecognizer *)sender {
    [self.userIdTextField resignFirstResponder];
    [self.view endEditing:YES];
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.userIdTextField && textField.text) {
        [Growing setLoginUserId:textField.text];
        [textField resignFirstResponder];
    }
    
    return YES;
}

@end
