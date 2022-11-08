//
//  GIOButtonViewController.m
//  GrowingExample
//
//  Created by GrowingIO on 21/03/2018.
//  Copyright © 2018 GrowingIO. All rights reserved.
//

#import "GIOButtonViewController.h"

// Corresponds to the row in the alert view section.
typedef NS_ENUM(NSInteger, AAPLAlertsViewControllerTableRow) {
    AAPLAlertsViewControllerAlertViewRowSimple = 2000,
    AAPLAlertsViewControllerAlertViewRowOkayCancel,
    AAPLAlertsViewControllerAlertViewRowOther,
    AAPLAlertsViewControllerAlertViewRowTextEntry,
    AAPLAlertsViewControllerActionSheetRowTextEntrySecure
};

@interface GIOButtonViewController ()<UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UIButton *systemTextButton;
@property (nonatomic, weak) IBOutlet UIButton *systemContactAddButton;
@property (nonatomic, weak) IBOutlet UIButton *systemDetailDisclosureButton;
@property (nonatomic, weak) IBOutlet UIButton *imageButton;
@property (nonatomic, weak) IBOutlet UIButton *attributedTextButton;
@property (weak, nonatomic) IBOutlet UIButton *imageAndTextButton;
@property (nonatomic, strong) UIAlertAction *otherAction;

@end

@implementation GIOButtonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
#if defined(AUTOTRACKER)
#if defined(SDK3rd)
    self.growingPageAlias = @"xxxx";
    self.view.growingUniqueTag = @"我是一个特别的view";
#endif
#endif
    self.title = @"Buttons & AlertView";
    
    [self configureAttributedTextSystemButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Configuration

- (void)configureAttributedTextSystemButton {
    NSDictionary *titleAttributes = @{NSForegroundColorAttributeName: [UIColor colorWithRed:0.333 green:0.784 blue:1 alpha:1], NSStrikethroughStyleAttributeName: @(NSUnderlineStyleSingle)};
    NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Button", nil) attributes:titleAttributes];
    [self.attributedTextButton setAttributedTitle:attributedTitle forState:UIControlStateNormal];
    
    NSDictionary *highlightedTitleAttributes = @{NSForegroundColorAttributeName : [UIColor colorWithRed:0.255 green:0.804 blue:0.470 alpha:1], NSStrikethroughStyleAttributeName: @(NSUnderlineStyleThick)};
    NSAttributedString *highlightedAttributedTitle = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Button", nil) attributes:highlightedTitleAttributes];
    [self.attributedTextButton setAttributedTitle:highlightedAttributedTitle forState:UIControlStateHighlighted];
    
}

#pragma mark - Actions

// Show an alert with an "Okay" button.
- (void)showSimpleAlert {
    NSString *title = NSLocalizedString(@"A Short Title Is Best", nil);
    NSString *message = NSLocalizedString(@"A message should be a short, complete sentence.", nil);
    NSString *cancelButtonTitle = NSLocalizedString(@"OK", nil);
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;
    [controller addAction:[UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf actionClicked:action];
    }]];
    [self presentViewController:controller animated:YES completion:nil];
}

// Show an alert with an "Okay" and "Cancel" button.
- (void)showOkayCancelAlert {
    NSString *title = NSLocalizedString(@"A Short Title Is Best", nil);
    NSString *message = NSLocalizedString(@"A message should be a short, complete sentence.", nil);
    NSString *cancelButtonTitle = NSLocalizedString(@"Cancel", nil);
    NSString *otherButtonTitle = NSLocalizedString(@"OK", nil);
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;
    [controller addAction:[UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf actionClicked:action];
    }]];
    [controller addAction:[UIAlertAction actionWithTitle:otherButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf actionClicked:action];
    }]];
    [self presentViewController:controller animated:YES completion:nil];
}

// Show an alert with two custom buttons.
- (void)showOtherAlert {
    NSString *title = NSLocalizedString(@"A Short Title Is Best", nil);
    NSString *message = NSLocalizedString(@"A message should be a short, complete sentence.", nil);
    NSString *cancelButtonTitle = NSLocalizedString(@"Cancel", nil);
    NSString *otherButtonTitleOne = NSLocalizedString(@"Choice One", nil);
    NSString *otherButtonTitleTwo = NSLocalizedString(@"Choice Two", nil);
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;
    [controller addAction:[UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf actionClicked:action];
    }]];
    [controller addAction:[UIAlertAction actionWithTitle:otherButtonTitleOne style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf actionClicked:action];
    }]];
    [controller addAction:[UIAlertAction actionWithTitle:otherButtonTitleTwo style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf actionClicked:action];
    }]];
    [self presentViewController:controller animated:YES completion:nil];
}

// Show a text entry alert with two custom buttons.
- (void)showTextEntryAlert {
    NSString *title = NSLocalizedString(@"A Short Title Is Best", nil);
    NSString *message = NSLocalizedString(@"A message should be a short, complete sentence.", nil);
    NSString *cancelButtonTitle = NSLocalizedString(@"Cancel", nil);
    NSString *otherButtonTitle = NSLocalizedString(@"OK", nil);
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;
    [controller addAction:[UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf actionClicked:action];
    }]];
    [controller addAction:[UIAlertAction actionWithTitle:otherButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf actionClicked:action];
    }]];
    [controller addTextFieldWithConfigurationHandler:nil];
    [self presentViewController:controller animated:YES completion:nil];
}

// Show a secure text entry alert with two custom buttons.
- (void)showSecureTextEntryAlert {
    NSString *title = NSLocalizedString(@"A Short Title Is Best", nil);
    NSString *message = NSLocalizedString(@"A message should be a short, complete sentence.", nil);
    NSString *cancelButtonTitle = NSLocalizedString(@"Cancel", nil);
    NSString *otherButtonTitle = NSLocalizedString(@"OK", nil);
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;
    [controller addAction:[UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf actionClicked:action];
    }]];
    self.otherAction = [UIAlertAction actionWithTitle:otherButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf actionClicked:action];
    }];
    self.otherAction.enabled = NO;
    [controller addAction:self.otherAction];
    [controller addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.secureTextEntry = YES;
        textField.delegate = self;
    }];
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)systemTextBtnClick:(UIButton *)sender {
    [self showSimpleAlert];
}

- (IBAction)systemContactAddClick:(UIButton *)sender {
    [self showOkayCancelAlert];
}

- (IBAction)systemDisclosureBtnClick:(UIButton *)sender {
    [self showOtherAlert];
}

- (IBAction)systemImageBtnClick:(UIButton *)sender {
    [self showTextEntryAlert];
}

- (IBAction)attributeTextBtnClick:(UIButton *)sender {
    [self showSecureTextEntryAlert];
}

- (IBAction)imageAndTextBtnClick:(UIButton *)sender {
    [self showSecureTextEntryAlert];
}

- (void)actionClicked:(UIAlertAction * _Nonnull)action {
    NSLog(@"Alert view clicked with the %@ button.", action.title);
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (self.otherAction) {
        self.otherAction.enabled = text.length >= 5;
    }

    return YES;
}

@end
