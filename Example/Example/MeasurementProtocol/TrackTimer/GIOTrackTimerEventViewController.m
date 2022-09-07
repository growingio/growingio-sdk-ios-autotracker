//
//  GIOTrackTimerEventViewController.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2022/9/6.
//  Copyright (C) 2022 Beijing Yishu Technology Co., Ltd.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import "GIOTrackTimerEventViewController.h"
#import "GIOConstants.h"
#import "GIODataProcessOperation.h"
#import "GIOKeyValueCell.h"
#import "GIOTrackTimerTableViewCell.h"

#define DEFAULT_ATTRIBUTES_COUNT 0

@interface GIOTrackTimerEventViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITextField *eventNameTextField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITableView *timersTableView;
@property (nonatomic, strong) NSMutableArray<NSDictionary *> *dataSource;
@property (nonatomic, strong) NSMutableArray<NSString *> *timers;
@property (nonatomic, strong) UIButton *footerButton;

@end

@implementation GIOTrackTimerEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.eventNameTextField.accessibilityLabel = @"CstmEid";
    self.eventNameTextField.text = [self randomEventName];
        
    [self setupTableView];
}

- (void)setupTableView {
    [self.tableView registerNib:[UINib nibWithNibName:@"GIOKeyValueCell" bundle:nil]
         forCellReuseIdentifier:@"GIOKeyValueCell"];
    self.tableView.rowHeight = 50;
    self.tableView.tableFooterView = self.footerButton;
}

- (IBAction)trackTimerStart:(id)sender {
    NSString *eventName = self.eventNameTextField.text;
    NSString *timerId = [[GrowingSDK sharedInstance] trackTimerStart:eventName];
    
    if (timerId.length > 0) {
        [self.timers addObject:timerId];
        [self.timersTableView reloadData];
    }
}

- (IBAction)clearAllTimers:(id)sender {
    [[GrowingSDK sharedInstance] clearTrackTimer];
    
    [self.timers removeAllObjects];
    [self.timersTableView reloadData];
}

- (void)timerPause:(NSString *)timerId {
    [[GrowingSDK sharedInstance] trackTimerPause:timerId];
}

- (void)timerResume:(NSString *)timerId {
    [[GrowingSDK sharedInstance] trackTimerResume:timerId];
}

- (void)timerEnd:(NSString *)timerId {
    NSMutableDictionary *atts = [NSMutableDictionary dictionary];
    for (NSDictionary *d in self.dataSource) {
        [atts addEntriesFromDictionary:d];
    }
    
    if (atts.count > 0) {
        [[GrowingSDK sharedInstance] trackTimerEnd:timerId withAttributes:atts];
    } else {
        [[GrowingSDK sharedInstance] trackTimerEnd:timerId];
    }
    
    for (NSString *timer in self.timers) {
        if ([timer isEqualToString:timerId]) {
            [self.timers removeObject:timer];
            break;
        }
    }
    [self.timersTableView reloadData];
}

- (IBAction)tapGestureHandle:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}

- (void)footerAddButtonClick:(UIButton *)sender {
    [self.dataSource addObject:@{[self randomKey]: [self randomValue]}];
    [self.tableView reloadData];
}

#pragma mark UITableViewDelegate, UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        return self.dataSource.count;
    } else {
        return self.timers.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.tableView) {
        GIOKeyValueCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GIOKeyValueCell" forIndexPath:indexPath];
        [cell configContentDict:self.dataSource[indexPath.row]];
        return cell;
    } else {
        GIOTrackTimerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GIOTrackTimerTableViewCell" forIndexPath:indexPath];
        NSString *timerId = [self.timers objectAtIndex:indexPath.row];
        cell.label.text = timerId;
        __weak typeof(self) weakSelf = self;
        cell.pauseBlock = ^(NSString * _Nonnull timerId) {
            __strong typeof(weakSelf) self = weakSelf;
            [self timerPause:timerId];
        };
        cell.resumeBlock = ^(NSString * _Nonnull timerId) {
            __strong typeof(weakSelf) self = weakSelf;
            [self timerResume:timerId];
        };
        cell.endBlock = ^(NSString * _Nonnull timerId) {
            __strong typeof(weakSelf) self = weakSelf;
            [self timerEnd:timerId];
        };
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (tableView == self.tableView) {
            [self.dataSource removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        } else {
            NSString *timerId = [self.timers objectAtIndex:indexPath.row];
            [[GrowingSDK sharedInstance] removeTimer:timerId];
            [self.timers removeObject:timerId];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

#pragma mark Lazy Load

- (NSMutableArray<NSDictionary *> *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
        
        for (NSInteger i = 0; i < DEFAULT_ATTRIBUTES_COUNT; i++) {
            [_dataSource addObject:@{[self randomKey]: [self randomValue]}];
        }
    }
    return _dataSource;
}

- (NSMutableArray<NSString *> *)timers {
    if (!_timers) {
        _timers = [NSMutableArray array];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        Class class = NSClassFromString(@"GrowingEventTimer");
        SEL selector = NSSelectorFromString(@"timers");
        if (class && [class respondsToSelector:selector]) {
            NSMutableDictionary *timers = [class performSelector:selector];
            for (NSString *timerId in timers.allKeys) {
                [_timers addObject:timerId];
            }
        }
#pragma clang diagnostic pop
    }
    return _timers;
}

- (UIButton *)footerButton {
    if (!_footerButton) {
        _footerButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
        _footerButton.frame = CGRectMake(0, 0, 40, 40);
        [_footerButton addTarget:self
                          action:@selector(footerAddButtonClick:)
                forControlEvents:UIControlEventTouchUpInside];
    }
    return _footerButton;
}

- (NSString *)randomEventName {
    int l = [GIODataProcessOperation getRandomLengthFrom:5 to:15];
    return [NSString stringWithFormat:@"n_%@", [GIODataProcessOperation randomStringWithLength:l]];
}

- (NSString *)randomKey {
    int l = [GIODataProcessOperation getRandomLengthFrom:5 to:15];
    return [NSString stringWithFormat:@"k_%@", [GIODataProcessOperation randomStringWithLength:l]];
}

- (NSString *)randomValue {
    int l = [GIODataProcessOperation getRandomLengthFrom:5 to:15];
    return [NSString stringWithFormat:@"v_%@", [GIODataProcessOperation randomStringWithLength:l]];
}

@end
