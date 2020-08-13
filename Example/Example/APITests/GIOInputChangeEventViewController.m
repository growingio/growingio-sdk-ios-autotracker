//
//  GIOInputChangeEventViewController.m
//  GrowingExample
//
//  Created by GrowingIO on 27/03/2018.
//  Copyright © 2018 GrowingIO. All rights reserved.
//

#import "GIOInputChangeEventViewController.h"

@interface GIOInputChangeEventViewController ()<UITextFieldDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passWordTextField;

@property (weak, nonatomic) IBOutlet UISearchBar *searchbartest;
@property (weak, nonatomic) IBOutlet UILabel *showDate;
@property (weak, nonatomic) IBOutlet UIDatePicker *dataPickerOper;

@end

@implementation GIOInputChangeEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.searchbartest.placeholder = @"搜索";
    self.searchbartest.accessibilityLabel = @"SearchBarTest";
    //[self.searchbartest resignFirstResponder];
    self.searchbartest.delegate = self;
    //日期选择
    self.dataPickerOper.datePickerMode = UIDatePickerModeDate;
    [self.dataPickerOper addTarget:self action:@selector(dateChange:) forControlEvents:UIControlEventValueChanged];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UISearchBarDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    if (textField == self.userNameTextField) {
        [self.passWordTextField becomeFirstResponder];
    }
    return NO;
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    NSLog(@"开始输入搜索内容");
    [searchBar setShowsCancelButton:YES animated:YES]; // 动画显示取消按钮
//    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = @"";
    [searchBar setShowsCancelButton:NO animated:YES];
    NSLog(@"清空搜索框！");
    [searchBar resignFirstResponder];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"开始搜索：%@",searchBar.text);
    [searchBar setShowsCancelButton:NO animated:YES]; 
    [searchBar resignFirstResponder];
}

-(void)dateChange:(UIDatePicker *)datePicker{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    //设置时间格式
    formatter.dateFormat = @"yyyy年 MM月 dd日";
    NSString *dateStr = [formatter stringFromDate:datePicker.date];
    
    self.showDate.text=dateStr;
}

@end
