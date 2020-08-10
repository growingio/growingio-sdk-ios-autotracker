//
//  PVarEventViewController.m
//  GrowingIOTest
//
//  Created by GrowingIO on 2018/6/5.
//  Copyright © 2018年 GrowingIO. All rights reserved.
//

#import "PVarEventViewController.h"
#import "GIODataProcessOperation.h"
#import "GIOConstants.h"

@interface PVarEventViewController ()

@property(nonatomic, strong)UIStoryboard *storyboard;

@end

@implementation PVarEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.PVarValiable.accessibilityLabel=@"PVarVal";
    self.PVarKey.accessibilityLabel=@"PVarKey";
    self.PVarNumVal.accessibilityLabel=@"PVarNv";
    self.PVarStrVal.accessibilityLabel=@"PVarSv";
    
    self.storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//setPageVariable操作
- (IBAction)setPvarVal:(id)sender {
    NSString *pvar = self.PVarValiable.text;
    if ([pvar isEqualToString:@"NULL"]) {
//        [Growing setPageVariable:nil toViewController:self];
    }
    else {
        NSDictionary *pvvar = [GIODataProcessOperation transStringToDic:pvar];
//        [Growing setPageVariable:pvvar toViewController:self];
    }
    NSLog(@"******setPageVariable:%@******",pvar);
}
//-setPageVariableWithKey:andStringValue操作
- (IBAction)setPvarWithStr:(id)sender {
    NSString *pvarkey = self.PVarKey.text;
    NSString *pstrval = self.PVarStrVal.text;
    //为方便测试，不判断数据
    if([pvarkey isEqualToString:@"NULL"]) {
        pvarkey=nil;
    }
    if ([pstrval isEqualToString:@"NULL"]) {
//        [Growing setPageVariableWithKey:pvarkey andStringValue:nil toViewController:self];
        NSLog(@"andStringValue is Nil!");
    } else {
//        [Growing setPageVariableWithKey:pvarkey andStringValue:pstrval toViewController:self];
        NSLog(@"***setPageVariableWithKey:%@ andStringValue:%@***",pvarkey,pstrval);
    }
}
//-setPageVariableWithKey:andNumberValue操作
- (IBAction)setPvarWithNum:(id)sender {
    NSString *pvarkey = self.PVarKey.text;
    NSString *pnumval = self.PVarNumVal.text;
    if ([pvarkey isEqualToString:@"NULL"]) {
        NSDictionary *pvar=[GIODataProcessOperation transStringToData:pnumval];
//        [Growing setPageVariableWithKey:nil andNumberValue:pvar[@"DataValue"] toViewController:self];
        NSLog(@"andNumberValue is nil");
    } else if ([pnumval isEqualToString:@"NULL"]) {
//        [Growing setPageVariableWithKey:pvarkey andNumberValue:nil toViewController:self];
        NSLog(@"***setPageVariableWithKey:%@ andNumberValue:%@***",pvarkey,nil);
    } else {
        NSDictionary *pvar=[GIODataProcessOperation transStringToData:pnumval];
//        [Growing setPageVariableWithKey:pvarkey andNumberValue:pvar[@"DataValue"] toViewController:self];
        NSLog(@"***setPageVariableWithKey:%@ andNumberValue:%@***",pvarkey,pvar[@"DataValue"]);
    }
}
//setPageVariable 值为超过100键值对
- (IBAction)setPvarOutRange:(id)sender {
    NSDictionary *pval = [GIOConstants getLargeDictionary];
//    [Growing setPageVariable:pval toViewController:self];
    NSLog(@"setPageVariable largeDic length is:%ld",pval.count);
}

@end
