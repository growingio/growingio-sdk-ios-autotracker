//
//  GIOUserIdViewController.m
//  GrowingExample
//
//  Created by GrowingIO on 2018/5/22.
//  Copyright (C) 2018 Beijing Yishu Technology Co., Ltd.
//

#import "GIOUserIdViewController.h"
#import "GIOConstants.h"
#import "GrowingAutotracker.h"
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
    [[GrowingAutotracker sharedInstance] setLoginUserId:@"10048"];
    NSLog(@"设置用户ID为10048");
}
//更新用户ID为10084
- (IBAction)changeUserId:(id)sender {
    [[GrowingAutotracker sharedInstance] setLoginUserId:@"10084"];
    NSLog(@"设置用户ID为10084");
}
//清除用户ID
- (IBAction)cleanUserId:(id)sender {
    [[GrowingAutotracker sharedInstance] cleanLoginUserId];
    NSLog(@"清除用户ID");
}
//自定义UID操作
- (IBAction)customSetUserId:(id)sender {
    NSString *userId = self.userIdTextField.text;
    [[GrowingAutotracker sharedInstance] setLoginUserId:userId];
    NSLog(@"设置用户ID为%@", userId);
}
//UID超过1000个字符操作
- (IBAction)setOutRangeUserId:(id)sender {
    NSString *outRangeUid = [GIOConstants getMyInput];
    NSLog(@"GetMyInput length:%ld",outRangeUid.length);
    [[GrowingAutotracker sharedInstance] setLoginUserId:outRangeUid];
}

- (IBAction)tapGestureHandle:(UITapGestureRecognizer *)sender {
    [self.userIdTextField resignFirstResponder];
    [self.view endEditing:YES];
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.userIdTextField && textField.text) {
        [[GrowingAutotracker sharedInstance] setLoginUserId:textField.text];
        [textField resignFirstResponder];
    }
    
    return YES;
}

@end
