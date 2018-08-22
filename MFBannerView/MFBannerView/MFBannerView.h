//
//  MFBannerView.h
//  MFBannerView
//
//  Created by 董宝君 on 2018/8/22.
//  Copyright © 2018年 董宝君. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFBannerLayout.h"

NS_ASSUME_NONNULL_BEGIN

/// bannerView滚动的方向（目前是左右，后续改成水平和竖直）
typedef NS_ENUM(NSUInteger, MFBannerScrollDirection) {
    MFBannerScrollDirectionLeft,
    MFBannerScrollDirectionRight,
};

@class MFBannerView;

@protocol MFBannerViewDataSource <NSObject>
@required

/// 数据源
- (NSInteger)numberOfItemsInBannerView:(MFBannerView *)bannerView;

- (__kindof UICollectionViewCell *)bannerView:(MFBannerView *)bannerView cellForItemAtIndex:(NSInteger)index;

- (MFBannerLayout *)layoutForBannerView:(MFBannerView *)bannerView;

@end


@protocol MFBannerViewDelegate <NSObject>
@optional

/// bannerView的行为
- (void)bannerView:(MFBannerView *)bannerView didScrollFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;

- (void)bannerView:(MFBannerView *)bannerView didSelectedItemCell:(__kindof UICollectionViewCell *)cell atIndex:(NSInteger)index;

/// 自定义布局
- (void)bannerView:(MFBannerView *)bannerView initializeTransformAttributes:(UICollectionViewLayoutAttributes *)attributes;

- (void)bannerView:(MFBannerView *)bannerView applyTransformToAttributes:(UICollectionViewLayoutAttributes *)attributes;

/// scrollView相关代理
- (void)bannerViewDidScroll:(MFBannerView *)bannerView;

- (void)bannerViewWillBeginDragging:(MFBannerView *)bannerView;

- (void)bannerViewDidEndDragging:(MFBannerView *)bannerView willDecelerate:(BOOL)decelerate;

- (void)bannerViewWillBeginDecelerating:(MFBannerView *)bannerView;

- (void)bannerViewDidEndDecelerating:(MFBannerView *)bannerView;

- (void)bannerViewWillBeginScrollingAnimation:(MFBannerView *)bannerView;

- (void)bannerViewDidEndScrollingAnimation:(MFBannerView *)bannerView;

@end



@interface MFBannerView : UIView

/// 背景 和bannerView大小相同
@property (nonatomic, strong, nullable) UIView *backgroundView;

@property (nonatomic, weak, nullable) id<MFBannerViewDataSource> dataSource;
@property (nonatomic, weak, nullable) id<MFBannerViewDelegate> delegate;

@property (nonatomic, weak, readonly) UICollectionView *collectionView;

/// 布局对象
@property (nonatomic, strong, readonly) MFBannerLayout *layout;

/// 是否循环轮播 默认YES
@property (nonatomic, assign) BOOL isInfiniteLoop;

/// 自动轮播的时间间隔 默认0 不自动轮播
@property (nonatomic, assign) CGFloat autoScrollInterval;

/// 当前轮播的index
@property (nonatomic, assign, readonly) NSInteger curIndex;

/// scrollView 相关的属性
@property (nonatomic, assign, readonly) CGPoint contentOffset;
@property (nonatomic, assign, readonly) BOOL tracking;
@property (nonatomic, assign, readonly) BOOL dragging;
@property (nonatomic, assign, readonly) BOOL decelerating;


/// 刷新数据 注意：这里的刷新数据会把layout文件也进行刷新，重新通过数据源获取layout
- (void)reloadData;

/// 更新数据 不更新布局
- (void)updateData;

/// 单纯的更新布局
- (void)setNeedUpdateLayout;

/// 把lauout置成nil 重新调用数据源中的获取layout
- (void)setNeedClearLayout;

/// 当前的cell
- (__kindof UICollectionViewCell * _Nullable)curIndexCell;

/// 显示的cell
- (NSArray<__kindof UICollectionViewCell *> *_Nullable)visibleCells;

/// 显示的cell对应的index
- (NSArray *)visibleIndexs;

/// 把item滚动到指定的index
- (void)scrollToItemAtIndex:(NSInteger)index animate:(BOOL)animate;

/// 滚动到下一个或者上一个item
- (void)scrollToNearlyIndexAtDirection:(MFBannerScrollDirection)direction animate:(BOOL)animate;

/// 通过Class 注册cell
- (void)registerClass:(Class)Class forCellWithReuseIdentifier:(NSString *)identifier;

/// 通过nib注册cell
- (void)registerNib:(UINib *)nib forCellWithReuseIdentifier:(NSString *)identifier;

/// 取出cell
- (__kindof UICollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
