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

@interface GIOButtonViewController ()<UIAlertViewDelegate>

@property (nonatomic, weak) IBOutlet UIButton *systemTextButton;
@property (nonatomic, weak) IBOutlet UIButton *systemContactAddButton;
@property (nonatomic, weak) IBOutlet UIButton *systemDetailDisclosureButton;
@property (nonatomic, weak) IBOutlet UIButton *imageButton;
@property (nonatomic, weak) IBOutlet UIButton *attributedTextButton;
@property (weak, nonatomic) IBOutlet UIButton *imageAndTextButton;

@end

@implementation GIOButtonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
    
    [alert show];   
}

// Show an alert with an "Okay" and "Cancel" button.
- (void)showOkayCancelAlert {
    NSString *title = NSLocalizedString(@"A Short Title Is Best", nil);
    NSString *message = NSLocalizedString(@"A message should be a short, complete sentence.", nil);
    NSString *cancelButtonTitle = NSLocalizedString(@"Cancel", nil);
    NSString *otherButtonTitle = NSLocalizedString(@"OK", nil);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitle, nil];
    
    [alert show];
}

// Show an alert with two custom buttons.
- (void)showOtherAlert {
    NSString *title = NSLocalizedString(@"A Short Title Is Best", nil);
    NSString *message = NSLocalizedString(@"A message should be a short, complete sentence.", nil);
    NSString *cancelButtonTitle = NSLocalizedString(@"Cancel", nil);
    NSString *otherButtonTitleOne = NSLocalizedString(@"Choice One", nil);
    NSString *otherButtonTitleTwo = NSLocalizedString(@"Choice Two", nil);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitleOne, otherButtonTitleTwo, nil];
    
    [alert show];
}

// Show a text entry alert with two custom buttons.
- (void)showTextEntryAlert {
    NSString *title = NSLocalizedString(@"A Short Title Is Best", nil);
    NSString *message = NSLocalizedString(@"A message should be a short, complete sentence.", nil);
    NSString *cancelButtonTitle = NSLocalizedString(@"Cancel", nil);
    NSString *otherButtonTitle = NSLocalizedString(@"OK", nil);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitle, nil];
    
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    [alert show];
}

// Show a secure text entry alert with two custom buttons.
- (void)showSecureTextEntryAlert {
    NSString *title = NSLocalizedString(@"A Short Title Is Best", nil);
    NSString *message = NSLocalizedString(@"A message should be a short, complete sentence.", nil);
    NSString *cancelButtonTitle = NSLocalizedString(@"Cancel", nil);
    NSString *otherButtonTitle = NSLocalizedString(@"OK", nil);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitle, nil];
    
    alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
    
    [alert show];
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

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.cancelButtonIndex == buttonIndex) {
        NSLog(@"Alert view clicked with the cancel button index.");
    }
    else {
        NSLog(@"Alert view clicked with button at index %ld.", (long)buttonIndex);
    }
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView {
    // Enforce a minimum length of >= 5 characters for secure text alert views.
    if (alertView.alertViewStyle == UIAlertViewStyleSecureTextInput) {
        return [[alertView textFieldAtIndex:0].text length] >= 5;
    }
    
    return YES;
}


@end
