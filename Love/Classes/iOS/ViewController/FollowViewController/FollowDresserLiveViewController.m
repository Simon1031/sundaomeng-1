//
//  FollowDresserLiveViewController.m
//  Love
//
//  Created by lee wei on 15/2/3.
//  Copyright (c) 2015年 HaiTao. All rights reserved.
//

#import "FollowDresserLiveViewController.h"
#import "BrandTableViewCell.h"

#import "FollowModel.h"
#import "FollowMeModel.h"

#import "LOVPageConfig.h"
#import "LOVCircle.h"

#import "UIImageView+WebCache.h"
#import "MJRefresh.h"

@interface FollowDresserLiveViewController ()<UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate, FollowViewDelegate>
{
    int nextPage;
}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSArray *tempDataArray;

@end

@implementation FollowDresserLiveViewController


- (void)setFollowView
{
    for (id view in [self.view subviews]) {
        if ([view isKindOfClass:[UIView class]]) {
            [view removeFromSuperview];
        }
    }
    
    //--正在直播
    CGRect tvRect = CGRectMake(0,0, self.view.frame.size.width, self.view.frame.size.height);
    _tableView = [[UITableView alloc] initWithFrame:tvRect style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.view addSubview:_tableView];
    [_dataArray removeAllObjects];
    [FollowMasterModel getFollowMasterWithP:@"1" pnum:@"10"];
}


#pragma mark -
#pragma mark - 刷新
- (void)addFollowDresserDataHeader
{
    __unsafe_unretained typeof(self) mySelf = self;
    // 添加下拉刷新头部控件
    [self.tableView addHeaderWithCallback:^{
        // 进入刷新状态就会回调这个Block
        //----- get data
        if ([mySelf.dataArray count] > 0) {
            [mySelf.dataArray removeAllObjects];
            [mySelf.tableView reloadData];
        }
        
        // 增加数据
        [FollowMasterModel getFollowMasterWithP:@"1" pnum:@"10"];
        
    }];
    
    //自动刷新(一进入程序就下拉刷新)
    [self.tableView headerBeginRefreshing];
}

- (void)addFollowDresserDataFooter
{
    __unsafe_unretained typeof(self) mySelf = self;
    // 添加上拉刷新尾部控件
    [self.tableView addFooterWithCallback:^{
        // 进入刷新状态就会回调这个Block
        [mySelf moreDresserDataAciton];
        
    }];
}
- (void)moreDresserDataAciton
{
    nextPage = nextPage + 1;
    [FollowMasterModel getFollowMasterWithP:[NSString stringWithFormat:@"%d",nextPage] pnum:kLovPageNumber];
    [_tableView reloadData];
}



#pragma mark - init
- (id)init
{
    self = [super init];
    if (self) {
        
        nextPage = 1;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _dataArray = [[NSMutableArray alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getDresserDataNotice:)
                                                 name:kFollowMasterNotificationName
                                               object:nil];
    
    self.view.backgroundColor = [UIColor colorRGBWithRed:235.f green:235.f blue:235.f alpha:1];
    
//    [FollowMasterModel getFollowMasterWithP:@"1" pnum:@"10"];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - connect
- (void)isConnect:(BOOL)connect
{
    if (connect) {
        [self setFollowView];
        
        //        if ([_dataArray count] == 0) {
        //            [[NSNotificationCenter defaultCenter] addObserver:self
        //                                                     selector:@selector(getDresserDataNotice:)
        //                                                         name:kFollowDresserNotificationName
        //                                                       object:nil];
        //
        //
        //        }else{
        //            [_tableView reloadData];
        //        }
        //
        
//        [self addFollowDresserDataHeader];
        [self addFollowDresserDataFooter];
    }
}


#pragma mark - notice
- (void)getDresserDataNotice:(NSNotification *)notice
{
    _tempDataArray = [notice object];
    [_dataArray addObjectsFromArray:_tempDataArray];
    
    if ([notice.object count] == 0) {
        [self.tableView setFooterHidden:YES];
    }
    [self.tableView headerEndRefreshing];
    [self.tableView footerEndRefreshing];
    
    
    [_tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([_dataArray count] > 0) {
        return [_dataArray count];
    }else{
        return 1;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    if ([_dataArray count] > 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        for (UIView *vi in cell.contentView.subviews) {
            [vi removeFromSuperview];
        }
//        cell.delegate = self;
        FollowMasterModel *model = (FollowMasterModel *)_dataArray[(NSUInteger)indexPath.row];
        UIView *iconView = [[UIView alloc] initWithFrame:CGRectMake(10, 15, 65, 65)];
        [cell.contentView addSubview:iconView];
        LOVCircle *circle = [[LOVCircle alloc] initWithFrame:CGRectMake(0, 0, 65, 65) imageWithPath:model.mheader placeholderImage:[UIImage imageNamed:kDefalutCommodityImageDownload]];
        [iconView addSubview:circle];
        
        UILabel *namelabel = [[UILabel alloc] initWithFrame:CGRectMake(84, 15, kScreenWidth - 190, 20)];
        namelabel.text = model.mName;
        namelabel.font = [UIFont systemFontOfSize:15.f];
        [cell.contentView addSubview:namelabel];
        
        UILabel *introLabel = [[UILabel alloc] initWithFrame:CGRectMake(84, 35, kScreenWidth - 190, 30)];
        introLabel.text = model.mIntro;
        introLabel.font = [UIFont systemFontOfSize:14.f];
        introLabel.textColor = [UIColor colorRGBWithRed:0 green:0 blue:0 alpha:0.3];
        [cell.contentView addSubview:introLabel];
        
        UIImageView *location = [[UIImageView alloc] initWithFrame:CGRectMake(86, 65, 12, 15)];
        location.image = [UIImage imageNamed:@"icon_location"];
        [cell.contentView addSubview:location];
        
        UILabel *addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 65, kScreenWidth - 205, 20)];
        addressLabel.text = model.mLocation;
        addressLabel.font = [UIFont systemFontOfSize:13.f];
        addressLabel.textColor = [UIColor colorRGBWithRed:0 green:0 blue:0 alpha:0.3];
        [cell.contentView addSubview:addressLabel];
        
        UIButton *attentionBnt = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 100, 33, 90, 30)];
        [attentionBnt setTitle:@"取消关注" forState:UIControlStateNormal];
        attentionBnt.backgroundColor = [UIColor lightGrayColor];
        attentionBnt.titleLabel.font = [UIFont systemFontOfSize:16.f];
        attentionBnt.layer.masksToBounds = YES;
        attentionBnt.layer.cornerRadius = 3.f;
        [attentionBnt addTarget:self action:@selector(cancelFollowButton:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:attentionBnt];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        return cell;
    }else{
        UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"noDataCell"];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"noDataCell"];
        }
        cell.detailTextLabel.text = MyLocalizedString(@"您还没有关注");
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 95.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_dataArray count] > 0) {
        FollowMasterModel *model = (FollowMasterModel *)_dataArray[(NSUInteger)indexPath.row];
        [_delegate pushDresserDetailViewControllerWithUserID:model.mid userName:model.mName];
    }
}

#pragma mark - 取消关注delegate
- (void)cancelFollowButton:(UIButton *)button
{
    NSIndexPath *indexPath = nil;
    if (VersionNumber_iOS_8) {
        indexPath = [_tableView indexPathForCell:(BrandTableViewCell *)[[button superview] superview]];
    }else{
        indexPath = [_tableView indexPathForCell:(BrandTableViewCell *)[[[button superview] superview] superview]];
    }
    NSInteger row = [indexPath  row];
    FollowMasterModel *model = (FollowMasterModel *)_dataArray[(NSUInteger)row];
    [FollowMeModel doFollowWithId:model.mid type:7 block:^(int code) {
        if (code == 0) {
            [self addFollowDresserDataHeader];
        }
    }];
}


@end
