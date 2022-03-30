//
//  GIOCollectionViewController.m
//  GrowingExample
//
//  Created by GrowingIO on 2018/5/22.
//  Copyright (C) 2018 Beijing Yishu Technology Co., Ltd.
//

#import "GIOCollectionViewController.h"
#import "GIOCollectionViewCell.h"

@interface GrowingCollectionDelegateProxy : NSProxy

@property (nonatomic, weak, readonly, nullable) id target;

@end

@implementation GrowingCollectionDelegateProxy
- (nonnull instancetype)initWithTarget:(nonnull id)target {
    _target = target;
    return self;
}

- (id)forwardingTargetForSelector:(SEL)selector {
    return _target;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    void *null = NULL;
    [invocation setReturnValue:&null];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    return [NSObject instanceMethodSignatureForSelector:@selector(init)];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return [_target respondsToSelector:aSelector];
}

- (BOOL)isEqual:(id)object {
    return [_target isEqual:object];
}

- (NSUInteger)hash {
    return [_target hash];
}

- (Class)superclass {
    return [_target superclass];
}

- (Class)class {
    return [_target class];
}

- (BOOL)isKindOfClass:(Class)aClass {
    return [_target isKindOfClass:aClass];
}

- (BOOL)isMemberOfClass:(Class)aClass {
    return [_target isMemberOfClass:aClass];
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol {
    return [_target conformsToProtocol:aProtocol];
}

- (BOOL)isProxy {
    return YES;
}

- (NSString *)description {
    return [_target description];
}

- (NSString *)debugDescription {
    return [_target debugDescription];
}


@end


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
        static GrowingCollectionDelegateProxy *proxy = nil;
        proxy = [[GrowingCollectionDelegateProxy alloc] initWithTarget:self];
        _mainCollectionView.delegate = proxy;
        _mainCollectionView.dataSource = self;
    }

    return _mainCollectionView;
}

- (NSArray<NSString *> *)imagesArray {
    if (!_imagesArray) {
        NSMutableArray *images = [NSMutableArray array];
        for (int i = 1; i < 9; i++) {
            [images addObject:[NSString stringWithFormat:@"cycle_0%d", i]];
        }
        _imagesArray = images.copy;
    }
    return _imagesArray;
}

@end



