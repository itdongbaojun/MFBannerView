//
//  MFBannerLayout.h
//  MFBannerView
//
//  Created by 董宝君 on 2018/8/22.
//  Copyright © 2018年 董宝君. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// layout类型
typedef NS_ENUM(NSUInteger, MFBannerLayoutType) {
    MFBannerLayoutLayoutNormal,
    MFBannerLayoutLayoutLinear,
    MFBannerLayoutCoverflow
};

/// 滚动方向
typedef NS_ENUM(NSUInteger, MFBannerViewScrollDirection) {
    MFBannerViewScrollDirectionHorizontal,
    MFBannerViewScrollDirectionVertical
};


@class MFBannerTransformLayout;
@protocol MFBannerTransformLayoutDelegate <NSObject>

- (void)bannerViewTransformLayout:(MFBannerTransformLayout *)bannerViewTransformLayout initializeTransformAttributes:(UICollectionViewLayoutAttributes *)attributes;

- (void)bannerViewTransformLayout:(MFBannerTransformLayout *)bannerViewTransformLayout applyTransformToAttributes:(UICollectionViewLayoutAttributes *)attributes;

@end


@interface MFBannerLayout : NSObject

@property (nonatomic, assign) CGSize itemSize;
@property (nonatomic, assign) CGFloat itemSpacing;
@property (nonatomic, assign) UIEdgeInsets sectionInset;

/// layout类型 默认MFBannerLayoutLayoutNormal 常规类型
@property (nonatomic, assign) MFBannerLayoutType layoutType;

/// 滚动方向，默认MFBannerViewScrollDirectionHorizontal水平滚动
@property (nonatomic, assign) MFBannerViewScrollDirection scrollDirection;

@property (nonatomic, assign) CGFloat minimumScale; // 最小sacle  默认0.8
@property (nonatomic, assign) CGFloat minimumAlpha; // 最小alpha 默认 1.0
@property (nonatomic, assign) CGFloat maximumAngle; // 最小angle 默认0.2

@property (nonatomic, assign) BOOL isInfiniteLoop;  // 循环轮播 默认NO
@property (nonatomic, assign) CGFloat rateOfChange; // scale 和 angle 的变化速率 默认0.4
@property (nonatomic, assign) BOOL adjustSpacingWhenScroling; //transform的过程中动态调整间距 默认YES

/// isInfiniteLoop 为NO时 的第一个和最后一个item的主轴对齐方式。滚动方向为水平滚动时MFBannerViewScrollDirectionHorizontal，表示的是Horizontal方向的对其方式，反之表示的是Vertical方向的对齐方式
@property (nonatomic, assign) BOOL itemMainDimensionCenter;

// 集中情况下的sectionInset
@property (nonatomic, assign, readonly) UIEdgeInsets onlyOneSectionInset;   //关闭循环轮播时的sectionInset，只在一个section中进行的操作
@property (nonatomic, assign, readonly) UIEdgeInsets firstSectionInset;     //打开循环轮播时，第一个section的inset
@property (nonatomic, assign, readonly) UIEdgeInsets lastSectionInset;      //打开循环轮播时，最后一个section的inset
@property (nonatomic, assign, readonly) UIEdgeInsets middleSectionInset;    //打开循环轮播时，中间的section的inset

@end


@interface MFBannerTransformLayout : UICollectionViewFlowLayout

@property (nonatomic, strong) MFBannerLayout *layout;

@property (nonatomic, weak, nullable) id<MFBannerTransformLayoutDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
