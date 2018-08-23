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

@property (nonatomic, assign) CGFloat minimumScale; // sacle  0.8
@property (nonatomic, assign) CGFloat minimumAlpha; // alpha default 1.0
@property (nonatomic, assign) CGFloat maximumAngle; // angle is % default 0.2

@property (nonatomic, assign) BOOL isInfiniteLoop;  // infinte scroll
@property (nonatomic, assign) CGFloat rateOfChange; // scale and angle change rate
@property (nonatomic, assign) BOOL adjustSpacingWhenScroling;

/// first and last item horizontalc enter, when isInfiniteLoop is NO 只有在关闭循环轮播的情况下，第一个和最后一个item的对齐方式
@property (nonatomic, assign) BOOL itemHorizontalCenter;

// sectionInset
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
