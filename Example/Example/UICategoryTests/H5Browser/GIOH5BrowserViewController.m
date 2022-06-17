//
//  GIOH5BrowserViewController.m
//  GrowingIOTest
//
//  Created by YoloMao on 2021/7/22.
//  Copyright © 2021 GrowingIO. All rights reserved.
//

#import "GIOH5BrowserViewController.h"
#import "GIODefaultWebViewController.h"
#import "GIOScanViewController.h"

@interface GIOH5BrowserViewController () <
UITableViewDelegate,
UITableViewDataSource,
UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *h5UrlTextView;
@property (weak, nonatomic) IBOutlet UIButton *jumpBtn;
@property (weak, nonatomic) IBOutlet UIButton *scanJumpBtn;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation GIOH5BrowserViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"H5任意门";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.dataSource = [self h5historicalRecord];
    [self.tableView reloadData];
}

#pragma mark - Private

- (void)jump {
    if (self.h5UrlTextView.text.length == 0) {
        return;
    }

    if (![NSURL URLWithString:self.h5UrlTextView.text]) {
        return;
    }

    NSString *text = self.h5UrlTextView.text;
    [self saveH5historicalRecordWithText:text];
    
    GIODefaultWebViewController *controller = [[GIODefaultWebViewController alloc] init];
    controller.h5Url = [self urlCorrectionWithURL:text];
    [self.navigationController pushViewController:controller animated:YES];
}

- (NSString *)urlCorrectionWithURL:(NSString *)URL {
    if (!URL || URL.length <= 0) {
        return URL;
    }
    
    if (![URL hasPrefix:@"http://"] && ![URL hasPrefix:@"https://"]) {
        return [NSString stringWithFormat:@"https://%@",URL];
    }
    
    if ([URL hasPrefix:@":"]) {
        return [NSString stringWithFormat:@"https%@",URL];
    }
    
    if ([URL hasPrefix:@"//"]) {
        return [NSString stringWithFormat:@"https:%@",URL];
    }
    
    if ([URL hasPrefix:@"/"]) {
        return [NSString stringWithFormat:@"https:/%@",URL];
    }
    
    return URL;
}

- (NSArray *)h5historicalRecord {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:@"h5historicalRecord"] ?: @[];
}

- (void)saveH5historicalRecordWithText:(NSString *)text {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *array = [self h5historicalRecord].mutableCopy;
    for (NSString *string in array) {
        if ([string isEqualToString:text]) {
            return;
        }
    }
    [array addObject:text];
    [userDefaults setObject:array forKey:@"h5historicalRecord"];
    [userDefaults synchronize];
}

- (void)clearH5historicalRecordWithText:(NSString *)text {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *array = [self h5historicalRecord].mutableCopy;
    for (NSString *string in array) {
        if ([string isEqualToString:text]) {
            [array removeObject:string];
            break;
        }
    }
    
    [userDefaults setObject:array forKey:@"h5historicalRecord"];
    [userDefaults synchronize];
}

- (void)clearAllH5historicalRecord {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:@"h5historicalRecord"];
    [userDefaults synchronize];
}

#pragma mark - Action

- (IBAction)scanAction:(UIButton *)sender {
    [self.view endEditing:YES];
    
    GIOScanViewController *controller = [[GIOScanViewController alloc] init];
    __weak typeof(self) weakSelf = self;
    controller.resultBlock = ^(NSString * _Nonnull string) {
        if (!string || string.length == 0) {
            return;
        }

        __strong typeof(weakSelf) self = weakSelf;
        self.h5UrlTextView.text = string;
        [self jump];
    };
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)jumpAction:(UIButton *)sender {
    [self.view endEditing:YES];
    [self jump];
}

- (IBAction)clearHistoryRecordAction:(UIButton *)sender {
    [self.view endEditing:YES];
    [self clearAllH5historicalRecord];
    self.dataSource = [self h5historicalRecord];
    [self.tableView reloadData];
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }

    return YES;
}

#pragma mark - UITableView Datasource & Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = self.dataSource[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.h5UrlTextView.text = self.dataSource[indexPath.row];
    [self jump];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self clearH5historicalRecordWithText:self.dataSource[indexPath.row]];
    self.dataSource = [self h5historicalRecord];
    [self.tableView reloadData];
}

@end
