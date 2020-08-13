//
//  GrowingKeyValueCell.m
//  GrowingExample
//
//  Created by GrowingIO on 2020/6/9.
//  Copyright © 2020 GrowingIO. All rights reserved.
//

#import "GrowingKeyValueCell.h"

@interface GrowingKeyValueCell () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *keyTextField;
@property (weak, nonatomic) IBOutlet UITextField *valueTextField;

@property (nonatomic, copy) NSString *savedOriginKey;

@end

@implementation GrowingKeyValueCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.keyTextField.delegate = self;
    self.valueTextField.delegate = self;
    
    [self.keyTextField addTarget:self action:@selector(keyTextFieldValueDidChanged:) forControlEvents:UIControlEventEditingDidEnd];
    [self.valueTextField addTarget:self action:@selector(valueTextFieldValueDidChanged:) forControlEvents:UIControlEventEditingDidEnd];

}

- (void)keyTextFieldValueDidChanged:(UITextField *)sender {
    [self notifiyDelegateForNewContent:@{sender.text: self.valueTextField.text}];
}

- (void)valueTextFieldValueDidChanged:(UITextField *)sender {
    [self notifiyDelegateForNewContent:@{self.keyTextField.text: sender.text}];
}

- (void)notifiyDelegateForNewContent:(NSDictionary *)dict {
    if ([self.delegate respondsToSelector:@selector(growingKeyValueCell:contentDidChanged:)]) {
        [self.delegate growingKeyValueCell:self contentDidChanged:dict];
    }
}

- (void)configContentDict:(NSDictionary *)contentDict {
    
    self.savedOriginKey = contentDict.allKeys.firstObject;
    self.keyTextField.text = self.savedOriginKey;
    self.valueTextField.text = contentDict.allValues.firstObject;
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
