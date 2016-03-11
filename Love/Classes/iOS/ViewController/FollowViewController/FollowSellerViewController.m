//
//  FollowSellerViewController.m
//  Love
//
//  Created by lee wei on 14-9-22.
//  Copyright (c) 2014年 李伟. All rights reserved.
//

#import "FollowSellerViewController.h"
#import "FollowTableViewCell.h"

#import "MyFollowModel.h"
#import "FollowMeModel.h"

#import "LOVPageConfig.h"
#import "MJRefresh.h"

@interface FollowSellerViewController ()<UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate, FollowViewDelegate>//  UISearchBarDelegate>
{
    int nextPage;
}
//@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSArray *tempDataArray;


@end

@implementation FollowSellerViewController

- (void)setFollowView
{
    for (id view in [self.view subviews]) {
        if ([view isKindOfClass:[UIView class]]) {
            [view removeFromSuperview];
        }
    }
    
    //-------

    
//    //--------
//    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 40.f)];
//    if (VersionNumber_iOS_7) {
//        _searchBar.barTintColor = [UIColor colorRGBWithRed:191.f green:30.f blue:39.f alpha:1];
//    }else{
//        _searchBar.tintColor = [UIColor colorRGBWithRed:191.f green:30.f blue:39.f alpha:1];
//    }
//    _searchBar.delegate = self;
//    _searchBar.placeholder = @"搜索 扫货买手";
//    [self.view addSubview:_searchBar];
    
    //--正在直播
    CGRect tvRect = CGRectMake(0,0, self.view.frame.size.width, self.view.frame.size.height);
    _tableView = [[UITableView alloc] initWithFrame:tvRect style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.view addSubview:_tableView];
    
}


#pragma mark -
#pragma mark - 刷新
- (void)addFollowSellerDataHeader
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
        [ MyFollowModel getMyFollowDataWithPage:kLovStartPage pnum:kLovPageNumber];
        
        
    }];
    
    [self.tableView headerBeginRefreshing];
}

- (void)addFollowSellerDataFooter
{
    __unsafe_unretained typeof(self) mySelf = self;
    // 添加上拉刷新尾部控件
    [self.tableView addFooterWithCallback:^{
        // 进入刷新状态就会回调这个Block
        [mySelf moreSellerDataAciton];
        
    }];
}

- (void)moreSellerDataAciton
{
    nextPage = nextPage + 1;
    NSLog(@"next page = %d", nextPage);
    [ MyFollowModel getMyFollowDataWithPage:[NSString stringWithFormat:@"%d", nextPage] pnum:kLovPageNumber];
    [_tableView reloadData];
}



#pragma mark - init
- (id)init
{
    self = [super init];
    if (self) {
        

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _dataArray = [[NSMutableArray alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(myFollowDataNotice:)
                                                 name:LoveMyFollowDataNotification
                                               object:nil];
    
    self.view.backgroundColor = [UIColor colorRGBWithRed:235.f green:235.f blue:235.f alpha:1];

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
//            
//
//            
//        }else{
//            [_tableView reloadData];
//
//        }
        
        [self addFollowSellerDataHeader];
        [self addFollowSellerDataFooter];
    }
}


#pragma mark - notice
- (void)myFollowDataNotice:(NSNotification *)notice
{
    _tempDataArray = [notice object];
    [_dataArray addObjectsFromArray:_tempDataArray];
    
    [_tableView reloadData];
    
    [self.tableView headerEndRefreshing];
    [self.tableView footerEndRefreshing];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    FollowTableViewCell *cell = (FollowTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"FollowTableViewCell" owner:self options:nil];
        for (id object in  nib) {
            if ([object isKindOfClass:[FollowTableViewCell class]]) {
                cell = (FollowTableViewCell *)object;
            }
        }
    }
    cell.delegate = self;
    
    MyFollowModel *myFollow = _dataArray[(NSUInteger)indexPath.row];
    cell.myFollow = myFollow;
    //cell.sellerNameLabel.text = myFollow.sellerName;
    
    
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
    
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 110.f;
}

/**
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 32.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIButton *moreDataButton = [UIButton buttonWithType:UIButtonTypeCustom];
    moreDataButton.backgroundColor = [UIColor clearColor];
    if ([_tempDataArray count] > 0) {
        [moreDataButton setTitle:MyLocalizedString(@"查看更多") forState:UIControlStateNormal];
    }else{
        [moreDataButton setTitle:MyLocalizedString(@"已是最后一条") forState:UIControlStateNormal];
    }
    
    [moreDataButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    moreDataButton.titleLabel.font = [UIFont systemFontOfSize:14.f];
    moreDataButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [moreDataButton addTarget:self action:@selector(moreSellerDataAciton) forControlEvents:UIControlEventTouchUpInside];
    if ([_dataArray count] > 0) {
        return moreDataButton;
    }
    return nil;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyFollowModel *myFollow = _dataArray[(NSUInteger)indexPath.row];
    [_delegate pushSellerViewControllerWithSellerID:myFollow.sellerID];
}

#pragma mark - 取消关注买手delegate
- (void)cancelFollowButton:(UIButton *)button
{
    NSIndexPath *indexPath = nil;
    if (VersionNumber_iOS_8) {
        indexPath = [_tableView indexPathForCell:(FollowTableViewCell *)[[button superview] superview]];
    }else{
        indexPath = [_tableView indexPathForCell:(FollowTableViewCell *)[[[button superview] superview] superview]];
    }
    NSInteger row = [indexPath  row];
    MyFollowModel *model = (MyFollowModel *)_dataArray[(NSUInteger)row];
    [FollowMeModel doFollowWithId:model.sellerID type:FollowModelTypeWithHaitao block:^(int code) {
        if (code == 0) {
            [self addFollowSellerDataHeader];
        }
    }];
}


#pragma mark - search bar delegate
//- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
//{
//    SellerSearchViewController *searchVC = [[SellerSearchViewController alloc] init];
//    [self.navigationController pushViewController:searchVC animated:YES];
//    
//    return NO;
//}


@end
