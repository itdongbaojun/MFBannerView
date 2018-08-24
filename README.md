## MFBannerView
a auto scroll banner view suport horizontal and vertical direction.
 
### CocoaPods

```ruby
pod 'MFBannerView'
```

### Requirements
* Xcode 9 or higher
* iOS 8.0 or higher
* ARC

### ScreenShot
![image](https://github.com/itdongbaojun/MFBannerView/blob/master/ScreenShot/MFBannerView.gif)

### Usage

```objc
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
    
    // 没有提供默认的pageControl实现，使用者根据自己的需要实现自己的pageControl即可
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


#pragma mark - MFBannerViewDataSource

// 数据源实现
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

// 可以通过响应的delegate实现一些自定义操作
- (void)bannerView:(MFBannerView *)bannerView didScrollFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    
    self.pageControl.text = [NSString stringWithFormat:@"%@/%@",@(toIndex + 1),@(self.datas.count)];
}

```

### 感谢和说明

该代码实现主要在[TYCyclePagerView](https://github.com/12207480/TYCyclePagerView)基础上进行的修改，在原基础上增加了垂直方向的滚动实现，同时对一些代码进行修改，后续也会在原repo的基础上进行针对垂直滚动的实现进行修改提交pr，如有侵权请联系本人删除。由于之前项目内使用[SDCycleScrollView](https://github.com/gsdios/SDCycleScrollView)通过源码的形式进行了很大程度的修改来满足业务上的需求，定制的自由程度不高。因此参考上述两者的代码和我们自己的业务，进行了修改，在这里对上述两个开源库的作者表示深深的感谢。

