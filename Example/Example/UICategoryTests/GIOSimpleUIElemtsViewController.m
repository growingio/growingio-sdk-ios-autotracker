//
//  GIOSimpleUIElemtsViewController.m
//  GrowingExample
//
//  Created by GrowingIO on 23/03/2018.
//  Copyright © 2018 GrowingIO. All rights reserved.
//

#import "GIOSimpleUIElemtsViewController.h"

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

@end

@implementation GIOSimpleUIElemtsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureRightNavButtonItem];
    [self configureSearchBar];
}

- (IBAction)imageBtnClick:(UIButton *)sender {
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
    self.searchBar.delegate = self;
    self.searchBar.backgroundImage = [UIImage imageNamed:@"search_bar_background"];
    
    // Set the bookmark image for both normal and highlighted states.
    UIImage *bookmarkImage = [UIImage imageNamed:@"bookmark_icon"];
    [self.searchBar setImage:bookmarkImage forSearchBarIcon:UISearchBarIconBookmark state:UIControlStateNormal];
    
    UIImage *bookmarkHighlightedImage = [UIImage imageNamed:@"bookmark_icon_highlighted"];
    [self.searchBar setImage:bookmarkHighlightedImage forSearchBarIcon:UISearchBarIconBookmark state:UIControlStateHighlighted];
}

#pragma mark - Stepper Actions

- (IBAction)stepperValueDidChange:(UIStepper *)sender {
    NSLog(@"A stepper changed its value: %@.", sender);
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

#pragma mark - Switch Actions

- (IBAction)switchValueDidChange:(UISwitch *)sender {
    NSLog(@"A switch changed its value: %@.", sender);
}

#pragma mark - SegmentedControl Actions

- (IBAction)segmentValudDidChange:(UISegmentedControl *)sender {
    NSLog(@"The selected segment changed for: %@.", sender);
}

#pragma mark - Slider Actions

- (IBAction)sliderValueDidChange:(UISlider *)sender {
    NSLog(@"A slider changed its value: %@", sender);
    float scale = sender.value / sender.maximumValue;
    [self.defaultStyleProgressView setProgress:scale animated:YES];
}

#pragma mark - Toolbar Actions

- (IBAction)barBtnItemClicked:(UIBarButtonItem *)sender {
    NSLog(@"A bar button item on the default toolbar was clicked: %@.", sender);
}

@end
