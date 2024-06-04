//
//  GIOCstmEventViewController.m
//  GrowingExample
//
//  Created by GrowingIO on 2018/6/1.
//  Copyright (C) 2018 Beijing Yishu Technology Co., Ltd.
//

#import "GIOCustomEventViewController.h"
#import "GIOConstants.h"
#import "GIODataProcessOperation.h"
#import "GIOKeyValueCell.h"
#import "GIODataProcessOperation.h"

@interface CustomPropertyPlugin1 : NSObject <GrowingPropertyPlugin>

@end

@implementation CustomPropertyPlugin1

- (NSDictionary<NSString *,id> *)attributes:(NSDictionary<NSString *,id> *)attributes { 
    NSMutableDictionary *attributesM = [NSMutableDictionary dictionaryWithDictionary:attributes];
    [attributesM setObject:@"1111" forKey:@"pluginKey"];
    return attributesM.copy;
}

- (BOOL)isMatchedWithFilter:(id<GrowingPropertyPluginEventFilter>)filter { 
    // 不处理eventName为impossible的CUSTOM事件
    if ([filter.name isEqualToString:@"impossible"]) {
        return NO;
    }
    // 不处理VISIT事件
    if ([filter.type isEqualToString:@"VISIT"]) {
        return NO;
    }
    // 不处理2月29日触发的事件
    if ([self isLeapDay:filter.time]) {
        return NO;
    }
    // 不处理来自hybrid的事件
    if (filter.isFromHybrid) {
        return NO;
    }
    return YES;
}

- (NSUInteger)priority { 
    return 1;
}

- (BOOL)isLeapDay:(NSTimeInterval)timestamp {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth fromDate:date];
    return (components.month == 2 && components.day == 29);
}

@end

@interface CustomPropertyPlugin2 : NSObject <GrowingPropertyPlugin>

@end

@implementation CustomPropertyPlugin2

- (NSDictionary<NSString *,id> *)attributes:(NSDictionary<NSString *,id> *)attributes {
    NSMutableDictionary *attributesM = [NSMutableDictionary dictionaryWithDictionary:attributes];
    [attributesM setObject:@"2222" forKey:@"pluginKey"];
    return attributesM.copy;
}

- (BOOL)isMatchedWithFilter:(id<GrowingPropertyPluginEventFilter>)filter {
    return YES;
}

- (NSUInteger)priority {
    return 2;
}

@end

#define DEFAULT_ATTRIBUTES_COUNT 0

@interface GIOCustomEventViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITextField *eventNameTextField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray <NSDictionary *> *dataSource;
@property (nonatomic, strong) UIButton *footerButton;

@end

@implementation GIOCustomEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.eventNameTextField.accessibilityLabel = @"CstmEid";
    self.eventNameTextField.text = [self randomEventName];
        
    [self setupTableView];
    
    [GrowingAutotracker setPropertyPlugins:[CustomPropertyPlugin1 new]];
    [GrowingAutotracker setPropertyPlugins:[CustomPropertyPlugin2 new]];
}

- (void)setupTableView {
    [self.tableView registerNib:[UINib nibWithNibName:@"GIOKeyValueCell" bundle:nil]
         forCellReuseIdentifier:@"GIOKeyValueCell"];
    self.tableView.rowHeight = 50;
    self.tableView.tableFooterView = self.footerButton;
}

//发送track请求，测试eventId
- (IBAction)trackCustomEvent:(id)sender {
    NSString *eventName = self.eventNameTextField.text;
    
    NSMutableDictionary *atts = [NSMutableDictionary dictionary];
    
    for (NSDictionary *d in self.dataSource) {
        [atts addEntriesFromDictionary:d];
    }
    
    if (atts.count > 0) {

        [[GrowingSDK sharedInstance] trackCustomEvent:eventName withAttributes:atts];
        NSLog(@"Track事件，eventName:%@, attributes:%@", eventName, atts);

    } else {
        [[GrowingSDK sharedInstance] trackCustomEvent:eventName];
        NSLog(@"Track事件，eventName:%@", eventName);
    }
}

//发送track请求，测试event长度越界
- (IBAction)eventNameOutRange:(id)sender {
    NSString *check = [GIOConstants getMyInput];
    [[GrowingSDK sharedInstance] trackCustomEvent:check];
    NSLog(@"Track eventName超界，数据长度为：%ld",[check length]);
}

//检查withVariable超过100个字典的情况
- (IBAction)eventAttributesOutRange:(id)sender {
    NSString *eid = self.eventNameTextField.text;
    NSDictionary *tvar=[GIOConstants getLargeDictionary];
    NSLog(@"Large Dict length is :%ld",tvar.count);
    [[GrowingSDK sharedInstance] trackCustomEvent:eid withAttributes:tvar];
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
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    GIOKeyValueCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GIOKeyValueCell" forIndexPath:indexPath];
    [cell configContentDict:self.dataSource[indexPath.row]];

    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.dataSource removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
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
    int l = [GIODataProcessOperation getRandomLengthFrom:5 to:50];
    return [NSString stringWithFormat:@"n_%@", [GIODataProcessOperation randomStringWithLength:l]];
}

- (NSString *)randomKey {
    int l = [GIODataProcessOperation getRandomLengthFrom:5 to:20];
    return [NSString stringWithFormat:@"k_%@", [GIODataProcessOperation randomStringWithLength:l]];
}

- (NSString *)randomValue {
    int l = [GIODataProcessOperation getRandomLengthFrom:5 to:30];
    return [NSString stringWithFormat:@"v_%@", [GIODataProcessOperation randomStringWithLength:l]];
}

@end
