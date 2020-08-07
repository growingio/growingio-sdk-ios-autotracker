//
//  GIOSimpleUIElemtsViewController.m
//  GrowingIOTest
//
//  Created by GIO-baitianyu on 23/03/2018.
//  Copyright © 2018 GrowingIO. All rights reserved.
//

#import "GIOSimpleUIElemtsViewController.h"
#import <GrowingAutoTracker.h>

const NSUInteger kProgressViewControllerMaxProgress = 100;

@interface GIOSimpleUIElemtsViewController ()<UISearchBarDelegate>
@property (nonatomic, weak) IBOutlet UISegmentedControl *defaultSegmentedControl;
@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, weak) IBOutlet UISwitch *defaultSwitch;
@property (nonatomic, weak) IBOutlet UIStepper *defaultStepper;
@property (nonatomic, weak) IBOutlet UISlider *defaultSlider;
@property (nonatomic, weak) IBOutlet UIProgressView *defaultStyleProgressView;
@property (nonatomic, weak) IBOutlet UIToolbar *toolbar;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *grayStyleActivityIndicatorView;

@property (nonatomic) NSOperationQueue *operationQueue;
@property (nonatomic) NSUInteger completedProgress;

@property (nonatomic, weak) IBOutlet UIButton *btn2;
@property (nonatomic, weak) IBOutlet UIButton *btn4;
@property (nonatomic, weak) IBOutlet UIButton *btn5;

@end

@implementation GIOSimpleUIElemtsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureRightNavButtonItem];
    [self configureSearchBar];
    [self configureDefaultSwitch];
    [self configureDefaultStepper];
    [self configureDefaultSegmentedControl];
    [self configureDefaultSlider];
    [self configureToolbar];
    [self configureGrayActivityIndicatorView];
    
    [self configureDefaultStyleProgressView];
    [self simulateProgress];
    
    //添加特殊的按钮
    _btn2 = [[UIButton alloc] initWithFrame:CGRectMake(50,500,50,30)];
    [_btn2 addTarget:self action:@selector(ontap) forControlEvents:UIControlEventTouchUpInside];
    _btn2.backgroundColor = [UIColor blueColor];
    [self.view addSubview:_btn2];
    
    _btn4 = [[UIButton alloc] initWithFrame:CGRectMake(130, 500, 50,50)];
    [_btn4 addTarget:self action:@selector(ontap) forControlEvents:UIControlEventTouchUpInside];
    //NSBundle *bundle = [NSBundle mainBundle];
    //NSString *resourcePath = [bundle resourcePath];
    //NSString *filePath = [resourcePath stringByAppendingPathComponent:@"/resource/icon_email@3x.png"];
    //UIImage *image = [UIImage imageWithContentsOfFile:filePath];
    UIImage *image=[UIImage imageNamed:@"bugs.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.accessibilityLabel = @"邮件";
    [_btn4 addSubview:imageView];
    [self.view addSubview:_btn4];
    
    UIView *viewContainer = [[UIView alloc] initWithFrame:CGRectMake(200, 500, 50, 50)];
    UIImage *image1=[UIImage imageNamed:@"fire.ico"];
    UIImageView *imageView2 = [[UIImageView alloc] initWithImage:image1];
    imageView2.accessibilityLabel = @"邮件容器";
    [viewContainer addSubview:imageView2];
    _btn5 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [_btn5 addTarget:self action:@selector(ontap) forControlEvents:UIControlEventTouchUpInside];
    [viewContainer addSubview:_btn5];
    [self.view addSubview:viewContainer];
    
}

-(void)ontap
{

    UIWindow * window=[[[UIApplication sharedApplication] delegate] window];
    
    CGRect startRact = [_btn5 convertRect:_btn5.bounds toView:window];
    
    NSLog(@"Btn5 x=%f,y=%f",startRact.origin.x,startRact.origin.y);
    
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Hello"
                                                                   message:@"你好,今天的天气真不错？"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"好的"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
                                            }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)configureRightNavButtonItem {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 40, 40);
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"scanqr"]];
    imageView.layoutMargins = UIEdgeInsetsMake(2, 2, 2, 2);
    imageView.contentMode = UIViewContentModeScaleToFill;
    imageView.frame = CGRectMake(0, 0, 30, 30);
    [button addSubview:imageView];
    
    UILabel *label = [[UILabel alloc] init];
    label.text = @"扫一扫";
    label.frame = CGRectMake(0, 30, 40, 10);
    label.font =  [UIFont systemFontOfSize:10];
    [button addSubview:label];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = rightItem;
    [button addTarget:self action:@selector(scanQR) forControlEvents:UIControlEventTouchUpInside];
    button.accessibilityLabel = @"ScanQRCode";
}

- (void)scanQR {
    NSLog(@"User click scan qrcode");
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UISearchBar Configuration

- (void)configureSearchBar {
    self.searchBar.showsCancelButton = YES;
    self.searchBar.showsBookmarkButton = YES;
    self.searchBar.accessibilityLabel=@"SearhBarTest";
    self.searchBar.tintColor = [UIColor colorWithRed:0.659 green:0.271 blue:0.988 alpha:1];
    
    self.searchBar.backgroundImage = [UIImage imageNamed:@"search_bar_background"];
    
    // Set the bookmark image for both normal and highlighted states.
    UIImage *bookmarkImage = [UIImage imageNamed:@"bookmark_icon"];
    [self.searchBar setImage:bookmarkImage forSearchBarIcon:UISearchBarIconBookmark state:UIControlStateNormal];
    
    UIImage *bookmarkHighlightedImage = [UIImage imageNamed:@"bookmark_icon_highlighted"];
    [self.searchBar setImage:bookmarkHighlightedImage forSearchBarIcon:UISearchBarIconBookmark state:UIControlStateHighlighted];
}


#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"The custom search bar keyboard search button was tapped: %@.", searchBar.text);
    
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"The custom search bar cancel button was tapped.");
    
    [searchBar resignFirstResponder];
}

- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"The custom bookmark button inside the search bar was tapped.");
}

#pragma mark - Switch Configuration

- (void)configureDefaultSwitch {
    [self.defaultSwitch setOn:YES animated:YES];
    
    [self.defaultSwitch addTarget:self action:@selector(switchValueDidChange:) forControlEvents:UIControlEventValueChanged];
}

#pragma mark - Switch Actions

- (void)switchValueDidChange:(UISwitch *)aSwitch {
    NSLog(@"A switch changed its value: %@.", aSwitch);
}


#pragma mark - Stepper Configuration

- (void)configureDefaultStepper {
    self.defaultStepper.value = 0;
    self.defaultStepper.minimumValue = 0;
    self.defaultStepper.maximumValue = 10;
    self.defaultStepper.stepValue = 1;
    [self.defaultStepper addTarget:self action:@selector(stepperValueDidChange:) forControlEvents:UIControlEventValueChanged];
}

#pragma mark - Stepper Actions

- (void)stepperValueDidChange:(UIStepper *)stepper {
    NSLog(@"A stepper changed its value: %@.", stepper);
}

#pragma mark - SegmentedControl Configuration

- (void)configureDefaultSegmentedControl {
    self.defaultSegmentedControl.tintColor = [UIColor colorWithRed:0.333 green:0.784 blue:1 alpha:1];

    [self.defaultSegmentedControl addTarget:self
                                     action:@selector(selectedSegmentDidChange:)
                           forControlEvents:UIControlEventValueChanged];
    
    self.defaultSegmentedControl.growingUniqueTag = @"defaultSegmentUniqueTag";
}

#pragma mark - SegmentedControl Actions

- (void)selectedSegmentDidChange:(UISegmentedControl *)segmentedControl {
    NSLog(@"The selected segment changed for: %@.", segmentedControl);
}

#pragma mark - Slider Configuration

- (void)configureDefaultSlider {
    self.defaultSlider.minimumValue = 0;
    self.defaultSlider.maximumValue = 100;
    self.defaultSlider.value = 42;
    self.defaultSlider.continuous = YES;
    
    [self.defaultSlider addTarget:self action:@selector(sliderValueDidChange:) forControlEvents:UIControlEventValueChanged];
}

#pragma mark - Slider Actions

- (void)sliderValueDidChange:(UISlider *)slider {
    NSLog(@"A slider changed its value: %@", slider);
}

#pragma mark - ProgressView Configuration

// Overrides the "completedProgress" property's setter.
- (void)setCompletedProgress:(NSUInteger)completedProgress {
    if (_completedProgress != completedProgress) {
        float fractionalProgress = (float)completedProgress / (float)kProgressViewControllerMaxProgress;
        
        [self.defaultStyleProgressView setProgress:fractionalProgress animated:YES];
        
        _completedProgress = completedProgress;
    }
}

- (void)configureDefaultStyleProgressView {
    self.defaultStyleProgressView.progressViewStyle = UIProgressViewStyleDefault;
}

#pragma mark - Progress Simulation

- (void)simulateProgress {
    // In this example we will simulate progress with a "sleep operation".
    self.operationQueue = [[NSOperationQueue alloc] init];
    
    for (NSUInteger count = 0; count < kProgressViewControllerMaxProgress; count++) {
        [self.operationQueue addOperationWithBlock:^{
            // Delay the system for a random number of seconds.
            // This code is _not_ intended for production purposes. The "sleep" call is meant to simulate work done in another subsystem.
            sleep(arc4random_uniform(10));
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                self.completedProgress++;
            }];
        }];
    }
}

#pragma mark - Toolbar Configuration

- (void)configureToolbar {
    NSArray *toolbarButtonItems = @[[self trashBarButtonItem], [self flexibleSpaceBarButtonItem], [self customTitleBarButtonItem]];
    [self.toolbar setItems:toolbarButtonItems animated:YES];
}


#pragma mark - UIBarButtonItem Creation and Configuration

- (UIBarButtonItem *)trashBarButtonItem {
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(barButtonItemClicked:)];
}

- (UIBarButtonItem *)flexibleSpaceBarButtonItem {
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
}

- (UIBarButtonItem *)customTitleBarButtonItem {
    NSString *customTitle = NSLocalizedString(@"Action", nil);
    
    return [[UIBarButtonItem alloc] initWithTitle:customTitle style:UIBarButtonItemStylePlain target:self action:@selector(barButtonItemClicked:)];
}


#pragma mark - Toolbar Actions

- (void)barButtonItemClicked:(UIBarButtonItem *)barButtonItem {
    NSLog(@"A bar button item on the default toolbar was clicked: %@.", barButtonItem);
}

#pragma mark - Configuration

- (void)configureGrayActivityIndicatorView {
    self.grayStyleActivityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    
    [self.grayStyleActivityIndicatorView startAnimating];
    
    self.grayStyleActivityIndicatorView.hidesWhenStopped = YES;
}




@end
