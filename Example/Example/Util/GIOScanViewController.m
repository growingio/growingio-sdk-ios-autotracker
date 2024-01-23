//
//  GIOScanViewController.m
//  GrowingIOTest
//
//  Created by YoloMao on 2021/7/22.
//  Copyright © 2021 GrowingIO. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "GIOScanViewController.h"
#import "UIColor+Hex.h"

@interface GIOScanViewController () <AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

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
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

#pragma mark - Private

- (void)configBaseUI {
    self.title = @"扫一扫";
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
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] 
                                               options:@{}
                                     completionHandler:^(BOOL success) {
                
            }];
        }]];
        [self presentViewController:controller animated:YES completion:nil];
        return;
    }
    
    [self setupQRCodeDetector];
}

- (void)configNavigationItem {
    CGFloat statusBarHeight = 44.0f;
    if (@available(iOS 11.0, *)) {
        statusBarHeight = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0.0 ? 44.0f : 20.0f;
    }
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, statusBarHeight, 60, 50);
    [button setImage:[UIImage imageNamed:@"icon_back_white"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    self.backButton = button;
}

- (void)setupQRCodeDetector {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    self.session = [[AVCaptureSession alloc] init];
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    [self.session addInput:input];
    [self.session addOutput:output];
    output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.previewLayer.frame = self.view.layer.bounds;
    [self.view.layer insertSublayer:self.previewLayer atIndex:0];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self.session startRunning];
    });
}

- (void)showToast:(NSString *)toast shouldRestart:(BOOL)shouldRestart {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:toast message:@"" preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;
    [controller addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        __strong typeof(weakSelf) self = weakSelf;
        if (shouldRestart) {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.session startRunning];
            });
        }
    }]];
    [self presentViewController:controller animated:YES completion:nil];
}

- (BOOL)getCameraAvailable {
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
        return NO;
    }
    return YES;
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (metadataObjects.count == 0) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self.session stopRunning];
    });
    AVMetadataMachineReadableCodeObject *metadata = metadataObjects[0];
    NSString *str = metadata.stringValue;
    NSLog(@"扫一扫结果:\n%@", str);
    if (!str || str.length == 0) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self.session startRunning];
        });
        return;
    }
    if (str) {
        [self.navigationController popViewControllerAnimated:NO];

        if (self.resultBlock) {
            self.resultBlock(str);
        }
    } else {
        [self showToast:@"无法识别二维码" shouldRestart:YES];
    }
}

#pragma mark - Action

- (void)backAction {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self.session stopRunning];
    });
    [self.navigationController popViewControllerAnimated:YES];
}

@end
