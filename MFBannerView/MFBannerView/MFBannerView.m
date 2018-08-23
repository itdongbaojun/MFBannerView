//
//  MFBannerView.m
//  MFBannerView
//
//  Created by 董宝君 on 2018/8/22.
//  Copyright © 2018年 董宝君. All rights reserved.
//

#import "MFBannerView.h"

typedef struct {
    NSInteger index;
    NSInteger section;
}MFIndexSection;

NS_INLINE BOOL MFEqualIndexSection(MFIndexSection indexSection1,MFIndexSection indexSection2) {
    return indexSection1.index == indexSection2.index && indexSection1.section == indexSection2.section;
}

NS_INLINE MFIndexSection MFMakeIndexSection(NSInteger index, NSInteger section) {
    MFIndexSection indexSection;
    indexSection.index = index;
    indexSection.section = section;
    return indexSection;
}

@interface MFBannerView()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MFBannerTransformLayoutDelegate> {
    struct {
        unsigned int bannerViewDidScroll   :1;
        unsigned int didScrollFromIndexToNewIndex   :1;
        unsigned int initializeTransformAttributes   :1;
        unsigned int applyTransformToAttributes   :1;
    }_delegateFlags;
    struct {
        unsigned int cellForItemAtIndex   :1;
        unsigned int layoutForPagerView   :1;
    }_dataSourceFlags;
}

// UI
@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, strong) MFBannerLayout *layout;
@property (nonatomic, strong) NSTimer *timer;

// Data
@property (nonatomic, assign) NSInteger numberOfItems;

@property (nonatomic, assign) MFIndexSection indexSection; // current index
@property (nonatomic, assign) NSInteger dequeueSection;
@property (nonatomic, assign) MFIndexSection beginDragIndexSection;
@property (nonatomic, assign) NSInteger firstScrollIndex;

@property (nonatomic, assign) BOOL needClearLayout;
@property (nonatomic, assign) BOOL didReloadData;
@property (nonatomic, assign) BOOL didLayout;

@end

#define kBannerViewMaxSectionCount 200
#define kBannerViewMinSectionCount 18

@implementation MFBannerView

#pragma mark - life Cycle

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configureProperty];
        
        [self addCollectionView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self configureProperty];
        
        [self addCollectionView];
    }
    return self;
}

- (void)configureProperty {
    _didReloadData = NO;
    _didLayout = NO;
    _autoScrollInterval = 0;
    _isInfiniteLoop = YES;
    _beginDragIndexSection.index = 0;
    _beginDragIndexSection.section = 0;
    _indexSection.index = -1;
    _indexSection.section = -1;
    _firstScrollIndex = -1;
}

- (void)addCollectionView {
    MFBannerTransformLayout *layout = [[MFBannerTransformLayout alloc]init];
    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
    layout.delegate = _delegateFlags.applyTransformToAttributes ? self : nil;;
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.pagingEnabled = NO;
    collectionView.decelerationRate = 1-0.0076;
    if ([collectionView respondsToSelector:@selector(setPrefetchingEnabled:)]) {
        if (@available(iOS 10.0, *)) {  //只是为了处理警告
            collectionView.prefetchingEnabled = NO;
        }
    }
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.showsVerticalScrollIndicator = NO;
    [self addSubview:collectionView];
    _collectionView = collectionView;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (!newSuperview) {
        [self removeTimer];
    }else {
        [self removeTimer];
        if (_autoScrollInterval > 0) {
            [self addTimer];
        }
    }
}

#pragma mark - timer

- (void)addTimer {
    if (_timer) {
        return;
    }
    _timer = [NSTimer timerWithTimeInterval:_autoScrollInterval target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)removeTimer {
    if (!_timer) {
        return;
    }
    [_timer invalidate];
    _timer = nil;
}

- (void)timerFired:(NSTimer *)timer {
    if (!self.superview || !self.window || _numberOfItems == 0 || self.tracking) {
        return;
    }
    
    [self scrollToNearlyIndexAtDirection:MFBannerScrollDirectionAfter animate:YES];
}

#pragma mark - getter

- (MFBannerLayout *)layout {
    if (!_layout) {
        if (_dataSourceFlags.layoutForPagerView) {
            _layout = [_dataSource layoutForBannerView:self];
            _layout.isInfiniteLoop = _isInfiniteLoop;
        }
        if (_layout.itemSize.width <= 0 || _layout.itemSize.height <= 0) {
            _layout = nil;
        }
    }
    return _layout;
}

- (NSInteger)curIndex {
    return _indexSection.index;
}

- (CGPoint)contentOffset {
    return _collectionView.contentOffset;
}

- (BOOL)tracking {
    return _collectionView.tracking;
}

- (BOOL)dragging {
    return _collectionView.dragging;
}

- (BOOL)decelerating {
    return _collectionView.decelerating;
}

- (UIView *)backgroundView {
    return _collectionView.backgroundView;
}

- (__kindof UICollectionViewCell *)curIndexCell {
    return [_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_indexSection.index inSection:_indexSection.section]];
}

- (NSArray<__kindof UICollectionViewCell *> *)visibleCells {
    return _collectionView.visibleCells;
}

- (NSArray *)visibleIndexs {
    NSMutableArray *indexs = [NSMutableArray array];
    for (NSIndexPath *indexPath in _collectionView.indexPathsForVisibleItems) {
        [indexs addObject:@(indexPath.item)];
    }
    return [indexs copy];
}

#pragma mark - setter

- (void)setBackgroundView:(UIView *)backgroundView {
    [_collectionView setBackgroundView:backgroundView];
}

- (void)setAutoScrollInterval:(CGFloat)autoScrollInterval {
    _autoScrollInterval = autoScrollInterval;
    [self removeTimer];
    if (autoScrollInterval > 0 && self.superview) {
        [self addTimer];
    }
}

- (void)setDelegate:(id<MFBannerViewDelegate>)delegate {
    _delegate = delegate;
    _delegateFlags.bannerViewDidScroll = [delegate respondsToSelector:@selector(bannerViewDidScroll:)];
    _delegateFlags.didScrollFromIndexToNewIndex = [delegate respondsToSelector:@selector(bannerView:didScrollFromIndex:toIndex:)];
    _delegateFlags.initializeTransformAttributes = [delegate respondsToSelector:@selector(bannerView:initializeTransformAttributes:)];
    _delegateFlags.applyTransformToAttributes = [delegate respondsToSelector:@selector(bannerView:applyTransformToAttributes:)];
    if (self.collectionView && self.collectionView.collectionViewLayout) {
        ((MFBannerTransformLayout *)self.collectionView.collectionViewLayout).delegate = _delegateFlags.applyTransformToAttributes ? self : nil;
    }
}

- (void)setDataSource:(id<MFBannerViewDataSource>)dataSource {
    _dataSource = dataSource;
    _dataSourceFlags.cellForItemAtIndex = [dataSource respondsToSelector:@selector(bannerView:cellForItemAtIndex:)];
    _dataSourceFlags.layoutForPagerView = [dataSource respondsToSelector:@selector(layoutForBannerView:)];
}

#pragma mark - public

- (void)reloadData {
    _didReloadData = YES;
    [self setNeedClearLayout];
    [self clearLayout];
    [self updateData];
}

// not clear layout
- (void)updateData {
    [self updateLayout];
    _numberOfItems = [_dataSource numberOfItemsInBannerView:self];
    [_collectionView reloadData];
    if (!_didLayout && !CGRectIsEmpty(self.frame) && _indexSection.index < 0) {
        _didLayout = YES;
    }
    [self resetBannerViewAtIndex:_indexSection.index < 0 && !CGRectIsEmpty(self.frame) ? 0 :_indexSection.index];
}

- (void)scrollToNearlyIndexAtDirection:(MFBannerScrollDirection)direction animate:(BOOL)animate {
    MFIndexSection indexSection = [self nearlyIndexPathAtDirection:direction];
    [self scrollToItemAtIndexSection:indexSection animate:animate];
}

- (void)scrollToItemAtIndex:(NSInteger)index animate:(BOOL)animate {
    if (!_didLayout && _didReloadData) {
        _firstScrollIndex = index;
    }else {
        _firstScrollIndex = -1;
    }
    if (!_isInfiniteLoop) {
        //非无限轮播 只在第一个section内进行处理
        [self scrollToItemAtIndexSection:MFMakeIndexSection(index, 0) animate:animate];
        return;
    }
    
    //无限循环需要在跨多section中进行处理
    [self scrollToItemAtIndexSection:MFMakeIndexSection(index, index >= self.curIndex ? _indexSection.section : _indexSection.section+1) animate:animate];
}

- (void)scrollToItemAtIndexSection:(MFIndexSection)indexSection animate:(BOOL)animate {
    if (_numberOfItems <= 0 || ![self isValidIndexSection:indexSection]) {
        return;
    }
    
    if (animate && [_delegate respondsToSelector:@selector(bannerViewWillBeginScrollingAnimation:)]) {
        [_delegate bannerViewWillBeginScrollingAnimation:self];
    }
    CGFloat offset = [self caculateOffsetAtIndexSection:indexSection];
    if(_layout.scrollDirection == MFBannerViewScrollDirectionHorizontal){
        [_collectionView setContentOffset:CGPointMake(offset, _collectionView.contentOffset.y) animated:animate];
    }else{
        [_collectionView setContentOffset:CGPointMake(_collectionView.contentOffset.x, offset) animated:animate];
    }
}

- (void)registerClass:(Class)Class forCellWithReuseIdentifier:(NSString *)identifier {
    [_collectionView registerClass:Class forCellWithReuseIdentifier:identifier];
}

- (void)registerNib:(UINib *)nib forCellWithReuseIdentifier:(NSString *)identifier {
    [_collectionView registerNib:nib forCellWithReuseIdentifier:identifier];
}

- (__kindof UICollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forIndex:(NSInteger)index {
    UICollectionViewCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:[NSIndexPath indexPathForItem:index inSection:_dequeueSection]];
    return cell;
}

#pragma mark - configure layout

- (void)updateLayout {
    if (!self.layout) {
        return;
    }
    self.layout.isInfiniteLoop = _isInfiniteLoop;
    ((MFBannerTransformLayout *)_collectionView.collectionViewLayout).layout = self.layout;
}

- (void)clearLayout {
    if (_needClearLayout) {
        _layout = nil;
        _needClearLayout = NO;
    }
}

- (void)setNeedClearLayout {
    _needClearLayout = YES;
}

- (void)setNeedUpdateLayout {
    if (!self.layout) {
        return;
    }
    [self clearLayout];
    [self updateLayout];
    [_collectionView.collectionViewLayout invalidateLayout];
    [self resetBannerViewAtIndex:_indexSection.index < 0 ? 0 :_indexSection.index];
}

#pragma mark - pager index

- (BOOL)isValidIndexSection:(MFIndexSection)indexSection {
    return indexSection.index >= 0 && indexSection.index < _numberOfItems && indexSection.section >= 0 && indexSection.section < kBannerViewMaxSectionCount;
}

- (MFIndexSection)nearlyIndexPathAtDirection:(MFBannerScrollDirection)direction{
    return [self nearlyIndexPathForIndexSection:_indexSection direction:direction];
}

- (MFIndexSection)nearlyIndexPathForIndexSection:(MFIndexSection)indexSection direction:(MFBannerScrollDirection)direction {
    
    //越界返回当前
    if (indexSection.index < 0 || indexSection.index >= _numberOfItems) {
        return indexSection;
    }
    
    //非无限轮播
    if (!_isInfiniteLoop) {
        
        //从右往左走， index+1，到右边尽头，复位到0.0最左边
        if (direction == MFBannerScrollDirectionAfter && indexSection.index == _numberOfItems - 1) {
            return _autoScrollInterval > 0 ? MFMakeIndexSection(0, 0) : indexSection;
        } else if (direction == MFBannerScrollDirectionAfter) {
            return MFMakeIndexSection(indexSection.index+1, 0);
        }
        
        //从左向右走，index-1，到左边尽头，复位到最右边
        if (indexSection.index == 0) {
            return _autoScrollInterval > 0 ? MFMakeIndexSection(_numberOfItems - 1, 0) : indexSection;
        }
        return MFMakeIndexSection(indexSection.index-1, 0);
    }
    
    //无限循环
    if (direction == MFBannerScrollDirectionAfter) {
        
        //当前section内能处理，就在当前正常+
        if (indexSection.index < _numberOfItems-1) {
            return MFMakeIndexSection(indexSection.index+1, indexSection.section);
        }
        //右边界
        if (indexSection.section >= kBannerViewMaxSectionCount-1) {
            return MFMakeIndexSection(indexSection.index, kBannerViewMaxSectionCount-1);
        }
        return MFMakeIndexSection(0, indexSection.section+1);
    }
    
    //从左向右
    if (indexSection.index > 0) {
        return MFMakeIndexSection(indexSection.index-1, indexSection.section);
    }
    if (indexSection.section <= 0) {
        return MFMakeIndexSection(indexSection.index, 0);
    }
    return MFMakeIndexSection(_numberOfItems-1, indexSection.section-1);
}

- (MFIndexSection)caculateIndexSectionWithOffset:(CGPoint)offset {

    if (_numberOfItems <= 0) {
        return MFMakeIndexSection(0, 0);
    }
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)_collectionView.collectionViewLayout;
    
    if(_layout.scrollDirection == MFBannerViewScrollDirectionHorizontal){
     
        CGFloat offsetX = offset.x;
        CGFloat leftEdge = _isInfiniteLoop ? _layout.sectionInset.left : _layout.onlyOneSectionInset.left;
        CGFloat width = CGRectGetWidth(_collectionView.frame);
        CGFloat middleOffset = offsetX + width/2;
        CGFloat itemWidth = layout.itemSize.width + layout.minimumInteritemSpacing;
        NSInteger curIndex = 0;
        NSInteger curSection = 0;
        if (middleOffset - leftEdge >= 0) {
            NSInteger itemIndex = (middleOffset - leftEdge+layout.minimumInteritemSpacing/2)/itemWidth;
            if (itemIndex < 0) {
                itemIndex = 0;
            }else if (itemIndex >= _numberOfItems*kBannerViewMaxSectionCount) {
                itemIndex = _numberOfItems*kBannerViewMaxSectionCount-1;
            }
            curIndex = itemIndex%_numberOfItems;
            curSection = itemIndex/_numberOfItems;
        }
        return MFMakeIndexSection(curIndex, curSection);
    }else{
        
        CGFloat offsetY = offset.y;
        CGFloat topEdge = _isInfiniteLoop ? _layout.sectionInset.top : _layout.onlyOneSectionInset.top;
        CGFloat height = CGRectGetHeight(_collectionView.frame);
        CGFloat middleOffset = offsetY + height/2;
        CGFloat itemHeight = layout.itemSize.height + layout.minimumInteritemSpacing;
        NSInteger curIndex = 0;
        NSInteger curSection = 0;
        if (middleOffset - topEdge >= 0) {
            NSInteger itemIndex = (middleOffset - topEdge+layout.minimumInteritemSpacing/2)/itemHeight;
            if (itemIndex < 0) {
                itemIndex = 0;
            }else if (itemIndex >= _numberOfItems*kBannerViewMaxSectionCount) {
                itemIndex = _numberOfItems*kBannerViewMaxSectionCount-1;
            }
            curIndex = itemIndex%_numberOfItems;
            curSection = itemIndex/_numberOfItems;
        }
        return MFMakeIndexSection(curIndex, curSection);
    }
}

- (CGFloat)caculateOffsetAtIndexSection:(MFIndexSection)indexSection{
    if (_numberOfItems == 0) {
        return 0;
    }
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)_collectionView.collectionViewLayout;
    UIEdgeInsets edge = _isInfiniteLoop ? _layout.sectionInset : _layout.onlyOneSectionInset;
    
    if(_layout.scrollDirection == MFBannerViewScrollDirectionHorizontal){
        
        CGFloat leftEdge = edge.left;
        CGFloat rightEdge = edge.right;
        CGFloat width = CGRectGetWidth(_collectionView.frame);
        CGFloat itemWidth = layout.itemSize.width + layout.minimumInteritemSpacing;
        CGFloat offsetX = 0;
        if (!_isInfiniteLoop && indexSection.index == _numberOfItems - 1) {
            offsetX = leftEdge + itemWidth*(indexSection.index + indexSection.section*_numberOfItems) - (width - itemWidth) -  layout.minimumInteritemSpacing + rightEdge;
        }else {
            offsetX = leftEdge + itemWidth*(indexSection.index + indexSection.section*_numberOfItems) - layout.minimumInteritemSpacing/2 - (width - itemWidth)/2;
        }
        return MAX(offsetX, 0);
    }else{
        
        CGFloat topEdge = edge.top;
        CGFloat bottomEdge = edge.bottom;
        CGFloat height = CGRectGetHeight(_collectionView.frame);
        CGFloat itemHeight = layout.itemSize.height + layout.minimumInteritemSpacing;
        CGFloat offsetY = 0;
        if (!_isInfiniteLoop && indexSection.index == _numberOfItems - 1) {
            offsetY = topEdge + itemHeight*(indexSection.index + indexSection.section*_numberOfItems) - (height - itemHeight) -  layout.minimumInteritemSpacing + bottomEdge;
        }else {
            offsetY = topEdge + itemHeight*(indexSection.index + indexSection.section*_numberOfItems) - layout.minimumInteritemSpacing/2 - (height - itemHeight)/2;
        }
        return MAX(offsetY, 0);
    }
}

- (void)resetBannerViewAtIndex:(NSInteger)index {
    if (_didLayout && _firstScrollIndex >= 0) {
        index = _firstScrollIndex;
        _firstScrollIndex = -1;
    }
    if (index < 0) {
        return;
    }
    if (index >= _numberOfItems) {
        index = 0;
    }
    [self scrollToItemAtIndexSection:MFMakeIndexSection(index, _isInfiniteLoop ? kBannerViewMaxSectionCount/3 : 0) animate:NO];
    if (!_isInfiniteLoop && _indexSection.index < 0) {
        [self scrollViewDidScroll:_collectionView];
    }
}

- (void)recycleBannerViewIfNeed {
    if (!_isInfiniteLoop) {
        return;
    }
    if (_indexSection.section > kBannerViewMaxSectionCount - kBannerViewMinSectionCount || _indexSection.section < kBannerViewMinSectionCount) {
        [self resetBannerViewAtIndex:_indexSection.index];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return _isInfiniteLoop ? kBannerViewMaxSectionCount : 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    _numberOfItems = [_dataSource numberOfItemsInBannerView:self];
    return _numberOfItems;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    _dequeueSection = indexPath.section;
    if (_dataSourceFlags.cellForItemAtIndex) {
        return [_dataSource bannerView:self cellForItemAtIndex:indexPath.row];
    }
    NSAssert(NO, @"bannerView cellForItemAtIndex: is nil!");
    return nil;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (!_isInfiniteLoop) {
        return _layout.onlyOneSectionInset;
    }
    if (section == 0 ) {
        return _layout.firstSectionInset;
    }else if (section == kBannerViewMaxSectionCount -1) {
        return _layout.lastSectionInset;
    }
    return _layout.middleSectionInset;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if ([_delegate respondsToSelector:@selector(bannerView:didSelectedItemCell:atIndex:)]) {
        [_delegate bannerView:self didSelectedItemCell:cell atIndex:indexPath.item];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!_didLayout) {
        return;
    }
    MFIndexSection newIndexSection =  [self caculateIndexSectionWithOffset:scrollView.contentOffset];
    if (_numberOfItems <= 0 || ![self isValidIndexSection:newIndexSection]) {
        return;
    }
    MFIndexSection indexSection = _indexSection;
    _indexSection = newIndexSection;
    
    if (_delegateFlags.bannerViewDidScroll) {
        [_delegate bannerViewDidScroll:self];
    }
    
    if (_delegateFlags.didScrollFromIndexToNewIndex && !MFEqualIndexSection(_indexSection, indexSection)) {
        [_delegate bannerView:self didScrollFromIndex:MAX(indexSection.index, 0) toIndex:_indexSection.index];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (_autoScrollInterval > 0) {
        [self removeTimer];
    }
    _beginDragIndexSection = [self caculateIndexSectionWithOffset:scrollView.contentOffset];
    if ([_delegate respondsToSelector:@selector(bannerViewWillBeginDragging:)]) {
        [_delegate bannerViewWillBeginDragging:self];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    
    if(_layout.scrollDirection == MFBannerViewScrollDirectionHorizontal){
        
        if (fabs(velocity.x) < 0.35 || !MFEqualIndexSection(_beginDragIndexSection, _indexSection)) {
            targetContentOffset->x = [self caculateOffsetAtIndexSection:_indexSection];
            return;
        }
        MFBannerScrollDirection direction = MFBannerScrollDirectionAfter;
        if ((scrollView.contentOffset.x < 0 && targetContentOffset->x <= 0) || (targetContentOffset->x < scrollView.contentOffset.x && scrollView.contentOffset.x < scrollView.contentSize.width - scrollView.frame.size.width)) {
            direction = MFBannerScrollDirectionBefore;
        }
        MFIndexSection indexSection = [self nearlyIndexPathForIndexSection:_indexSection direction:direction];
        targetContentOffset->x = [self caculateOffsetAtIndexSection:indexSection];
    }else{
        
        if (fabs(velocity.y) < 0.35 || !MFEqualIndexSection(_beginDragIndexSection, _indexSection)) {
            targetContentOffset->x = [self caculateOffsetAtIndexSection:_indexSection];
            return;
        }
        MFBannerScrollDirection direction = MFBannerScrollDirectionAfter;
        if ((scrollView.contentOffset.y < 0 && targetContentOffset->y <= 0) || (targetContentOffset->y < scrollView.contentOffset.y && scrollView.contentOffset.y < scrollView.contentSize.height - scrollView.frame.size.height)) {
            direction = MFBannerScrollDirectionBefore;
        }
        MFIndexSection indexSection = [self nearlyIndexPathForIndexSection:_indexSection direction:direction];
        targetContentOffset->y = [self caculateOffsetAtIndexSection:indexSection];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (_autoScrollInterval > 0) {
        [self addTimer];
    }
    if ([_delegate respondsToSelector:@selector(bannerViewDidEndDragging:willDecelerate:)]) {
        [_delegate bannerViewDidEndDragging:self willDecelerate:decelerate];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    if ([_delegate respondsToSelector:@selector(bannerViewWillBeginDecelerating:)]) {
        [_delegate bannerViewWillBeginDecelerating:self];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self recycleBannerViewIfNeed];
    if ([_delegate respondsToSelector:@selector(bannerViewDidEndDecelerating:)]) {
        [_delegate bannerViewDidEndDecelerating:self];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self recycleBannerViewIfNeed];
    if ([_delegate respondsToSelector:@selector(bannerViewDidEndScrollingAnimation:)]) {
        [_delegate bannerViewDidEndScrollingAnimation:self];
    }
}

#pragma mark - MFBannerTransformLayoutDelegate

- (void)bannerViewTransformLayout:(MFBannerLayout *)bannerViewTransformLayout initializeTransformAttributes:(UICollectionViewLayoutAttributes *)attributes {
    if (_delegateFlags.initializeTransformAttributes) {
        [_delegate bannerView:self initializeTransformAttributes:attributes];
    }
}

- (void)bannerViewTransformLayout:(MFBannerLayout *)bannerViewTransformLayout applyTransformToAttributes:(UICollectionViewLayoutAttributes *)attributes {
    if (_delegateFlags.applyTransformToAttributes) {
        [_delegate bannerView:self applyTransformToAttributes:attributes];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    BOOL needUpdateLayout = !CGRectEqualToRect(_collectionView.frame, self.bounds);
    _collectionView.frame = self.bounds;
    if ((_indexSection.section < 0 || needUpdateLayout) && (_numberOfItems > 0 || _didReloadData)) {
        _didLayout = YES;
        [self setNeedUpdateLayout];
    }
}

- (void)dealloc {
    ((MFBannerTransformLayout *)_collectionView.collectionViewLayout).delegate = nil;
    _collectionView.delegate = nil;
    _collectionView.dataSource = nil;
}

@end
