//
//  MFBannerLayout.m
//  MFBannerView
//
//  Created by 董宝君 on 2018/8/22.
//  Copyright © 2018年 董宝君. All rights reserved.
//

#import "MFBannerLayout.h"

typedef NS_ENUM(NSUInteger, MFTransformLayoutItemDirection) {
    MFTransformLayoutItemBefore,  //水平的left，垂直的top
    MFTransformLayoutItemCurrent,   //center
    MFTransformLayoutItemAfter  //水平的right，垂直的bottom
};

@interface MFBannerLayout()

@property (nonatomic, weak) UIView *pageView;

@end

@implementation MFBannerLayout

- (instancetype)init {
    if (self = [super init]) {
        _minimumScale = 0.8;
        _minimumAlpha = 1.0;
        _maximumAngle = 0.2;
        _rateOfChange = 0.4;
        _adjustSpacingWhenScroling = YES;
        _scrollDirection = MFBannerViewScrollDirectionHorizontal;
    }
    return self;
}

#pragma mark - getter

- (UIEdgeInsets)onlyOneSectionInset {
    
    if(_scrollDirection == MFBannerViewScrollDirectionHorizontal){
     
        CGFloat leftSpace = _pageView && !_isInfiniteLoop ? (CGRectGetWidth(_pageView.frame) - _itemSize.width)/2 : _sectionInset.left;
        CGFloat rightSpace = _pageView && !_isInfiniteLoop ? (CGRectGetWidth(_pageView.frame) - _itemSize.width)/2 : _sectionInset.right;
        CGFloat verticalSpace = (CGRectGetHeight(_pageView.frame) - _itemSize.height)/2;
        return UIEdgeInsetsMake(verticalSpace, leftSpace, verticalSpace, rightSpace);
    }else{
        
        CGFloat bottomSpace = _pageView && !_isInfiniteLoop ? (CGRectGetHeight(_pageView.frame) - _itemSize.height)/2 : _sectionInset.bottom;
        CGFloat topSpace = _pageView && !_isInfiniteLoop ? (CGRectGetHeight(_pageView.frame) - _itemSize.height)/2 : _sectionInset.top;
        CGFloat horizontalSpace = (CGRectGetWidth(_pageView.frame) - _itemSize.width)/2;
        return UIEdgeInsetsMake(topSpace, horizontalSpace, bottomSpace, horizontalSpace);
    }
}

- (UIEdgeInsets)firstSectionInset {
    
    if(_scrollDirection == MFBannerViewScrollDirectionHorizontal){

        CGFloat verticalSpace = (CGRectGetHeight(_pageView.frame) - _itemSize.height)/2;
        return UIEdgeInsetsMake(verticalSpace, _sectionInset.left, verticalSpace, _itemSpacing);
    }else{
        
        CGFloat horizontalSpace = (CGRectGetWidth(_pageView.frame) - _itemSize.width)/2;
        return UIEdgeInsetsMake(_sectionInset.top, horizontalSpace, _itemSpacing, horizontalSpace);
    }
}

- (UIEdgeInsets)lastSectionInset {
    
    if(_scrollDirection == MFBannerViewScrollDirectionHorizontal){

        CGFloat verticalSpace = (CGRectGetHeight(_pageView.frame) - _itemSize.height)/2;
        return UIEdgeInsetsMake(verticalSpace, 0, verticalSpace, _sectionInset.right);
    }else{
        
        CGFloat horizontalSpace = (CGRectGetWidth(_pageView.frame) - _itemSize.width)/2;
        return UIEdgeInsetsMake(0, horizontalSpace, _sectionInset.bottom, horizontalSpace);
    }
}

- (UIEdgeInsets)middleSectionInset {
    
    if(_scrollDirection == MFBannerViewScrollDirectionHorizontal){

        CGFloat verticalSpace = (CGRectGetHeight(_pageView.frame) - _itemSize.height)/2;
        return UIEdgeInsetsMake(verticalSpace, 0, verticalSpace, _itemSpacing);
    }else{
        
        CGFloat horizontalSpace = (CGRectGetWidth(_pageView.frame) - _itemSize.width)/2;
        return UIEdgeInsetsMake(0, horizontalSpace, _itemSpacing, horizontalSpace);
    }
}

@end



@interface MFBannerTransformLayout () {
    struct {
        unsigned int applyTransformToAttributes   :1;
        unsigned int initializeTransformAttributes   :1;
    }_delegateFlags;
}

@property (nonatomic, assign) BOOL applyTransformToAttributesDelegate;

@end

@implementation MFBannerTransformLayout

- (instancetype)init {
    if (self = [super init]) {
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return self;
}

#pragma mark - getter setter

- (void)setDelegate:(id<MFBannerTransformLayoutDelegate>)delegate {
    _delegate = delegate;
    _delegateFlags.initializeTransformAttributes = [delegate respondsToSelector:@selector(bannerViewTransformLayout:initializeTransformAttributes:)];
    _delegateFlags.applyTransformToAttributes = [delegate respondsToSelector:@selector(bannerViewTransformLayout:applyTransformToAttributes:)];
}

- (void)setLayout:(MFBannerLayout *)layout {
    _layout = layout;
    _layout.pageView = self.collectionView;
    self.itemSize = _layout.itemSize;
    self.minimumInteritemSpacing = _layout.itemSpacing;
    self.minimumLineSpacing = _layout.itemSpacing;
    if(_layout.scrollDirection == MFBannerViewScrollDirectionHorizontal){
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }else{
        self.scrollDirection = UICollectionViewScrollDirectionVertical;
    }
}

- (CGSize)itemSize {
    if (!_layout) {
        return [super itemSize];
    }
    return _layout.itemSize;
}

- (CGFloat)minimumLineSpacing {
    if (!_layout) {
        return [super minimumLineSpacing];
    }
    return _layout.itemSpacing;
}

- (CGFloat)minimumInteritemSpacing {
    if (!_layout) {
        return [super minimumInteritemSpacing];
    }
    return _layout.itemSpacing;
}

- (MFTransformLayoutItemDirection)directionWithCenter:(CGPoint)center {
    MFTransformLayoutItemDirection direction= MFTransformLayoutItemAfter;
    
    if(self.scrollDirection == UICollectionViewScrollDirectionHorizontal){
       
        CGFloat centerX = center.x;
        CGFloat contentCenterX = self.collectionView.contentOffset.x + CGRectGetWidth(self.collectionView.frame)/2;
        if (ABS(centerX - contentCenterX) < 0.5) {
            direction = MFTransformLayoutItemCurrent;
        }else if (centerX - contentCenterX < 0) {
            direction = MFTransformLayoutItemBefore;
        }
        return direction;
    }else{
        
        CGFloat centerY = center.y;
        CGFloat contentCenterY = self.collectionView.contentOffset.y + CGRectGetHeight(self.collectionView.frame)/2;
        if (ABS(centerY - contentCenterY) < 0.5) {
            direction = MFTransformLayoutItemCurrent;
        }else if (centerY - contentCenterY < 0) {
            direction = MFTransformLayoutItemBefore;
        }
        return direction;
    }
}

#pragma mark - layout

-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    
    return _layout.layoutType == MFBannerLayoutLayoutNormal ? [super shouldInvalidateLayoutForBoundsChange:newBounds] : YES;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    if (_delegateFlags.applyTransformToAttributes || _layout.layoutType != MFBannerLayoutLayoutNormal) {
        NSArray *attributesArray = [[NSArray alloc] initWithArray:[super layoutAttributesForElementsInRect:rect] copyItems:YES];
        CGRect visibleRect = {self.collectionView.contentOffset,self.collectionView.bounds.size};
        for (UICollectionViewLayoutAttributes *attributes in attributesArray) {
            if (!CGRectIntersectsRect(visibleRect, attributes.frame)) {
                continue;
            }
            if (_delegateFlags.applyTransformToAttributes) {
                [_delegate bannerViewTransformLayout:self applyTransformToAttributes:attributes];
            }else {
                [self applyTransformToAttributes:attributes layoutType:_layout.layoutType];
            }
        }
        return attributesArray;
    }
    return [super layoutAttributesForElementsInRect:rect];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attributes = [super layoutAttributesForItemAtIndexPath:indexPath];
    if (_delegateFlags.initializeTransformAttributes) {
        [_delegate bannerViewTransformLayout:self initializeTransformAttributes:attributes];
    }else if(_layout.layoutType != MFBannerLayoutLayoutNormal){
        [self initializeTransformAttributes:attributes layoutType:_layout.layoutType];
    }
    return attributes;
}

#pragma mark - transform

- (void)initializeTransformAttributes:(UICollectionViewLayoutAttributes *)attributes layoutType:(MFBannerLayoutType)layoutType {
    switch (layoutType) {
            case MFBannerLayoutLayoutLinear:
        {
            [self applyLinearTransformToAttributes:attributes scale:_layout.minimumScale alpha:_layout.minimumAlpha];
            break;
        }
            case MFBannerLayoutCoverflow:
        {
            [self applyCoverflowTransformToAttributes:attributes angle:_layout.maximumAngle alpha:_layout.minimumAlpha];
            break;
        }
        default:
            break;
    }
}

- (void)applyTransformToAttributes:(UICollectionViewLayoutAttributes *)attributes layoutType:(MFBannerLayoutType)layoutType {
    switch (layoutType) {
            case MFBannerLayoutLayoutLinear:
            [self applyLinearTransformToAttributes:attributes];
            break;
            case MFBannerLayoutCoverflow:
            [self applyCoverflowTransformToAttributes:attributes];
            break;
        default:
            break;
    }
}

#pragma mark - LinearTransform

- (void)applyLinearTransformToAttributes:(UICollectionViewLayoutAttributes *)attributes {
    
    if(self.scrollDirection == UICollectionViewScrollDirectionHorizontal){
     
        CGFloat collectionViewWidth = self.collectionView.frame.size.width;
        if (collectionViewWidth <= 0) {
            return;
        }
        CGFloat centetX = self.collectionView.contentOffset.x + collectionViewWidth/2;
        CGFloat delta = ABS(attributes.center.x - centetX);
        CGFloat scale = MAX(1 - delta/collectionViewWidth*_layout.rateOfChange, _layout.minimumScale);
        CGFloat alpha = MAX(1 - delta/collectionViewWidth, _layout.minimumAlpha);
        [self applyLinearTransformToAttributes:attributes scale:scale alpha:alpha];
    }else{
        
        CGFloat collectionHeight = self.collectionView.frame.size.height;
        if (collectionHeight <= 0) {
            return;
        }
        CGFloat centetY = self.collectionView.contentOffset.y + collectionHeight/2;
        CGFloat delta = ABS(attributes.center.y - centetY);
        CGFloat scale = MAX(1 - delta/collectionHeight*_layout.rateOfChange, _layout.minimumScale);
        CGFloat alpha = MAX(1 - delta/collectionHeight, _layout.minimumAlpha);
        [self applyLinearTransformToAttributes:attributes scale:scale alpha:alpha];
    }
}

- (void)applyLinearTransformToAttributes:(UICollectionViewLayoutAttributes *)attributes scale:(CGFloat)scale alpha:(CGFloat)alpha {
    CGAffineTransform transform = CGAffineTransformMakeScale(scale, scale);
    if (_layout.adjustSpacingWhenScroling) {
        MFTransformLayoutItemDirection direction = [self directionWithCenter:attributes.center];
        CGFloat translate = 0;
        switch (direction) {
                case MFTransformLayoutItemBefore:
                translate = 1.15 * ((self.scrollDirection == UICollectionViewScrollDirectionHorizontal) ? attributes.size.width : attributes.size.height)*(1-scale)/2;
                break;
                case MFTransformLayoutItemAfter:
                translate = -1.15 * ((self.scrollDirection == UICollectionViewScrollDirectionHorizontal) ? attributes.size.width : attributes.size.height)*(1-scale)/2;
                break;
            default:
                // center
                scale = 1.0;
                alpha = 1.0;
                break;
        }
        transform = CGAffineTransformTranslate(transform,translate, 0);
    }
    attributes.transform = transform;
    attributes.alpha = alpha;
}

#pragma mark - CoverflowTransform

- (void)applyCoverflowTransformToAttributes:(UICollectionViewLayoutAttributes *)attributes{
    
    if(self.scrollDirection == UICollectionViewScrollDirectionHorizontal){
    
        CGFloat collectionViewWidth = self.collectionView.frame.size.width;
        if (collectionViewWidth <= 0) {
            return;
        }
        CGFloat centetX = self.collectionView.contentOffset.x + collectionViewWidth/2;
        CGFloat delta = ABS(attributes.center.x - centetX);
        CGFloat angle = MIN(delta/collectionViewWidth*(1-_layout.rateOfChange), _layout.maximumAngle);
        CGFloat alpha = MAX(1 - delta/collectionViewWidth, _layout.minimumAlpha);
        [self applyCoverflowTransformToAttributes:attributes angle:angle alpha:alpha];
    }else{
        
        CGFloat collectionViewHeight = self.collectionView.frame.size.height;
        if (collectionViewHeight <= 0) {
            return;
        }
        CGFloat centetY = self.collectionView.contentOffset.y + collectionViewHeight/2;
        CGFloat delta = ABS(attributes.center.y - centetY);
        CGFloat angle = MIN(delta/collectionViewHeight*(1-_layout.rateOfChange), _layout.maximumAngle);
        CGFloat alpha = MAX(1 - delta/collectionViewHeight, _layout.minimumAlpha);
        [self applyCoverflowTransformToAttributes:attributes angle:angle alpha:alpha];
    }
}

- (void)applyCoverflowTransformToAttributes:(UICollectionViewLayoutAttributes *)attributes angle:(CGFloat)angle alpha:(CGFloat)alpha {
    MFTransformLayoutItemDirection direction = [self directionWithCenter:attributes.center];
    CATransform3D transform3D = CATransform3DIdentity;
    transform3D.m34 = -0.002;
    CGFloat translate = 0;
    switch (direction) {
            case MFTransformLayoutItemBefore:
            translate = (1-cos(angle*1.2*M_PI))*((self.scrollDirection == UICollectionViewScrollDirectionHorizontal) ? attributes.size.width : attributes.size.height);
            break;
            case MFTransformLayoutItemAfter:
            translate = -(1-cos(angle*1.2*M_PI))*((self.scrollDirection == UICollectionViewScrollDirectionHorizontal) ? attributes.size.width : attributes.size.height);
            angle = -angle;
            break;
        default:
            // center
            angle = 0;
            alpha = 1;
            break;
    }
    
    transform3D = CATransform3DRotate(transform3D, M_PI*angle, 0, 1, 0);
    if (_layout.adjustSpacingWhenScroling) {
        transform3D = CATransform3DTranslate(transform3D, translate, 0, 0);
    }
    attributes.transform3D = transform3D;
    attributes.alpha = alpha;
    
}
@end

