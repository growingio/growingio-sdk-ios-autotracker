//
//  GIOPagingViewController.m
//  Example
//
//  Created by BeyondChao on 2020/8/10.
//  Copyright © 2020 GrowingIO. All rights reserved.
//

#import "GIOPagingViewController.h"

@interface GIOPageItemController ()

@property (nonatomic, strong) UIImageView *contentImageView;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation GIOPageItemController

#pragma mark View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
        
    [self.view addSubview:self.contentImageView];
    [self.view addSubview:self.titleLabel];
    self.contentImageView.image = [UIImage imageNamed:self.imageName];
}

- (void)setImageName:(NSString *)name {
    _imageName = name;
    self.contentImageView.image = [UIImage imageNamed:_imageName];
    self.titleLabel.text = name;
}

- (UIImageView *)contentImageView {
    if (!_contentImageView) {
        _contentImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _contentImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _contentImageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(150, 100, 150, 80)];
        _titleLabel.textColor = [UIColor darkTextColor];
    }
    return _titleLabel;
}


@end

#pragma mark - GIOPagingViewController

@interface GIOPagingViewController () <UIPageViewControllerDataSource>

@property (nonatomic, strong) NSArray *contentImages;
@property (nonatomic, strong) UIPageViewController *pageViewController;

@end

@implementation GIOPagingViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = @"PagingViewController";

    [self createPageViewController];
}

- (void)createPageViewController {
    
    UIPageViewController *pageController = [[UIPageViewController alloc] init];
    pageController.view.backgroundColor = [UIColor whiteColor];
    pageController.dataSource = self;
    
    if ([self.contentImages count]) {
        NSArray *startingViewControllers = @[[self itemControllerForIndex:0]];
        [pageController setViewControllers:startingViewControllers
                                 direction:UIPageViewControllerNavigationDirectionForward
                                  animated:NO
                                completion:nil];
    }
    
    self.pageViewController = pageController;
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
}

#pragma mark UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    GIOPageItemController *itemController = (GIOPageItemController *)viewController;
    
    if (itemController.itemIndex > 0) {
        return [self itemControllerForIndex:itemController.itemIndex - 1];
    }
    
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    GIOPageItemController *itemController = (GIOPageItemController *)viewController;
    
    if (itemController.itemIndex + 1 < [self.contentImages count]) {
        return [self itemControllerForIndex:itemController.itemIndex + 1];
    }
    
    return nil;
}

- (GIOPageItemController *)itemControllerForIndex:(NSUInteger)itemIndex {
    if (itemIndex < [self.contentImages count]) {
        GIOPageItemController *pageItemController = [[GIOPageItemController alloc] init];
        pageItemController.itemIndex = itemIndex;
        pageItemController.imageName = self.contentImages[itemIndex];
        return pageItemController;
    }
    
    return nil;
}

#pragma mark Page Indicator

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return self.contentImages.count;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    return 0;
}

#pragma mark - Additions

- (NSUInteger)currentControllerIndex {
    GIOPageItemController *pageItemController = (GIOPageItemController *) [self currentController];
    
    if (pageItemController) {
        return pageItemController.itemIndex;
    }
    
    return -1;
}

- (UIViewController *)currentController {
    if ([self.pageViewController.viewControllers count]) {
        return self.pageViewController.viewControllers[0];
    }
    
    return nil;
}

#pragma mark - Load Lazy

- (NSArray *)contentImages {
    if (!_contentImages) {
        _contentImages = @[@"food1", @"food2", @"food3"];
    }
    return _contentImages;
}

@end
