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
    MFBannerLayoutCoverflow,
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

@property (nonatomic, assign) MFBannerLayoutType layoutType;

@property (nonatomic, assign) CGFloat minimumScale; // sacle  0.8
@property (nonatomic, assign) CGFloat minimumAlpha; // alpha default 1.0
@property (nonatomic, assign) CGFloat maximumAngle; // angle is % default 0.2

@property (nonatomic, assign) BOOL isInfiniteLoop;  // infinte scroll
@property (nonatomic, assign) CGFloat rateOfChange; // scale and angle change rate
@property (nonatomic, assign) BOOL adjustSpacingWhenScroling;

/**
 pageView cell item vertical centering
 */
@property (nonatomic, assign) BOOL itemVerticalCenter;

/**
 first and last item horizontalc enter, when isInfiniteLoop is NO
 */
@property (nonatomic, assign) BOOL itemHorizontalCenter;

// sectionInset
@property (nonatomic, assign, readonly) UIEdgeInsets onlyOneSectionInset;
@property (nonatomic, assign, readonly) UIEdgeInsets firstSectionInset;
@property (nonatomic, assign, readonly) UIEdgeInsets lastSectionInset;
@property (nonatomic, assign, readonly) UIEdgeInsets middleSectionInset;

@end


@interface MFBannerTransformLayout : UICollectionViewFlowLayout

@property (nonatomic, strong) MFBannerLayout *layout;

@property (nonatomic, weak, nullable) id<MFBannerTransformLayoutDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
