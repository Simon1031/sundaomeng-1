//
//  Config.h
//  CSLCLottery
//
//  Created by 李伟 on 13-1-21.
//  Copyright (c) 2013年 CSLC. All rights reserved.
//
#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhone4 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)

#define VersionNumber_iOS_8  [[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0
#define VersionNumber_iOS_7  [[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0 //floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1

#define MyLocalizedString(S)  NSLocalizedString(S, @"")

#define kMaximumLeftDrawerWidth  150.f
#define kMaximumRightDrawerWidth  [[UIScreen mainScreen] bounds].size.width

#define kScreenWidth [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height

#define kDefalutCommodityImageDownload  @"default_image_download"
#define kDefalutFlagImageDownload       @"albums.png"

#define kHomePageTimeNotificationName @"HomePageTimeNotificationName"
#define kHomePageCatagoryNotificationName @"HomePageCatagoryNotificationName"


//--------登录测试
#define TestSessionKey    @"abcdefghigklmn12345678"
#define TestUserName      @"baai"
#define TestPassword      @"123456"

//-----获取省市区
#define kAllAddressKey     @"ProvinceCityDistrict"

// iTunes identifier
#define iTunesItemIdentifier @"444934666" //

typedef NS_ENUM(NSUInteger, LOVShareType) {
    LOVShareTypeWeixin = 0,
    LOVShareTypeWeixinTimeline = 1,
    LOVShareTypeSinaWeibo = 2,
    LOVShareTypeQQ = 3,
    LOVShareTypeQzone = 4
};

