//
//  UserHomeViewController.m
//  Love
//
//  Created by use on 15-3-18.
//  Copyright (c) 2015年 HaiTao. All rights reserved.
//

#import "UserHomeViewController.h"
#import "LOVSegmentControl.h"
#import "ShareProductViewController.h"
#import "LoginViewController.h"
#import "ProductDetailViewController.h"
#import "UserHomeHeaderView.h"
#import "ShareProductDetailViewController.h"
#import "MyCartViewController.h"
#import "CommissionSKUViewController.h"
#import "LoginViewController.h"

#import "UserInfoAndShareModel.h"
#import "ShareListModel.h"
#import "UserManager.h"
#import "FollowMeModel.h"
#import "SKUModel.h"
#import "UserManager.h"

#import "LOVCircle.h"
#import "UIImageView+WebCache.h"
#import "MJRefresh.h"
#import "SVProgressHUD.h"
static CGFloat const kImageOriginHight = 160.f;
@interface UserHomeViewController ()<UITableViewDataSource,UITableViewDelegate,pushNextViewController>
{
    int nextPage;
}
@property (nonatomic, strong) LOVSegmentControl *segmentController;
@property (nonatomic, strong) UserHomeHeaderView *headerView;
@property (nonatomic, strong) ShareProductViewController *shareProductVC;
@property (nonatomic, strong) ProductDetailViewController *productDetailVC;
@property (nonatomic, strong) ShareProductDetailViewController *shareDetailProductVC;
@property (nonatomic, strong) CommissionSKUViewController *skuViewController;

@property (nonatomic, strong) UIView *myContentView;
@property (nonatomic, strong) UIImageView *zoomImageView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation UserHomeViewController
#pragma mark -- pushNextViewController(商品点击进入后续页面)
- (void)pushViewDelegateAndProductId:(NSString *)productId productName:(NSString *)productName{
    if (_shareDetailProductVC == nil) {
        _shareDetailProductVC = [[ShareProductDetailViewController alloc] init];
        _shareDetailProductVC.productId = productId;
        _shareDetailProductVC.productName = productName;
        [_shareDetailProductVC reloadTheDataWithShare:YES];
        [self.navigationController pushViewController:_shareDetailProductVC animated:YES];
    }
}

- (void)pushSKUViewControllerWithProductId:(NSString *)productId ProductIntro:(NSString *)productIntro{
    [self pushSKUViewController:YES ProductId:productId ProductIntro:productIntro];
    
}
//修改商品显示时头的frame
- (void)changeFrame:(UITableView *)tableView{
    CGRect tableVewFrame = tableView.frame;
    CGRect zoomFrame = _zoomImageView.frame;
    if (tableView.contentOffset.y < 0) {
        zoomFrame.origin.y = 0;
        zoomFrame.size.height = 200 - tableView.contentOffset.y;
    }else{
        zoomFrame.origin.y = -tableView.contentOffset.y;
    }
    CGRect headerFrame = _headerView.frame;
    headerFrame.origin.y = -tableView.contentOffset.y;
    CGRect segFrame = _segmentController.frame;
    segFrame.origin.y = 160 - tableView.contentOffset.y;
    CGRect contentViewFrame = _myContentView.frame;
    if (200 - tableView.contentOffset.y > 0) {
        contentViewFrame.origin.y = segFrame.origin.y + segFrame.size.height;
        contentViewFrame.size.height = tableView.frame.size.height + tableView.contentOffset.y;
    }else{
        contentViewFrame.origin.y = 0;
        contentViewFrame.size.height = kScreenHeight - 64.f;
    }
    _zoomImageView.frame = zoomFrame;
    _headerView.frame = headerFrame;
    _segmentController.frame = segFrame;
    _myContentView.frame = contentViewFrame;
}

//跳转到SKU页面
- (void)pushSKUViewController:(BOOL)isCart ProductId:(NSString *)productId ProductIntro:(NSString *)productIntro
{
    NSString *sig = [UserManager readSig];
    if ([sig length] > 0) {
        if (_skuViewController == nil) {
            NSString *item = productId;
            [SKUModel getSKUWithItem:item block:^(NSString *thumbPath, NSString *stockNum,NSString *section1,
                                                  NSString *section2, NSString *price1, NSString *price2, NSString *price3, NSString *defaultPrice, NSDictionary *commoListDic, NSArray *skuValueArray) {
                
                _skuViewController = [[CommissionSKUViewController alloc] initWithNibName:@"CommissionSKUViewController" bundle:nil];
                _skuViewController.isCart = isCart;
                _skuViewController.commoStr = item;
                _skuViewController.thumbPath = thumbPath;
                _skuViewController.stocksNum = stockNum;
                _skuViewController.defaultPrice = defaultPrice;
                _skuViewController.commList = commoListDic;
                _skuViewController.skuValueArr = skuValueArray;
                _skuViewController.section1 = section1;
                _skuViewController.section2 = section2;
                _skuViewController.price1 = price1;
                _skuViewController.price2 = price2;
                _skuViewController.price3 = price3;
                
                _skuViewController.intro = productIntro;
                [self.navigationController pushViewController:_skuViewController animated:YES];
            }];
        }
    }else{
        LoginViewController *loginController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:loginController animated:YES];
    }
}


-(instancetype)init{
    self = [super init];
    if (self) {
//        self.title = _userName;
        nextPage = 1;
        _dataArray = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    _shareDetailProductVC = nil;
    _shareProductVC = nil;
    _productDetailVC = nil;
    _skuViewController = nil;
//    [self addHeaderRefresh];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = _userName;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getShareListData:) name:kShareListNotificationName object:nil];
    
    [UserInfoAndShareModel getUserInfoAndShareList:_userId block:^(NSDictionary *userInfo) {
        LOVCircle *circleView = [[LOVCircle alloc] initWithFrame:CGRectMake(0, 0, 75, 75) imageWithPath:[userInfo objectForKey:@"header"] placeholderImage:[UIImage imageNamed:kDefalutCommodityImageDownload]];
        _headerView.iconImageView.backgroundColor = [UIColor clearColor];
        //    _headerView.iconImageView.image = [UIImage imageNamed:@"icon"];
        [_headerView.iconImageView addSubview:circleView];
        [self.view addSubview:_headerView];
        
        _headerView.fasnNumber.text = [userInfo objectForKey:@"funs"];
        
        _headerView.shareLabel.text = [userInfo objectForKey:@"share"];
        
        if ([[userInfo objectForKey:@"is_attent"] isEqual:@"0"]) {
            NSLog(@"未关注");
        }else{
            NSLog(@"已关注");
            _headerView.attentButton.backgroundColor = [UIColor colorRGBWithRed:255 green:255 blue:255 alpha:0.3];
            [_headerView.attentButton setTitle:@"√ 已关注" forState:UIControlStateNormal];
            [_headerView.attentButton setTitleColor:[UIColor colorRGBWithRed:0 green:0 blue:0 alpha:0.3] forState:UIControlStateNormal];
            _headerView.attentButton.userInteractionEnabled = NO;
        }
        
    }];
    
    //----- 导航条右侧按钮
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 25.f, 20.f);
    rightButton.backgroundColor = [UIColor clearColor];
    [rightButton setImage:[UIImage imageNamed:@"icon_cart"] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(rightButtonPressAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    [self.navigationItem setRightBarButtonItem:rightBarButton animated:YES];
    
    _zoomImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_userhome.jpg"]];
    _zoomImageView.frame = CGRectMake(0, 0, kScreenWidth, kImageOriginHight);
    _zoomImageView.userInteractionEnabled = YES;
//    self.tableView.contentInset = UIEdgeInsetsMake(kImageOriginHight, 0, 0, 0);
    [self.view addSubview:_zoomImageView];
    
    _headerView = [[UserHomeHeaderView alloc] initWithFrame:CGRectMake(0, 0, _zoomImageView.frame.size.width, _zoomImageView.frame.size.height)];
    _headerView.userInteractionEnabled = YES;
    _headerView.attentButton.backgroundColor = [UIColor colorRGBWithRed:252 green:130 blue:37 alpha:1];
    [_headerView.attentButton setTitle:@"+ 关注" forState:UIControlStateNormal];
    _headerView.attentButton.layer.masksToBounds = YES;
    _headerView.attentButton.layer.cornerRadius = 3.f;
    [_headerView.attentButton addTarget:self action:@selector(attentedButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    NSArray *titleArr = @[MyLocalizedString(@"分享"),MyLocalizedString(@"商品")];
    _segmentController = [[LOVSegmentControl alloc] initWithItems:titleArr];
    _segmentController.frame = CGRectMake(0, 160, CGRectGetWidth(self.view.frame), 40);
    _segmentController.backgroundColor = [UIColor whiteColor];
    _segmentController.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    _segmentController.layer.borderWidth = 0.4;
    _segmentController.selectedSegmentIndex = 0;
    [_segmentController addTarget:self action:@selector(headButtonAction:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_segmentController];
    
    CGRect tvRect = CGRectMake(0, CGRectGetMaxY(_segmentController.frame), kScreenWidth, kScreenHeight - 64);
    _myContentView.backgroundColor = [UIColor whiteColor];
    _myContentView = [[UIView alloc] initWithFrame:tvRect];
    [self.view addSubview:_myContentView];
    
    [self reloadShareData];
}

- (void)addHeaderRefresh{
    // 添加下拉刷新头部控件
    __unsafe_unretained typeof(self) mySelf = self;
    [self.tableView addHeaderWithCallback:^{
        if ([mySelf.dataArray count] > 0) {
            [mySelf.dataArray removeAllObjects];
            [mySelf.tableView reloadData];
        }
//        [ShareLabelListModel getShareLabelListWithTagId:mySelf.labelId page:@"1" pageNumber:@"10"];
        [ShareListModel getShareListWithShareId:mySelf.userId page:@"1" pageNumber:@"10"];
    }];
    
    [self.tableView headerBeginRefreshing];
}

- (void)addFooterRefresh{
    __unsafe_unretained typeof(self) mySelf = self;
    // 添加上拉刷新尾部控件
    [self.tableView addFooterWithCallback:^{
        // 进入刷新状态就会回调这个Block
        [mySelf loadingDataAction];
    }];
}

- (void)loadingDataAction{
    nextPage = nextPage + 1;
//    [ShareLabelListModel getShareLabelListWithTagId:_labelId page:[NSString stringWithFormat:@"%d",nextPage] pageNumber:@"10"];
    [ShareListModel getShareListWithShareId:_userId page:[NSString stringWithFormat:@"%d",nextPage] pageNumber:@"10"];
}

- (void)getShareListData:(NSNotification *)noti{
    [_dataArray addObjectsFromArray:noti.object];
    [self.tableView reloadData];
    [self.tableView headerEndRefreshing];
    [self.tableView footerEndRefreshing];
}

#pragma mark -- reloadProduct
- (void)reloadProductView{
    _segmentController.selectedSegmentIndex = 1;
    //---- 标签
    _shareProductVC.view.alpha = 1;
    _tableView.alpha = 0;
    if (_shareProductVC == nil) {
        _shareProductVC = [[ShareProductViewController alloc] init];
        _shareProductVC.view.frame = _myContentView.bounds;
        _shareProductVC.userId = _userId;
        [_shareProductVC reloadProductListData];
        _shareProductVC.view.alpha = 1.f;
        _shareProductVC.delegate = self;
        [_shareProductVC.view setBackgroundColor:[UIColor clearColor]];
        _shareProductVC.view.userInteractionEnabled = YES;
        [_myContentView addSubview:_shareProductVC.view];
    }
}
#pragma mark -- reloadShare
- (void)reloadShareData{
    _tableView = [[UITableView alloc] initWithFrame:_myContentView.bounds style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_myContentView addSubview:_tableView];
    [self addHeaderRefresh];
    [self addFooterRefresh];
//    _shareProductVC.view.alpha = 0;
//    _tableView.alpha = 1;
//
//    // 加载数据
//    if ([self.dataArray count] > 0) {
//        [self.dataArray removeAllObjects];
//        [self.tableView reloadData];
//    }else{
//        
//    }
//    [ShareListModel getShareListWithShareId:_userId
//                                       page:@"1"
//                                 pageNumber:@"10"];
    
//    [self addHeaderRefresh];
    
}

#pragma mark -- buttonAction
- (void)headButtonAction:(LOVSegmentControl *)segmentController{
    NSInteger tag = segmentController.selectedSegmentIndex;
    if (tag == 0) {
        nextPage = 1;
        [self reloadShareData];
    }else{
        nextPage = 1;
        [self reloadProductView];
    }
}

- (void)rightButtonPressAction:(UIButton *)sender{
    NSLog(@"购物车");
    MyCartViewController *myCartVC = [[MyCartViewController alloc] init];
    [self.navigationController pushViewController:myCartVC animated:YES];
}

- (void)attentedButtonAction:(UIButton *)button{
    NSLog(@"未关注");
    NSString *sig = [UserManager readSig];
    if (sig.length > 0) {
        NSLog(@"喜欢");
        [FollowMeModel doFollowWithId:_userId type:7 block:^(int code) {
            if (code == 1) {
                _headerView.attentButton.backgroundColor = [UIColor colorRGBWithRed:255 green:255 blue:255 alpha:0.3];
                [_headerView.attentButton setTitle:@"√ 已关注" forState:UIControlStateNormal];
                [_headerView.attentButton setTitleColor:[UIColor colorRGBWithRed:0 green:0 blue:0 alpha:0.3] forState:UIControlStateNormal];
                _headerView.attentButton.userInteractionEnabled = NO;
            }else{
                [SVProgressHUD showErrorWithStatus:@"关注失败"];
            }
        }];
        
        
        
    }else{
        LoginViewController *loginVC = [[LoginViewController alloc] init];
        [self.navigationController pushViewController:loginVC animated:YES];
    }

    
}

#pragma mark -- UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([_dataArray count] > 0) {
        return [_dataArray count];
    }else{
        return 1;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"cellID";
    static NSString *cellID1 = @"cellID1";
    if ([_dataArray count] > 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
            ShareListModel *model = (ShareListModel*)_dataArray[indexPath.row];
            
            UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 100, 100)];
            iconImageView.backgroundColor = [UIColor lightGrayColor];
            iconImageView.layer.masksToBounds = YES;
            iconImageView.layer.cornerRadius = 3.f;
            NSString *urlString = model.thumb;
            [iconImageView sd_setImageWithURL:[NSURL URLWithString:urlString] placeholderImage:[UIImage imageNamed:kDefalutCommodityImageDownload]];
            [cell.contentView addSubview:iconImageView];
        
            UILabel *tagLabel = [[UILabel alloc] initWithFrame:CGRectMake(125, 10, kScreenWidth - 135, 25)];
            tagLabel.text = [NSString stringWithFormat:@"# %@",model.tagName];
            [cell.contentView addSubview:tagLabel];
        
            UILabel *introLabel = [[UILabel alloc] initWithFrame:CGRectMake(125, 30, kScreenWidth - 135, 50)];
            introLabel.text = [NSString stringWithFormat:@"%@",model.content];
            introLabel.font = [UIFont systemFontOfSize:15.f];
            introLabel.numberOfLines = 0;
            introLabel.textColor = [UIColor colorRGBWithRed:1.f green:1.f blue:1.f alpha:0.6];
            [cell.contentView addSubview:introLabel];
        
            UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(125, CGRectGetMaxY(introLabel.frame), kScreenWidth - 135, 15)];
            timeLabel.text = [NSString stringWithFormat:@"%@",model.createTime];
            timeLabel.font = [UIFont systemFontOfSize:13.f];
            [cell.contentView addSubview:timeLabel];
        
            UIImageView *localIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(125, CGRectGetMaxY(timeLabel.frame) + 3, 10, 13)];
            localIconImageView.backgroundColor = [UIColor clearColor];
            localIconImageView.image = [UIImage imageNamed:@"icon_location"];
            [cell.contentView addSubview:localIconImageView];
        
            UILabel *localLabe = [[UILabel alloc] initWithFrame:CGRectMake(140, CGRectGetMaxY(timeLabel.frame), kScreenWidth - 135, 15)];
            localLabe.text = [NSString stringWithFormat:@"%@",model.location];
            localLabe.font = [UIFont systemFontOfSize:13.f];
            [cell.contentView addSubview:localLabe];
        
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(125, 113.f, kScreenWidth - 123.f, 1)];
            lineView.backgroundColor = [UIColor colorRGBWithRed:1.f green:1.f blue:1.f alpha:0.1];
            [cell.contentView addSubview:lineView];
        
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    return cell;
    }else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID1];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID1];
            cell.textLabel.text = @"还没有数据";
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        return cell;
    }
    return nil;
}

#pragma mark -- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    if (indexPath.row == 0) {
//        return 200.f;
//    }
    return 114.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ShareListModel *model = _dataArray[indexPath.row];
    if (_productDetailVC == nil) {
        _productDetailVC = [[ProductDetailViewController alloc] init];
        _productDetailVC.shareId = model.shareId;
        _productDetailVC.myTitle = model.myTitle;
        [self.navigationController pushViewController:_productDetailVC animated:YES];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == _tableView) {
        CGRect zoomFrame = _zoomImageView.frame;
        if (_tableView.contentOffset.y < 0) {
            zoomFrame.origin.y = 0;
            zoomFrame.size.height = 200 - _tableView.contentOffset.y;
        }else{
            zoomFrame.origin.y = -_tableView.contentOffset.y;
        }
        CGRect headerFrame = _headerView.frame;
        headerFrame.origin.y = -_tableView.contentOffset.y;
        CGRect segFrame = _segmentController.frame;
        segFrame.origin.y = 160 - _tableView.contentOffset.y;
        CGRect contentViewFrame = _myContentView.frame;
        if (200 - _tableView.contentOffset.y > 0) {
            contentViewFrame.origin.y = segFrame.origin.y + segFrame.size.height;
            contentViewFrame.size.height = _tableView.frame.size.height + _tableView.contentOffset.y;
        }else{
            contentViewFrame.origin.y = 0;
            contentViewFrame.size.height = kScreenHeight - 64.f;
        }
        _zoomImageView.frame = zoomFrame;
        _headerView.frame = headerFrame;
        _segmentController.frame = segFrame;
        _myContentView.frame = contentViewFrame;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
