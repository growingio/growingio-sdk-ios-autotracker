//
//  GIOScanViewController.m
//  GrowingIOTest
//
//  Created by YoloMao on 2021/7/22.
//  Copyright © 2021 GrowingIO. All rights reserved.
//

#import "GIOScanViewController.h"
#import "UIColor+Hex.h"
#import <AVFoundation/AVCaptureDevice.h>

#define is_iPhoneX \
({BOOL isPhoneX = NO;\
if (@available(iOS 11.0, *)) {\
isPhoneX = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0.0;\
}\
(isPhoneX);})

#define StatusBarHeight     (is_iPhoneX ? 44.f : 20.f)

@interface GIOScanViewController ()

@property (nonatomic, assign) BOOL isScanning;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UILabel *tipLabel;

@end

@implementation GIOScanViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configBaseUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.view bringSubviewToFront:self.backButton];

    if (!self.tipLabel) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 300 / 2,
                                                                   self.view.frame.size.height / 2 + self.view.frame.size.width / 2 - self.style.xScanRetangleOffset - self.style.centerUpOffset + 13,
                                                                   300,
                                                                   16)];
        label.text = @"将二维码放入框内，即可自动扫描";
        label.font = [UIFont systemFontOfSize:14];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor colorForHex:@"AFAFAF"];
        [self.view addSubview:label];
        self.tipLabel = label;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.isScanning = NO;
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

#pragma mark - Private

- (void)configBaseUI {
    self.title = @"扫一扫";
    self.style = [self gioStyle];
    [self configNavigationItem];

    if (![self getCameraAvailable]) {
        NSString *title = @"相机权限未开启";
        NSString *msg = @"请在系统设置中开启该应用相机服务\n(设置->隐私->相机->开启)";
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
        __weak typeof(self) weakSelf = self;
        [controller addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            __strong typeof(weakSelf) self = weakSelf;
            [self.navigationController popViewControllerAnimated:YES];
        }]];
        [controller addAction:[UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }]];
        [self presentViewController:controller animated:YES completion:nil];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationBecomeActive) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)configNavigationItem {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, StatusBarHeight, 60, 50);
    [button setImage:[UIImage imageNamed:@"icon_back_white"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    self.backButton = button;
}

- (void)showNextVCWithScanResult:(LBXScanResult *)scanResult {
    NSLog(@"扫一扫结果:\n%@", scanResult.strScanned);
    
    NSString *str = scanResult.strScanned;
    self.scanImage = scanResult.imgScanned;
    if (!str || str.length == 0) {
        [self reStartDevice];
        return;
    }
    if (str) {
        [self.navigationController popViewControllerAnimated:NO];

        if (self.resultBlock) {
            self.resultBlock(str);
        }
    }else {
        [self showToast:@"无法识别二维码" shouldRestart:YES];
    }
}

- (void)showToast:(NSString *)toast shouldRestart:(BOOL)shouldRestart {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:toast message:@"" preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;
    [controller addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        __strong typeof(weakSelf) self = weakSelf;
        if (shouldRestart) {
            [self reStartDevice];
        }
    }]];
    [self presentViewController:controller animated:YES completion:nil];
}

- (LBXScanViewStyle *)gioStyle {
    LBXScanViewStyle *style = [[LBXScanViewStyle alloc] init];

    //扫码框中心位置与View中心位置上移偏移像素(一般扫码框在视图中心位置上方一点)
    style.centerUpOffset = 44;

    //扫码框周围4个角的类型设置为在框的上面,可自行修改查看效果
    style.photoframeAngleStyle = LBXScanViewPhotoframeAngleStyle_Outer;

    //扫码框周围4个角绘制线段宽度
    style.photoframeLineW = 5;

    //扫码框周围4个角水平长度
    style.photoframeAngleW = 33;

    //扫码框周围4个角垂直高度
    style.photoframeAngleH = 33;

    //动画类型：网格形式，模仿支付宝
    style.anmiationStyle = LBXScanViewAnimationStyle_NetGrid;

    //动画图片:网格图片
    style.animationImage = [UIImage imageNamed:@"CodeScan.bundle/qrcode_scan_full_net.png"];

    //扫码框周围4个角的颜色
    style.colorAngle = [UIColor colorForHex:@"4877EF"];

    //是否显示扫码框
    style.isNeedShowRetangle = YES;

    //扫码框颜色
    style.colorRetangleLine = [UIColor colorForHex:@"4877EF"];

    //非扫码框区域颜色(扫码框周围颜色，一般颜色略暗)
    //必须通过[UIColor colorWithRed: green: blue: alpha:]来创建，内部需要解析成RGBA
    style.notRecoginitonArea = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];

    return style;
}

- (BOOL)getCameraAvailable {
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
        return NO;
    }
    return YES;
}

#pragma mark - Action

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - NSNotification

- (void)applicationBecomeActive {
    if (self.isScanning) {
        [self.qRScanView startScanAnimation];
    }
}

#pragma mark - Override

- (void)scanResultWithArray:(NSArray<LBXScanResult *> *)array {
    if (array.count < 1) {
        [self reStartDevice];
        return;
    }
    
    LBXScanResult *scanResult = array[0];
    [self showNextVCWithScanResult:scanResult];
}

- (void)didStartScan {
    self.isScanning = YES;
}

@end
