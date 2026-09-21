//
//  GIOViewImpressionViewController.m
//  GrowingExample
//
//  Created by YoloMao on 2026/9/21.
//  Copyright © 2026 GrowingIO. All rights reserved.
//

#import "GIOViewImpressionViewController.h"

#if defined(SDKVIEWIMPMODULE)

static const CGFloat kCardHeight = 80.0;
static const CGFloat kLogPanelHeight = 150.0;
static const NSUInteger kLogCapacity = 10;
static const NSInteger kReuseRowCount = 30;
static const NSInteger kSubviewRowCount = 30;
static const NSInteger kBadgeTag = 9001;

static NSString *const kSlotA = @"slot_a";
static NSString *const kSlotB = @"slot_b";
static NSString *const kOnceIdentifier = @"once_element";
static NSString *const kUpdateIdentifier = @"update_element";

@interface GIOViewImpressionViewController () <GrowingViewImpressionDelegate,
                                               UITableViewDataSource,
                                               UITableViewDelegate>

@property (nonatomic, strong) UILabel *logLabel;
@property (nonatomic, strong) NSMutableArray<NSString *> *logs;
@property (nonatomic, strong) UISwitch *vetoSwitch;
@property (nonatomic, strong) UISwitch *dynamicSwitch;
@property (nonatomic, strong) UIStackView *contentStack;
@property (nonatomic, strong) UIView *multiSlotCard;
@property (nonatomic, strong) UIView *updateCard;
@property (nonatomic, assign) NSUInteger updateCount;

@end

@implementation GIOViewImpressionViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"ViewImpression";
    self.view.backgroundColor = UIColor.systemBackgroundColor;
    self.logs = [NSMutableArray array];

    [self setupLogPanel];
    [self setupContentScrollView];

    [self addBasicSection];
    [self addScaleSection];
    [self addStayDurationSection];
    [self addRepeatableSection];
    [self addMultiSlotSection];
    [self addUpdateAttributesSection];
    [self addClippedContainerSection];
    [self addReuseListSection];
    [self addReuseSubviewSection];
    [self addTailSpacer];

    [[GrowingViewImpression sharedInstance] addImpressionDelegate:self];
}

#pragma mark - 固定面板

- (void)setupLogPanel {
    UIView *panel = [[UIView alloc] init];
    panel.translatesAutoresizingMaskIntoConstraints = NO;
    panel.backgroundColor = [UIColor.systemGrayColor colorWithAlphaComponent:0.12];
    [self.view addSubview:panel];

    UIStackView *controls = [[UIStackView alloc] init];
    controls.axis = UILayoutConstraintAxisHorizontal;
    controls.alignment = UIStackViewAlignmentCenter;
    controls.spacing = 6;
    controls.translatesAutoresizingMaskIntoConstraints = NO;
    [panel addSubview:controls];

    self.vetoSwitch = [[UISwitch alloc] init];
    self.dynamicSwitch = [[UISwitch alloc] init];
    [controls addArrangedSubview:[self captionLabel:@"否决"]];
    [controls addArrangedSubview:self.vetoSwitch];
    [controls addArrangedSubview:[self captionLabel:@"动态属性"]];
    [controls addArrangedSubview:self.dynamicSwitch];
    [controls addArrangedSubview:[self smallButton:@"重置状态" action:@selector(resetAllState)]];
    [controls addArrangedSubview:[self smallButton:@"清空日志" action:@selector(clearLogs)]];

    self.logLabel = [[UILabel alloc] init];
    self.logLabel.numberOfLines = 0;
    self.logLabel.font = [UIFont monospacedDigitSystemFontOfSize:11 weight:UIFontWeightRegular];
    self.logLabel.textColor = UIColor.secondaryLabelColor;
    self.logLabel.text = @"曝光事件会显示在这里";
    self.logLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [panel addSubview:self.logLabel];

    UILayoutGuide *safeArea = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [panel.topAnchor constraintEqualToAnchor:safeArea.topAnchor],
        [panel.leadingAnchor constraintEqualToAnchor:safeArea.leadingAnchor],
        [panel.trailingAnchor constraintEqualToAnchor:safeArea.trailingAnchor],
        [panel.heightAnchor constraintEqualToConstant:kLogPanelHeight],

        [controls.topAnchor constraintEqualToAnchor:panel.topAnchor constant:6],
        [controls.leadingAnchor constraintEqualToAnchor:panel.leadingAnchor constant:12],

        [self.logLabel.topAnchor constraintEqualToAnchor:controls.bottomAnchor constant:6],
        [self.logLabel.leadingAnchor constraintEqualToAnchor:panel.leadingAnchor constant:12],
        [self.logLabel.trailingAnchor constraintEqualToAnchor:panel.trailingAnchor constant:-12],
        [self.logLabel.bottomAnchor constraintLessThanOrEqualToAnchor:panel.bottomAnchor constant:-6],
    ]];
}

- (void)setupContentScrollView {
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:scrollView];

    self.contentStack = [[UIStackView alloc] init];
    self.contentStack.axis = UILayoutConstraintAxisVertical;
    self.contentStack.spacing = 10;
    self.contentStack.layoutMarginsRelativeArrangement = YES;
    self.contentStack.layoutMargins = UIEdgeInsetsMake(12, 16, 12, 16);
    self.contentStack.translatesAutoresizingMaskIntoConstraints = NO;
    [scrollView addSubview:self.contentStack];

    UILayoutGuide *safeArea = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [scrollView.topAnchor constraintEqualToAnchor:safeArea.topAnchor constant:kLogPanelHeight],
        [scrollView.leadingAnchor constraintEqualToAnchor:safeArea.leadingAnchor],
        [scrollView.trailingAnchor constraintEqualToAnchor:safeArea.trailingAnchor],
        [scrollView.bottomAnchor constraintEqualToAnchor:safeArea.bottomAnchor],

        [self.contentStack.topAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.topAnchor],
        [self.contentStack.bottomAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.bottomAnchor],
        [self.contentStack.leadingAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.leadingAnchor],
        [self.contentStack.trailingAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.trailingAnchor],
        [self.contentStack.widthAnchor constraintEqualToAnchor:scrollView.frameLayoutGuide.widthAnchor],
    ]];
}

#pragma mark - 各项能力演示

- (void)addBasicSection {
    [self addSectionTitle:@"1. 基础标记" detail:@"默认配置，露出即曝光；滚出去再滚回来会再次曝光"];

    UIView *card = [self cardWithText:@"imp_basic" color:UIColor.systemBlueColor];
    [card growingMarkImpression:@"imp_basic" attributes:@{@"section": @"basic"}];
}

- (void)addScaleSection {
    [self addSectionTitle:@"2. 可见面积阈值" detail:@"scale=0.5 露一半即曝光；scale=1.0 需完整露出"];

    UIView *half = [self cardWithText:@"imp_scale_50  (scale = 0.5)" color:UIColor.systemTealColor];
    [half growingMarkImpression:@"imp_scale_50"
                     attributes:nil
                     identifier:@"scale_50"
                         config:[GrowingViewImpressionConfig configWithViewImpressionScale:0.5f
                                                                              stayDuration:0.0
                                                                                repeatable:YES]];

    UIView *full = [self cardWithText:@"imp_scale_100  (scale = 1.0)" color:UIColor.systemTealColor];
    [full growingMarkImpression:@"imp_scale_100"
                     attributes:nil
                     identifier:@"scale_100"
                         config:[GrowingViewImpressionConfig configWithViewImpressionScale:1.0f
                                                                              stayDuration:0.0
                                                                                repeatable:YES]];
}

- (void)addStayDurationSection {
    [self addSectionTitle:@"3. 停留时长" detail:@"连续可见满 2 秒才曝光，快速划过不计"];

    UIView *card = [self cardWithText:@"imp_stay_2s  (stayDuration = 2)" color:UIColor.systemIndigoColor];
    [card growingMarkImpression:@"imp_stay_2s"
                     attributes:nil
                     identifier:@"stay_2s"
                         config:[GrowingViewImpressionConfig configWithViewImpressionScale:0.0f
                                                                              stayDuration:2.0
                                                                                repeatable:YES]];
}

- (void)addRepeatableSection {
    [self addSectionTitle:@"4. 只曝光一次" detail:@"repeatable = NO，反复滚动也只发一次，点「重置状态」后可再发"];

    UIView *card = [self cardWithText:@"imp_once  (repeatable = NO)" color:UIColor.systemPurpleColor];
    [card growingMarkImpression:@"imp_once"
                     attributes:nil
                     identifier:kOnceIdentifier
                         config:[GrowingViewImpressionConfig configWithViewImpressionScale:0.0f
                                                                              stayDuration:0.0
                                                                                repeatable:NO]];
}

- (void)addMultiSlotSection {
    [self addSectionTitle:@"5. 单视图多槽位" detail:@"同一个视图挂两个 identifier，各自独立发送，可单独移除"];

    self.multiSlotCard = [self cardWithText:@"imp_slot_a + imp_slot_b" color:UIColor.systemOrangeColor];
    [self.multiSlotCard growingMarkImpression:@"imp_slot_a" attributes:nil identifier:kSlotA config:nil];
    [self.multiSlotCard growingMarkImpression:@"imp_slot_b" attributes:nil identifier:kSlotB config:nil];

    [self.contentStack addArrangedSubview:[self wideButton:@"移除 slot_a（slot_b 不受影响）"
                                                    action:@selector(removeSlotA)]];
}

- (void)addUpdateAttributesSection {
    [self addSectionTitle:@"6. 更新属性" detail:@"更新属性不会触发重新曝光；下次曝光时带上新属性"];

    self.updateCard = [self cardWithText:@"imp_update  (count = 0)" color:UIColor.systemGreenColor];
    [self.updateCard growingMarkImpression:@"imp_update"
                                attributes:@{@"count": @(0)}
                                identifier:kUpdateIdentifier
                                    config:nil];

    [self.contentStack addArrangedSubview:[self wideButton:@"更新属性（不应产生新曝光）"
                                                    action:@selector(updateAttributes)]];
}

- (void)addClippedContainerSection {
    [self addSectionTitle:@"7. 滚动容器裁剪" detail:@"横向滚动，只有真正露出容器的卡片才曝光"];

    UIScrollView *horizontal = [[UIScrollView alloc] init];
    horizontal.showsHorizontalScrollIndicator = NO;
    horizontal.translatesAutoresizingMaskIntoConstraints = NO;

    UIStackView *row = [[UIStackView alloc] init];
    row.axis = UILayoutConstraintAxisHorizontal;
    row.spacing = 10;
    row.translatesAutoresizingMaskIntoConstraints = NO;
    [horizontal addSubview:row];

    for (NSInteger i = 0; i < 8; i++) {
        UIView *card = [[UIView alloc] init];
        card.backgroundColor = [UIColor.systemPinkColor colorWithAlphaComponent:0.8];
        card.layer.cornerRadius = 8;
        card.translatesAutoresizingMaskIntoConstraints = NO;
        [card.widthAnchor constraintEqualToConstant:120].active = YES;
        [row addArrangedSubview:card];

        UILabel *label = [self cardLabel:[NSString stringWithFormat:@"横向 #%ld", (long)i]];
        [card addSubview:label];
        [NSLayoutConstraint activateConstraints:@[
            [label.centerXAnchor constraintEqualToAnchor:card.centerXAnchor],
            [label.centerYAnchor constraintEqualToAnchor:card.centerYAnchor],
        ]];

        [card growingMarkImpression:@"imp_horizontal"
                         attributes:@{@"index": @(i)}
                         identifier:[NSString stringWithFormat:@"horizontal_%ld", (long)i]
                             config:[GrowingViewImpressionConfig configWithViewImpressionScale:0.9f
                                                                                  stayDuration:0.0
                                                                                    repeatable:YES]];
    }

    [self.contentStack addArrangedSubview:horizontal];
    [NSLayoutConstraint activateConstraints:@[
        [horizontal.heightAnchor constraintEqualToConstant:kCardHeight],
        [row.topAnchor constraintEqualToAnchor:horizontal.contentLayoutGuide.topAnchor],
        [row.bottomAnchor constraintEqualToAnchor:horizontal.contentLayoutGuide.bottomAnchor],
        [row.leadingAnchor constraintEqualToAnchor:horizontal.contentLayoutGuide.leadingAnchor],
        [row.trailingAnchor constraintEqualToAnchor:horizontal.contentLayoutGuide.trailingAnchor],
        [row.heightAnchor constraintEqualToAnchor:horizontal.frameLayoutGuide.heightAnchor],
    ]];
}

- (void)addReuseListSection {
    [self addSectionTitle:@"8. 列表复用" detail:@"30 行，identifier 为行号、repeatable = NO，复用不串号且每行只发一次"];

    UITableView *tableView = [[UITableView alloc] init];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.rowHeight = 56;
    tableView.layer.cornerRadius = 8;
    tableView.layer.borderWidth = 1;
    tableView.layer.borderColor = UIColor.separatorColor.CGColor;
    tableView.clipsToBounds = YES;
    tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"ReuseCell"];

    [self.contentStack addArrangedSubview:tableView];
    [tableView.heightAnchor constraintEqualToConstant:280].active = YES;
}

- (void)addReuseSubviewSection {
    [self addSectionTitle:@"9. 复用 cell 的子视图"
                   detail:
                       @"标记的是 cell 里的角标而非 cell 本身，identifier 随行内容变化；"
                        "复用后角标只发当前行的曝光，不会带着上一行的属性重复发"];

    UITableView *tableView = [[UITableView alloc] init];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.tag = 1;
    tableView.rowHeight = 56;
    tableView.layer.cornerRadius = 8;
    tableView.layer.borderWidth = 1;
    tableView.layer.borderColor = UIColor.separatorColor.CGColor;
    tableView.clipsToBounds = YES;
    tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"SubviewCell"];

    [self.contentStack addArrangedSubview:tableView];
    [tableView.heightAnchor constraintEqualToConstant:280].active = YES;
}

- (void)addTailSpacer {
    UILabel *hint = [[UILabel alloc] init];
    hint.text = @"↓ 下方留白用于把上面的元素滚出可视区，再滚回来观察重新曝光";
    hint.font = [UIFont systemFontOfSize:12];
    hint.textColor = UIColor.tertiaryLabelColor;
    hint.numberOfLines = 0;
    [self.contentStack addArrangedSubview:hint];

    UIView *spacer = [[UIView alloc] init];
    spacer.translatesAutoresizingMaskIntoConstraints = NO;
    [spacer.heightAnchor constraintEqualToConstant:500].active = YES;
    [self.contentStack addArrangedSubview:spacer];
}

#pragma mark - 交互

- (void)removeSlotA {
    [self.multiSlotCard growingUnmarkImpressionWithIdentifier:kSlotA];
    [self appendLog:@"已移除 slot_a"];
}

- (void)updateAttributes {
    self.updateCount += 1;
    [self.updateCard growingUpdateImpressionAttributes:@{@"count": @(self.updateCount)} identifier:kUpdateIdentifier];

    UILabel *label = self.updateCard.subviews.firstObject;
    label.text = [NSString stringWithFormat:@"imp_update  (count = %lu)", (unsigned long)self.updateCount];
    [self appendLog:[NSString stringWithFormat:@"已更新属性 count = %lu", (unsigned long)self.updateCount]];
}

- (void)resetAllState {
    [GrowingViewImpression resetAllImpressionState];
    [self appendLog:@"已重置全部曝光状态"];
}

- (void)clearLogs {
    [self.logs removeAllObjects];
    self.logLabel.text = @"曝光事件会显示在这里";
}

#pragma mark - GrowingViewImpressionDelegate

- (BOOL)growingImpressionShouldTrack:(UIView *)view eventName:(NSString *)eventName identifier:(NSString *)identifier {
    if (self.vetoSwitch.isOn) {
        [self appendLog:[NSString stringWithFormat:@"✕ 否决 %@", eventName]];
        return NO;
    }
    return YES;
}

- (NSDictionary<NSString *, id> *)growingImpressionDynamicAttributes:(UIView *)view
                                                           eventName:(NSString *)eventName
                                                          identifier:(NSString *)identifier {
    if (!self.dynamicSwitch.isOn) {
        return nil;
    }
    return @{@"dynamic_timestamp": @((long long)([NSDate date].timeIntervalSince1970 * 1000))};
}

- (void)growingImpressionDidTrack:(UIView *)view eventName:(NSString *)eventName identifier:(NSString *)identifier {
    NSString *suffix = identifier.length > 0 ? [NSString stringWithFormat:@" [%@]", identifier] : @"";
    [self appendLog:[NSString stringWithFormat:@"✓ %@%@", eventName, suffix]];
}

#pragma mark - UITableViewDataSource / Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return tableView.tag == 1 ? kSubviewRowCount : kReuseRowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == 1) {
        return [self subviewCellForTableView:tableView indexPath:indexPath];
    }

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReuseCell" forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"列表第 %ld 行", (long)indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:14];

    [cell growingMarkImpression:@"imp_list_row"
                     attributes:@{@"row": @(indexPath.row)}
                     identifier:[NSString stringWithFormat:@"list_row_%ld", (long)indexPath.row]
                         config:[GrowingViewImpressionConfig configWithViewImpressionScale:0.8f
                                                                              stayDuration:0.0
                                                                                repeatable:NO]];
    return cell;
}

- (UITableViewCell *)subviewCellForTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SubviewCell" forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"商品 %ld", (long)indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:14];

    UILabel *badge = [cell.contentView viewWithTag:kBadgeTag];
    if (!badge) {
        badge = [[UILabel alloc] init];
        badge.tag = kBadgeTag;
        badge.textAlignment = NSTextAlignmentCenter;
        badge.textColor = UIColor.whiteColor;
        badge.font = [UIFont systemFontOfSize:11 weight:UIFontWeightMedium];
        badge.backgroundColor = UIColor.systemRedColor;
        badge.layer.cornerRadius = 4;
        badge.clipsToBounds = YES;
        badge.translatesAutoresizingMaskIntoConstraints = NO;
        [cell.contentView addSubview:badge];
        [NSLayoutConstraint activateConstraints:@[
            [badge.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:-16],
            [badge.centerYAnchor constraintEqualToAnchor:cell.contentView.centerYAnchor],
            [badge.widthAnchor constraintEqualToConstant:64],
            [badge.heightAnchor constraintEqualToConstant:22],
        ]];
    }
    badge.text = [NSString stringWithFormat:@"角标 %ld", (long)indexPath.row];

    // 标记的是被复用的角标视图本身，identifier 随行内容变化
    [badge growingMarkImpression:@"imp_badge"
                      attributes:@{@"goods_id": [NSString stringWithFormat:@"goods_%ld", (long)indexPath.row]}
                      identifier:[NSString stringWithFormat:@"badge_%ld", (long)indexPath.row]
                          config:nil];
    return cell;
}

#pragma mark - 视图构造辅助

- (void)addSectionTitle:(NSString *)title detail:(NSString *)detail {
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = title;
    titleLabel.font = [UIFont boldSystemFontOfSize:16];

    UILabel *detailLabel = [[UILabel alloc] init];
    detailLabel.text = detail;
    detailLabel.font = [UIFont systemFontOfSize:12];
    detailLabel.textColor = UIColor.secondaryLabelColor;
    detailLabel.numberOfLines = 0;

    [self.contentStack addArrangedSubview:titleLabel];
    [self.contentStack addArrangedSubview:detailLabel];
    [self.contentStack setCustomSpacing:2 afterView:titleLabel];
}

- (UIView *)cardWithText:(NSString *)text color:(UIColor *)color {
    UIView *card = [[UIView alloc] init];
    card.backgroundColor = [color colorWithAlphaComponent:0.8];
    card.layer.cornerRadius = 8;
    card.translatesAutoresizingMaskIntoConstraints = NO;

    UILabel *label = [self cardLabel:text];
    [card addSubview:label];

    [self.contentStack addArrangedSubview:card];
    [NSLayoutConstraint activateConstraints:@[
        [card.heightAnchor constraintEqualToConstant:kCardHeight],
        [label.centerXAnchor constraintEqualToAnchor:card.centerXAnchor],
        [label.centerYAnchor constraintEqualToAnchor:card.centerYAnchor],
    ]];
    return card;
}

- (UILabel *)cardLabel:(NSString *)text {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.textColor = UIColor.whiteColor;
    label.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    return label;
}

- (UILabel *)captionLabel:(NSString *)text {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.font = [UIFont systemFontOfSize:12];
    return label;
}

- (UIButton *)smallButton:(NSString *)title action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:12];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (UIButton *)wideButton:(NSString *)title action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:13];
    button.backgroundColor = [UIColor.systemGrayColor colorWithAlphaComponent:0.15];
    button.layer.cornerRadius = 6;
    button.translatesAutoresizingMaskIntoConstraints = NO;
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [button.heightAnchor constraintEqualToConstant:34].active = YES;
    return button;
}

- (void)appendLog:(NSString *)line {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HH:mm:ss.SSS";
    [self.logs insertObject:[NSString stringWithFormat:@"%@  %@", [formatter stringFromDate:[NSDate date]], line]
                    atIndex:0];
    while (self.logs.count > kLogCapacity) {
        [self.logs removeLastObject];
    }
    self.logLabel.text = [self.logs componentsJoinedByString:@"\n"];
}

@end

#else

@implementation GIOViewImpressionViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"ViewImpression";
    self.view.backgroundColor = UIColor.systemBackgroundColor;

    UILabel *label = [[UILabel alloc] init];
    label.text = @"未集成 GrowingAnalytics/ViewImpression";
    label.textColor = UIColor.secondaryLabelColor;
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:label];
    [NSLayoutConstraint activateConstraints:@[
        [label.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [label.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
    ]];
}

@end

#endif
