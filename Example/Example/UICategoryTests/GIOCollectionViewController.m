//
//  GIOCollectionViewController.m
//  GrowingExample
//
//  Created by GrowingIO on 2018/5/22.
//  Copyright (C) 2018 Beijing Yishu Technology Co., Ltd.
//

#import "GIOCollectionViewController.h"

#import "GIOCollectionViewCell.h"

@interface GIOCollectionViewController () <UICollectionViewDelegate,
                                           UICollectionViewDataSource,
                                           UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *mainCollectionView;
@property (nonatomic, strong) NSArray<NSString *> *imagesArray;

@end

@implementation GIOCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view addSubview:self.mainCollectionView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UICollectionViewDelegate, UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 3;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imagesArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GIOCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GIOCollectionViewCell"
                                                                            forIndexPath:indexPath];

    NSString *title = [NSString stringWithFormat:(@"第%ld张图片"), (long)indexPath.row + 1];
    [cell configWithTitle:title andIamgeName:self.imagesArray[indexPath.row]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%s-%d indexPath = %@", __func__, __LINE__, indexPath);
}

#pragma mark Lazy Load

- (UICollectionView *)mainCollectionView {
    if (!_mainCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        //设置collectionView滚动方向
        //[layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        //设置headerView的尺寸大小
        layout.headerReferenceSize = CGSizeMake(self.view.frame.size.width, 10);
        //该方法也可以设置itemSize
        layout.itemSize = CGSizeMake(110, 150);

        _mainCollectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        _mainCollectionView.backgroundColor = [UIColor clearColor];

        [_mainCollectionView registerNib:[UINib nibWithNibName:@"GIOCollectionViewCell" bundle:nil]
              forCellWithReuseIdentifier:@"GIOCollectionViewCell"];

        //注册headerView  此处的ReuseIdentifier 必须和 cellForItemAtIndexPath 方法中 一致  均为reusableView
        [_mainCollectionView registerClass:[UICollectionReusableView class]
                forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                       withReuseIdentifier:@"reusableView"];

        // 4.设置代理
        _mainCollectionView.accessibilityIdentifier = @"GIOCollectionView";
        _mainCollectionView.delegate = self;
        _mainCollectionView.dataSource = self;
    }

    return _mainCollectionView;
}

- (NSArray<NSString *> *)imagesArray {
    if (!_imagesArray) {
        _imagesArray = @[
            @"cycle_01.jpg", @"cycle_02.jpg", @"cycle_03.jpg", @"cycle_04.jpg", @"cycle_03.jpg", @"cycle_04.jpg",
            @"cycle_05.jpg", @"cycle_06.jpg", @"cycle_07.jpg", @"cycle_08.jpg"
        ];
    }
    return _imagesArray;
}

@end
