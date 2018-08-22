//
//  MFBannerCell.h
//  MFBannerView
//
//  Created by 董宝君 on 2018/8/22.
//  Copyright © 2018年 董宝君. All rights reserved.
//

#import <UIKit/UIKit.h>

/// 业务方根据自己的需要定义自己需要的cell即可
@interface MFBannerCell : UICollectionViewCell

@property (nonatomic, weak, readonly) UILabel *label;

@end
