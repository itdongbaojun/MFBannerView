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

//demo配置相关
@property (nonatomic, weak) UILabel *horOrVerLabel;
@property (nonatomic, weak) UISwitch *horOrVerSwitch;

@property (nonatomic, weak) UILabel *loopLabel;
@property (nonatomic, weak) UISwitch *loopSwitch;

@property (nonatomic, weak) UILabel *autoLabel;
@property (nonatomic, weak) UISwitch *autoSwitch;

@property (nonatomic, weak) UILabel *mainLabel;
@property (nonatomic, weak) UISwitch *mainSwitch;

@property (nonatomic, weak) UILabel *typeLabel;
@property (nonatomic, weak) UISegmentedControl *typeControl;

@property (nonatomic, weak) UILabel *itemSizeLabel;
@property (nonatomic, weak) UISlider *itemSizeSlider;

@property (nonatomic, weak) UILabel *itemSpaceLabel;
@property (nonatomic, weak) UISlider *itemSpaceSlider;

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
    
    //添加demo控制
    [self addSwitchView];
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
    
    //demo配置
    self.horOrVerLabel.frame = CGRectMake(10, CGRectGetMaxY(self.bannerView.frame) + 18.0, 0, 0);
    [self.horOrVerLabel sizeToFit];
    self.horOrVerSwitch.frame = CGRectMake(CGRectGetMaxX(self.horOrVerLabel.frame) + 10, CGRectGetMaxY(self.bannerView.frame) + 10.0, 0, 0);
    
    self.loopLabel.frame = CGRectMake(CGRectGetMaxX(self.horOrVerSwitch.frame) + 50.0, CGRectGetMinY(self.horOrVerLabel.frame), 0, 0);
    [self.loopLabel sizeToFit];
    self.loopSwitch.frame = CGRectMake(CGRectGetMaxX(self.loopLabel.frame) + 10, CGRectGetMinY(self.horOrVerSwitch.frame), 0, 0);
    
    self.autoLabel.frame = CGRectMake(10, CGRectGetMaxY(self.horOrVerLabel.frame) + 38.0, 0, 0);
    [self.autoLabel sizeToFit];
    self.autoSwitch.frame = CGRectMake(CGRectGetMaxX(self.autoLabel.frame) + 10, CGRectGetMaxY(self.horOrVerLabel.frame) + 30.0, 0, 0);
    
    self.mainLabel.frame = CGRectMake(CGRectGetMaxX(self.autoSwitch.frame) + 30.0, CGRectGetMaxY(self.horOrVerLabel.frame) + 38.0, 0, 0);
    [self.mainLabel sizeToFit];
    self.mainSwitch.frame = CGRectMake(CGRectGetMaxX(self.mainLabel.frame) + 10, CGRectGetMaxY(self.horOrVerLabel.frame) + 30.0, 0, 0);
    
    self.typeLabel.frame = CGRectMake(10, CGRectGetMaxY(self.autoLabel.frame) + 38.0, 0, 0);
    [self.typeLabel sizeToFit];
    self.typeControl.frame = CGRectMake(CGRectGetMaxX(self.typeLabel.frame) + 10, CGRectGetMaxY(self.autoLabel.frame) + 30.0, 220, 30);
    
    self.itemSizeLabel.frame = CGRectMake(10, CGRectGetMaxY(self.typeLabel.frame) + 38.0, 0, 0);
    [self.itemSizeLabel sizeToFit];
    self.itemSizeSlider.frame = CGRectMake(CGRectGetMaxX(self.itemSizeLabel.frame) + 10, CGRectGetMaxY(self.typeLabel.frame) + 30.0, 220, 30);
    
    self.itemSpaceLabel.frame = CGRectMake(10, CGRectGetMaxY(self.itemSizeLabel.frame) + 38.0, 0, 0);
    [self.itemSpaceLabel sizeToFit];
    self.itemSpaceSlider.frame = CGRectMake(CGRectGetMaxX(self.itemSpaceLabel.frame) + 10, CGRectGetMaxY(self.itemSizeLabel.frame) + 30.0, 220, 30);
}

#pragma mark - MFBannerViewDataSource

- (NSInteger)numberOfItemsInBannerView:(MFBannerView *)bannerView {
    
    return self.datas.count;
}

- (UICollectionViewCell *)bannerView:(MFBannerView *)bannerView cellForItemAtIndex:(NSInteger)index {
    
    MFBannerCell *bannerCell = [bannerView dequeueReusableCellWithReuseIdentifier:@"BannerCellId" forIndex:index];
    bannerCell.backgroundColor = self.datas[index];
    bannerCell.label.text = [NSString stringWithFormat:@"index->%@",@(index + 1)];
    return bannerCell;
}

- (MFBannerLayout *)layoutForBannerView:(MFBannerView *)bannerView {
    
    MFBannerLayout *layout = [[MFBannerLayout alloc] init];
    layout.itemSize = CGSizeMake(CGRectGetWidth(bannerView.frame)*0.8, CGRectGetHeight(bannerView.frame)*0.8);
    layout.itemSpacing = 15.0;
    layout.layoutType = _typeControl.selectedSegmentIndex;
    layout.scrollDirection = _horOrVerSwitch.isOn ? MFBannerViewScrollDirectionVertical : MFBannerViewScrollDirectionHorizontal;
    layout.itemMainDimensionCenter = _mainSwitch.isOn;
    return layout;
}

#pragma mark - MFBannerViewDelegate

- (void)bannerView:(MFBannerView *)bannerView didScrollFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    
    self.pageControl.text = [NSString stringWithFormat:@"%@/%@",@(toIndex + 1),@(self.datas.count)];
}

#pragma mark - demo 配置

- (void)addSwitchView {
    
    UILabel *horOrVerLabel = [[UILabel alloc] init];
    horOrVerLabel.text = @"水平滚动";
    horOrVerLabel.textColor = [UIColor blackColor];
    horOrVerLabel.font = [UIFont systemFontOfSize:14.0];
    [self.view addSubview:horOrVerLabel];
    _horOrVerLabel = horOrVerLabel;
    
    UISwitch *horOrVerSwitch = [[UISwitch alloc] init];
    [horOrVerSwitch addTarget:self action:@selector(switchChange:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:horOrVerSwitch];
    _horOrVerSwitch = horOrVerSwitch;
    
    
    UILabel *loopLabel = [[UILabel alloc] init];
    loopLabel.text = @"无限循环";
    loopLabel.textColor = [UIColor blackColor];
    loopLabel.font = [UIFont systemFontOfSize:14.0];
    [self.view addSubview:loopLabel];
    _loopLabel = loopLabel;
    
    UISwitch *loopSwitch = [[UISwitch alloc] init];
    [loopSwitch setOn:YES];
    [loopSwitch addTarget:self action:@selector(switchChange:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:loopSwitch];
    _loopSwitch = loopSwitch;
    
    
    UILabel *autoLabel = [[UILabel alloc] init];
    autoLabel.text = @"自动轮播";
    autoLabel.textColor = [UIColor blackColor];
    autoLabel.font = [UIFont systemFontOfSize:14.0];
    [self.view addSubview:autoLabel];
    _autoLabel = autoLabel;
    
    UISwitch *autoSwitch = [[UISwitch alloc] init];
    [autoSwitch setOn:YES];
    [autoSwitch addTarget:self action:@selector(switchChange:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:autoSwitch];
    _autoSwitch = autoSwitch;
    
    
    UILabel *mainLabel = [[UILabel alloc] init];
    mainLabel.text = @"主轴居中对齐(开)";
    mainLabel.textColor = [UIColor blackColor];
    mainLabel.font = [UIFont systemFontOfSize:14.0];
    [self.view addSubview:mainLabel];
    _mainLabel = mainLabel;
    
    UISwitch *mainSwitch = [[UISwitch alloc] init];
    [mainSwitch setOn:YES];
    [mainSwitch addTarget:self action:@selector(switchChange:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:mainSwitch];
    _mainSwitch = mainSwitch;
    
    
    UILabel *typeLabel = [[UILabel alloc] init];
    typeLabel.text = @"布局样式";
    typeLabel.textColor = [UIColor blackColor];
    typeLabel.font = [UIFont systemFontOfSize:14.0];
    [self.view addSubview:typeLabel];
    _typeLabel = typeLabel;
    
    UISegmentedControl *typeControl = [[UISegmentedControl alloc] initWithItems:@[@"Normal", @"Linear", @"Coverflow"]];
    [typeControl addTarget:self action:@selector(segControlValueChange:) forControlEvents:UIControlEventValueChanged];
    [typeControl setSelectedSegmentIndex:0];
    [self.view addSubview:typeControl];
    _typeControl = typeControl;
    
    
    UILabel *itemSizeLabel = [[UILabel alloc] init];
    itemSizeLabel.text = @"itemSize";
    itemSizeLabel.textColor = [UIColor blackColor];
    itemSizeLabel.font = [UIFont systemFontOfSize:14.0];
    [self.view addSubview:itemSizeLabel];
    _itemSizeLabel = itemSizeLabel;
    
    UISlider *itemSizeSlider = [[UISlider alloc] init];
    [itemSizeSlider addTarget:self action:@selector(sliderValueChange:) forControlEvents:UIControlEventValueChanged];
    itemSizeSlider.value = 0.8;
    [self.view addSubview:itemSizeSlider];
    _itemSizeSlider = itemSizeSlider;
    
    
    UILabel *itemSpaceLabel = [[UILabel alloc] init];
    itemSpaceLabel.text = @"itemSpace";
    itemSpaceLabel.textColor = [UIColor blackColor];
    itemSpaceLabel.font = [UIFont systemFontOfSize:14.0];
    [self.view addSubview:itemSpaceLabel];
    _itemSpaceLabel = itemSpaceLabel;
    
    UISlider *itemSpaceSlider = [[UISlider alloc] init];
    [itemSpaceSlider addTarget:self action:@selector(sliderValueChange:) forControlEvents:UIControlEventValueChanged];
    itemSpaceSlider.value = 0.5;
    [self.view addSubview:itemSpaceSlider];
    _itemSpaceSlider = itemSpaceSlider;
}

- (void)switchChange:(UISwitch *)sender {
    
    if(sender == self.horOrVerSwitch){
        self.horOrVerLabel.text = sender.isOn ? @"垂直滚动" : @"水平滚动";
        self.bannerView.layout.scrollDirection = sender.isOn ? MFBannerViewScrollDirectionVertical : MFBannerViewScrollDirectionHorizontal;
        [self.bannerView setNeedUpdateLayout];
    }else if(sender == self.loopSwitch){
        
        self.loopLabel.text = sender.isOn ? @"无限循环" : @"不循环";
        self.bannerView.isInfiniteLoop = sender.isOn;
        [self.bannerView updateData];
    }else if(sender == self.autoSwitch){
        
        self.autoLabel.text = sender.isOn ? @"自动轮播" : @"手动轮播";
        self.bannerView.autoScrollInterval = sender.isOn ? 3.0 : 0.0;
    }else if(sender == self.mainSwitch){
        
        self.mainLabel.text = sender.isOn ? @"主轴居中对齐(开)" : @"主轴居中对齐(关)";
        self.bannerView.layout.itemMainDimensionCenter = sender.isOn;
        [self.bannerView setNeedUpdateLayout];
    }
    
}

- (void)segControlValueChange:(UISegmentedControl *)sender {
    
    self.bannerView.layout.layoutType = sender.selectedSegmentIndex;
    [self.bannerView setNeedUpdateLayout];
}

- (void)sliderValueChange:(UISlider *)sender {
    
    if(sender == self.itemSizeSlider){
        self.bannerView.layout.itemSize = CGSizeMake(CGRectGetWidth(self.bannerView.frame)*sender.value, CGRectGetHeight(self.bannerView.frame)*sender.value);
        [self.bannerView setNeedUpdateLayout];
    }else if(sender == self.itemSpaceSlider){
        
        self.bannerView.layout.itemSpacing = 30 * sender.value;
        [self.bannerView setNeedUpdateLayout];
    }
}

@end
