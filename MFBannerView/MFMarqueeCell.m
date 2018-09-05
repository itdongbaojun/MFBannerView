//
//  MFMarqueeCell.m
//  MFBannerView
//
//  Created by 董宝君 on 2018/9/5.
//  Copyright © 2018年 董宝君. All rights reserved.
//

#import "MFMarqueeCell.h"
#import "MFBannerView.h"
#import <Masonry.h>

static NSString *const TextCellIdentifier = @"TextCellIdentifier";

@interface MFTextCell : UICollectionViewCell
@property (nonatomic, strong) UILabel *label;
@end

@implementation MFTextCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self addLabel];
    }
    return self;
}

- (void)addLabel {
    
    UILabel *label = [[UILabel alloc]init];
    label.textAlignment = NSTextAlignmentLeft;
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:18];
    [self addSubview:label];
    
    _label = label;
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.bottom.trailing.equalTo(self);
        make.leading.mas_equalTo(@15.0);
    }];
}

@end



@interface MFMarqueeCell()<MFBannerViewDataSource, MFBannerViewDelegate>

@property (nonatomic, strong) MFBannerView *bannerView;
@property (nonatomic, copy) NSArray *datas;

@property (nonatomic, strong) UIView *bottomLine;

@end

@implementation MFMarqueeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        
        [self setupView];
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setupView {
    
    [self.contentView addSubview:self.bannerView];
    [self.contentView addSubview:self.bottomLine];
    
    [self.bannerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    
    [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView.mas_bottom);
        make.height.mas_equalTo(@(1.0/[UIScreen mainScreen].scale));
    }];
}

#pragma mark - MFBannerViewDataSource

- (NSInteger)numberOfItemsInBannerView:(MFBannerView *)bannerView {
    
    return self.datas.count;
}

- (UICollectionViewCell *)bannerView:(MFBannerView *)bannerView cellForItemAtIndex:(NSInteger)index {
    
    MFTextCell *textCell = [bannerView dequeueReusableCellWithReuseIdentifier:TextCellIdentifier forIndex:index];
    textCell.label.text = self.datas[index];
    return textCell;
}

- (MFBannerLayout *)layoutForBannerView:(MFBannerView *)bannerView {
    
    MFBannerLayout *layout = [[MFBannerLayout alloc] init];
    layout.itemSize = CGSizeMake(CGRectGetWidth(bannerView.frame), CGRectGetHeight(bannerView.frame));
    layout.itemSpacing = 0.0;
    layout.sectionInset = UIEdgeInsetsZero;
    layout.layoutType = MFBannerLayoutNormal;
    layout.scrollDirection = MFBannerViewScrollDirectionVertical;
    return layout;
}

#pragma mark - setter and getter

- (MFBannerView *)bannerView {
    
    if(!_bannerView){
        
        _bannerView = [[MFBannerView alloc] init];
        _bannerView.isInfiniteLoop = YES;
        _bannerView.autoScrollInterval = 3.0;
        _bannerView.dataSource = self;
        _bannerView.delegate = self;
        _bannerView.collectionView.scrollEnabled = NO;
        [_bannerView registerClass:[MFTextCell class] forCellWithReuseIdentifier:TextCellIdentifier];
    }
    
    return _bannerView;
}

- (NSArray *)datas {
    
    if(!_datas){
        
        _datas = @[@"Marquee ~ 跑马灯"];
    }
    
    return _datas;
}

- (UIView *)bottomLine {
    
    if(!_bottomLine){
        
        _bottomLine = [[UIView alloc] initWithFrame:CGRectZero];
        _bottomLine.backgroundColor = [UIColor lightGrayColor];
    }
    
    return _bottomLine;
}

@end
