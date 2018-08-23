//
//  ViewController.m
//  MFBannerView
//
//  Created by 董宝君 on 2018/8/22.
//  Copyright © 2018年 董宝君. All rights reserved.
//

#import "ViewController.h"
#import "MFBannerView.h"
#import "MFBannerCell.h"

@interface ViewController ()<MFBannerViewDataSource, MFBannerViewDelegate>

@property (nonatomic, weak) MFBannerView *bannerView;
@property (nonatomic, weak) UILabel *pageControl;
@property (nonatomic, copy) NSArray *datas;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"MFBannerView";
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self addBannerView];
    [self addPageControl];
    
    //模拟加载数据
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addBannerView {
    
    MFBannerView *bannerView = [[MFBannerView alloc]init];
    bannerView.layer.borderWidth = 1;
    bannerView.isInfiniteLoop = YES;
    bannerView.autoScrollInterval = 3.0;
    bannerView.dataSource = self;
    bannerView.delegate = self;
    // 业务方根据自己的需要自定义自己的cell，自己进行注册
    [bannerView registerClass:[MFBannerCell class] forCellWithReuseIdentifier:@"BannerCellId"];
    [self.view addSubview:bannerView];
    _bannerView = bannerView;
}

- (void)addPageControl {
    
    UILabel *pageControl = [[UILabel alloc] init];
    pageControl.textColor = [UIColor whiteColor];
    pageControl.font = [UIFont systemFontOfSize:12];
    pageControl.layer.masksToBounds = YES;
    pageControl.layer.cornerRadius = 9.f;
    pageControl.textAlignment = NSTextAlignmentCenter;
    pageControl.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [self.bannerView addSubview:pageControl];
    _pageControl = pageControl;
}

- (void)loadData {
    
    NSMutableArray *datas = [NSMutableArray array];
    for (int i = 0; i < 7; ++i) {
        if (i == 0) {
            [datas addObject:[UIColor redColor]];
            continue;
        }
        [datas addObject:[UIColor colorWithRed:arc4random()%255/255.0 green:arc4random()%255/255.0 blue:arc4random()%255/255.0 alpha:arc4random()%255/255.0]];
    }
    self.datas = datas;
    [self.bannerView reloadData];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.bannerView.frame = CGRectMake(0, 100, CGRectGetWidth(self.view.frame), 200);
    
    CGFloat pageControlHeight = 18.f;
    CGFloat pageControlWidth = 33.f;
    CGFloat pageControlX = CGRectGetWidth(self.bannerView.frame) - 7.5f - pageControlWidth;
    CGFloat pageControlY = CGRectGetHeight(self.bannerView.frame) - 7.5f - pageControlHeight;
    self.pageControl.frame = CGRectMake(pageControlX, pageControlY, pageControlWidth, pageControlHeight);
}

#pragma mark - MFBannerViewDataSource

- (NSInteger)numberOfItemsInBannerView:(MFBannerView *)bannerView {
    
    return self.datas.count;
}

- (UICollectionViewCell *)bannerView:(MFBannerView *)bannerView cellForItemAtIndex:(NSInteger)index {
    
    MFBannerCell *bannerCell = [bannerView dequeueReusableCellWithReuseIdentifier:@"BannerCellId" forIndex:index];
    bannerCell.backgroundColor = self.datas[index];
    bannerCell.label.text = [NSString stringWithFormat:@"index->%@",@(index)];
    return bannerCell;
}

- (MFBannerLayout *)layoutForBannerView:(MFBannerView *)bannerView {
    
    MFBannerLayout *layout = [[MFBannerLayout alloc] init];
    layout.itemSize = CGSizeMake(CGRectGetWidth(bannerView.frame)*1.0, CGRectGetHeight(bannerView.frame)*1.0);
    layout.itemSpacing = 15.0;
    layout.layoutType = MFBannerLayoutLayoutNormal;
    layout.scrollDirection = MFBannerViewScrollDirectionVertical;
    return layout;
}

#pragma mark - MFBannerViewDelegate

- (void)bannerView:(MFBannerView *)bannerView didScrollFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    
    self.pageControl.text = [NSString stringWithFormat:@"%@/%@",@(toIndex + 1),@(self.datas.count)];
}

@end
