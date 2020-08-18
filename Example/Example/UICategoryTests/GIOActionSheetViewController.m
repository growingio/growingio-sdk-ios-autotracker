//
//  GIOActionSheetViewController.m
//  GrowingExample
//
//  Created by GrowingIO on 23/03/2018.
//  Copyright © 2018 GrowingIO. All rights reserved.
//

#import "GIOActionSheetViewController.h"
#import <GrowingAlert.h>


// Corresponds to the row in the action sheet section.
typedef NS_ENUM(NSInteger, GIOActionSheetsViewControllerTableRow) {
    GIOAlertsViewControllerActionSheetRowOkayCancel = 0,
    GIOAlertsViewControllerActionSheetRowOther,
    GrwingAlertOneMenuRow,
    GrwingAlertTwoMenuRow,
    GrwingAlertThreeMenuRow,
    GrwingAlertTwoTextMenuRow,
};

@interface GIOActionSheetViewController ()<UIActionSheetDelegate>

@end

@implementation GIOActionSheetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [UIView new];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Show a dialog with an "Okay" and "Cancel" button.
- (void)showOkayCancelActionSheet {
    NSString *cancelButtonTitle = NSLocalizedString(@"Cancel", nil);
    NSString *destructiveButtonTitle = NSLocalizedString(@"OK", nil);
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:cancelButtonTitle
                                               destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:nil];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    
    [actionSheet showInView:self.view];
}

// Show a dialog with two custom buttons.
- (void)showOtherActionSheet {
    NSString *destructiveButtonTitle = NSLocalizedString(@"Destructive Choice", nil);
    NSString *otherButtonTitle = NSLocalizedString(@"Safe Choice", nil);
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:otherButtonTitle, nil];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    
    [actionSheet showInView:self.view];
}

- (void)showGrowingAlertMenuOne {
    
    GrowingAlert *alert = [GrowingAlert createAlertWithStyle:UIAlertControllerStyleAlert
                                                       title:@"提示"
                                                     message:@"电脑端连接超时，请刷新电脑页面，再次尝试扫码圈选。"];
    [alert addOkWithTitle:@"知道了"
                  handler:^(UIAlertAction * _Nonnull action, NSArray<UITextField *> * _Nonnull textFields) {
        NSLog(@"aciton = %@, textFields = %@", action, textFields);
    }];
    
    [alert showAlertAnimated:YES];
    
}

- (void)showGrowingAlertMenuTwo {
    
    GrowingAlert *alert = [GrowingAlert createAlertWithStyle:UIAlertControllerStyleAlert
                                                       title:@"提示"
                                                     message:@"电脑端连接超时，请刷新电脑页面，再次尝试扫码圈选。"];
    [alert addOkWithTitle:@"知道了"
                  handler:^(UIAlertAction * _Nonnull action, NSArray<UITextField *> * _Nonnull textFields) {
        NSLog(@"aciton = %@, textFields = %@", action, textFields);
    }];
    
    [alert addCancelWithTitle:@"取消"
                  handler:^(UIAlertAction * _Nonnull action, NSArray<UITextField *> * _Nonnull textFields) {
        NSLog(@"aciton = %@, textFields = %@", action, textFields);
    }];
    
    [alert showAlertAnimated:YES];
}

- (void)showGrowingAlertMenuThree {
    
    GrowingAlert *alert = [GrowingAlert createAlertWithStyle:UIAlertControllerStyleAlert
                                                       title:@"提示"
                                                     message:@"电脑端连接超时，请刷新电脑页面，再次尝试扫码圈选。"];
    [alert addActionWithTitle:@"One" style:UIAlertActionStyleDefault handler:nil];
    [alert addActionWithTitle:@"Two" style:UIAlertActionStyleDefault handler:nil];
    [alert addActionWithTitle:@"Three" style:UIAlertActionStyleDefault handler:nil];

    [alert showAlertAnimated:YES];

}

- (void)showGrowingAlertMenuTwoText {
    
    GrowingAlert *alert = [GrowingAlert createAlertWithStyle:UIAlertControllerStyleAlert
                                                       title:@"提示"
                                                     message:@"电脑端连接超时，请刷新电脑页面，再次尝试扫码圈选。"];
    [alert addActionWithTitle:@"One" style:UIAlertActionStyleDefault handler:nil];
    [alert addActionWithTitle:@"Two" style:UIAlertActionStyleDefault handler:nil];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"account-name";
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"account-passwrokd";
    }];
    [alert showAlertAnimated:YES];

}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.destructiveButtonIndex == buttonIndex) {
        NSLog(@"Action sheet clicked with the destructive button index.");
    }
    else if (actionSheet.cancelButtonIndex == buttonIndex) {
        NSLog(@"Action sheet clicked with the cancel button index.");
    }
    else {
        NSLog(@"Action sheet clicked with button at index %ld.", (long)buttonIndex);
    }
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GIOActionSheetsViewControllerTableRow row = indexPath.row;

    switch (row) {
        case GIOAlertsViewControllerActionSheetRowOkayCancel:
            [self showOkayCancelActionSheet];
            break;
        case GIOAlertsViewControllerActionSheetRowOther:
            [self showOtherActionSheet];
            break;
        case GrwingAlertOneMenuRow:
            [self showGrowingAlertMenuOne];
            break;
        case GrwingAlertTwoMenuRow:
            [self showGrowingAlertMenuTwo];
            break;
        case GrwingAlertThreeMenuRow:
            [self showGrowingAlertMenuThree];
            break;
        case GrwingAlertTwoTextMenuRow:
            [self showGrowingAlertMenuTwoText];
            break;
        default:
            break;
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
