//
//  GIOAttributesTrackViewController.m
//  GrowingExample
//
//  Created by GrowingIO on 2020/6/10.
//  Copyright © 2020 GrowingIO. All rights reserved.
//

#import "GIOAttributesTrackViewController.h"
#import "GIOConstants.h"
#import "GIODataProcessOperation.h"
#import "GIOKeyValueCell.h"

@interface GIOAttributesTrackViewController () <UITableViewDelegate, UITableViewDataSource, GIOKeyValueCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIButton *footerButton;
@property (nonatomic, strong) NSMutableArray<NSDictionary *> *dataSource;
@property (nonatomic, assign) NSInteger attributesCount;

@end

@implementation GIOAttributesTrackViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.attributesCount = [GIODataProcessOperation getRandomLengthFrom:1 to:5];

    [self setupTableView];

    self.navigationItem.title = [NSString stringWithFormat:@"%@事件", self.eventType];
}

- (void)setupTableView {
    [self.tableView registerNib:[UINib nibWithNibName:@"GIOKeyValueCell" bundle:nil]
         forCellReuseIdentifier:@"GIOKeyValueCell"];
    self.tableView.rowHeight = 50;
    self.tableView.tableFooterView = self.footerButton;
}

#pragma mark UITableViewDelegate, UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GIOKeyValueCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GIOKeyValueCell"
                                                                forIndexPath:indexPath];
    cell.delegate = self;
    [cell configContentDict:self.dataSource[indexPath.row]];

    return cell;
}

- (void)tableView:(UITableView *)tableView
    commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
     forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.dataSource removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationLeft];
    }
}

- (NSString *)tableView:(UITableView *)tableView
    titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

#pragma mark GIOKeyValueCellDelegate

- (void)GIOKeyValueCell:(GIOKeyValueCell *)keyValueCell contentDidChanged:(NSDictionary *)newContentDict {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:keyValueCell];
    [self.dataSource replaceObjectAtIndex:indexPath.row withObject:newContentDict];
}

#pragma mark Target Action

- (IBAction)trackBtnClick:(UIButton *)sender {
    NSMutableDictionary *atts = [NSMutableDictionary dictionary];

    for (NSDictionary *d in self.dataSource) {
        [atts addEntriesFromDictionary:d];
    }

    [self trackEventWithAttributes:atts];
}

- (IBAction)outRangeBtnClick:(UIButton *)sender {
    NSDictionary *largeAtts = [GIOConstants getLargeDictionary];
    [self trackEventWithAttributes:largeAtts];
}

- (IBAction)tapGestureHandle:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}

- (void)trackEventWithAttributes:(NSDictionary *)atts {
    if ([self.eventType isEqualToString:@"LOGIN_USER_ATTRIBUTES"]) {
#if defined(SDK3rd)
        [[GrowingSDK sharedInstance] setLoginUserAttributes:atts];
        
        GrowingAttributesBuilder *builder = GrowingAttributesBuilder.new;
        [builder setString:@"value" forKey:@"key"];
        [builder setArray:@[@"value1", @"value2", @"value3"] forKey:@"key2"];
        [builder setString:@"LOGIN_USER_ATTRIBUTES" forKey:@"type"];
        [GrowingSDK.sharedInstance setLoginUserAttributes:builder.build];
#endif
        
    } else if ([self.eventType isEqualToString:@"CONVERSION_VARIABLES"]) {
//#if defined(SDK3rd)
//        [[GrowingSDK sharedInstance] setConversionVariables:atts];
//
//        GrowingAttributesBuilder *builder = GrowingAttributesBuilder.new;
//        [builder setString:@"value" forKey:@"key"];
//        [builder setArray:@[@"value1", @"value2", @"value3"] forKey:@"key2"];
//        [builder setString:@"CONVERSION_VARIABLES" forKey:@"type"];
//        [GrowingSDK.sharedInstance setConversionVariables:builder.build];
//#endif
    } else if ([self.eventType isEqualToString:@"VISITOR_ATTRIBUTES"]) {
//#if defined(SDK3rd)
//        [[GrowingSDK sharedInstance] setVisitorAttributes:atts];
//
//        GrowingAttributesBuilder *builder = GrowingAttributesBuilder.new;
//        [builder setString:@"value" forKey:@"key"];
//        [builder setArray:@[@"value1", @"value2", @"value3"] forKey:@"key2"];
//        [builder setString:@"VISITOR_ATTRIBUTES" forKey:@"type"];
//        [GrowingSDK.sharedInstance setVisitorAttributes:builder.build];
//#endif
    }

    NSLog(@"track %@ 事件，attributes:%@", self.eventType, atts);
}

- (void)footerAddButtonClick:(UIButton *)sender {
    [self.dataSource addObject:@{[self randomKey] : [self randomValue]}];
    [self.tableView reloadData];
}

#pragma mark Lazy Load

- (NSMutableArray<NSDictionary *> *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];

        for (NSInteger i = 0; i < self.attributesCount; i++) {
            [_dataSource addObject:@{[self randomKey] : [self randomValue]}];
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

- (NSString *)randomKey {
    int l = [GIODataProcessOperation getRandomLengthFrom:5 to:20];
    return [NSString stringWithFormat:@"k_%@", [GIODataProcessOperation randomStringWithLength:l]];
}

- (NSString *)randomValue {
    int l = [GIODataProcessOperation getRandomLengthFrom:5 to:30];
    return [NSString stringWithFormat:@"v_%@", [GIODataProcessOperation randomStringWithLength:l]];
}

@end
