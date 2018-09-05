//
//  MFBasicTitleCell.m
//  MFBannerView
//
//  Created by 董宝君 on 2018/9/5.
//  Copyright © 2018年 董宝君. All rights reserved.
//

#import "MFBasicTitleCell.h"
#import <Masonry.h>

@interface MFBasicTitleCell()

@property (nonatomic, strong) UIView *bottomLine;

@end

@implementation MFBasicTitleCell

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
    
    [self.contentView addSubview:self.label];
    [self.contentView addSubview:self.bottomLine];

    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.top.bottom.trailing.equalTo(self.contentView);
        make.leading.mas_equalTo(@15.0);
    }];
    
    [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView.mas_bottom);
        make.height.mas_equalTo(@(1.0/[UIScreen mainScreen].scale));
    }];
}

#pragma mark - setter and getter

- (UILabel *)label {
    
    if(!_label){
        
        _label = [[UILabel alloc]init];
        _label.textAlignment = NSTextAlignmentLeft;
        _label.textColor = [UIColor blackColor];
        _label.font = [UIFont systemFontOfSize:18];
    }
    
    return _label;
}

- (UIView *)bottomLine {
    
    if(!_bottomLine){
        
        _bottomLine = [[UIView alloc] initWithFrame:CGRectZero];
        _bottomLine.backgroundColor = [UIColor lightGrayColor];
    }
    
    return _bottomLine;
}


@end
