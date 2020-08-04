//
//  PVarEventViewController.h
//  GrowingIOTest
//
//  Created by GrowingIO on 2018/6/5.
//  Copyright © 2018年 GrowingIO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PVarEventViewController : UIViewController
//pvar valiable
@property (weak, nonatomic) IBOutlet UITextField *PVarValiable;

//pvar key
@property (weak, nonatomic) IBOutlet UITextField *PVarKey;

//pvar StringValue
@property (weak, nonatomic) IBOutlet UITextField *PVarStrVal;

//pvar NumberValue
@property (weak, nonatomic) IBOutlet UITextField *PVarNumVal;

@end
