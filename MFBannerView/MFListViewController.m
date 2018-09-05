//
//  MFListViewController.m
//  MFBannerView
//
//  Created by 董宝君 on 2018/9/5.
//  Copyright © 2018年 董宝君. All rights reserved.
//

#import "MFListViewController.h"
#import "MFMainViewController.h"
#import "MFBasicTitleCell.h"
#import "MFMarqueeCell.h"
#import <Masonry.h>

static NSString *const ListCellIdentifier = @"ListCellIdentifier";
static NSString *const MarqueeCellIdentifier = @"MarqueeCellIdentifier";

@interface MFListViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation MFListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupView {
    
    self.title = @"MFBannerView";
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
    
#ifdef __IPHONE_11_0
    if (@available(iOS 11.0, *)) {
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view);
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
            make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft);
            make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight);
        }];
    } else
#endif
    {
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.row == 0){
        
        MFBasicTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:ListCellIdentifier forIndexPath:indexPath];
        cell.label.text = @"Basic function ~ 基础功能示例";
        return cell;
    }else{
     
        MFMarqueeCell *cell = [tableView dequeueReusableCellWithIdentifier:MarqueeCellIdentifier forIndexPath:indexPath];
        return cell;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 0:
            {
                MFMainViewController *mainViewController = [[MFMainViewController alloc] init];
                [self.navigationController pushViewController:mainViewController animated:YES];
            }
            break;
        case 1:
        {
            
        }
            break;
        default:
            break;
    }
}

#pragma mark - getter and setter

- (UITableView *)tableView {
    
    if(!_tableView){
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_tableView registerClass:MFMarqueeCell.class forCellReuseIdentifier:MarqueeCellIdentifier];
        [_tableView registerClass:MFBasicTitleCell.class forCellReuseIdentifier:ListCellIdentifier];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 50.0;
        _tableView.bounces = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        _tableView.tableFooterView = [UIView new];
    }
    
    return _tableView;
}

@end
